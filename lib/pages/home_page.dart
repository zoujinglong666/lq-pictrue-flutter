import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lq_picture/apis/notific_api.dart';
import 'package:lq_picture/model/picture.dart';

import '../apis/picture_api.dart';
import '../model/notify.dart';
import '../services/sse_service.dart';
import '../widgets/cached_image.dart';
import '../providers/unread_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  int _unreadNotificationCount = 0; // 未读消息数量
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  late SSEService _sseService;

  // 搜索和筛选相关
  String _searchKeyword = '';
  String _selectedCategory = '全部';
  String _selectedSort = '最新';
  bool _showFilters = false;
  
  final List<String> _categories = ['全部', '模板', '电商', '表情包', '素材', '海报'];
  final List<String> _sortOptions = ['最新', '热门'];
  
  List<PictureVO> _images = [];

  /// 设置SSE监听器
  void _setupSSEListener() {
    // 后端SSE接口已实现，使用真实连接，传递ref用于检查登录状态
    _sseService.initialize(ref: ref);
    _sseService.addUnreadCountListener(_handleUnreadCountChange);
    _sseService.addNewNotificationListener(_handleNewNotification);
  }

  /// 处理未读数量变化（同步到全局 Provider）
  void _handleUnreadCountChange(int count) {
    // if (mounted) {
    //   setState(() {
    //     _unreadNotificationCount = count;
    //   });
    //   // 同步到 Riverpod Provider，供全局使用（底部消息图标角标等）
    //   ref.read(unreadCountProvider.notifier).state = count;
    // }
  }

  /// 处理新通知到达
  void _handleNewNotification(NotifyVO notify) {
    // 可以在这里添加本地通知或弹窗提示
    print('收到新通知: ${notify.content}');
    _loadCountUnread();
    // 如果需要显示弹窗提示
    // _showNotificationDialog(notify);
  }

  /// 显示通知弹窗（可选功能）
  // void _showNotificationDialog(NotifyVO notify) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('新消息'),
  //       content: Text(notify.content),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('知道了'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             Navigator.pushNamed(context, '/notification');
  //           },
  //           child: const Text('查看'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  void initState() {
    super.initState();
    _sseService = SSEService();
    _setupSSEListener();
    _scrollController.addListener(_onScroll);
    _loadData();
    _loadCountUnread();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _sseService.removeUnreadCountListener(_handleUnreadCountChange);
    _sseService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 更新列表中的图片数据
  void _updatePictureInList(PictureVO updatedPicture) {
    setState(() {
      final index =
          _images.indexWhere((picture) => picture.id == updatedPicture.id);
      if (index != -1) {
        _images[index] = updatedPicture;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreImages();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requestData = _buildRequestParams(1);
      final res = await PictureApi.getList(requestData);

      setState(() {
        _images = res.records ?? [];
        _isLoading = false;
        _currentPage = 2; // 下一页为2
        _hasMore = (res.records?.length ?? 0) >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 构建请求参数
  Map<String, dynamic> _buildRequestParams(int page) {
    final params = <String, dynamic>{
      "current": page,
      "pageSize": 10,
      "sortField": _selectedSort == '热门' ? 'likeCount' : 'createTime',
      "sortOrder": 'descend',
    };
    
    // 添加搜索关键词
    if (_searchKeyword.isNotEmpty) {
      params['searchText'] = _searchKeyword;
    }
    
    // 添加分类筛选
    if (_selectedCategory != '全部') {
      params['category'] = _selectedCategory;
    }
    
    return params;
  }

  Future<void> _loadCountUnread() async {
    try {
      final res = await NotifyApi.countUnread();
      setState(() {
        _unreadNotificationCount = int.parse(res as String);
      });
      ref.read(unreadCountProvider.notifier).state = _unreadNotificationCount;
    } catch (e) {}
  }

  Future<void> _loadMoreImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final requestData = _buildRequestParams(_currentPage);
      final res = await PictureApi.getList(requestData);

      setState(() {
        if (res.records != null) {
          _images.addAll(res.records!);
          _currentPage++;
          _hasMore = res.records!.length >= 10;
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 执行搜索
  void _performSearch(String keyword) {
    setState(() {
      _searchKeyword = keyword.trim();
      _currentPage = 1;
      _hasMore = true;
    });
    _searchFocusNode.unfocus(); // 收起键盘
    _loadData();
  }
  
  // 应用筛选
  void _applyFilters() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _showFilters = false;
    });
    _loadData();
  }
  
  // 清空搜索
  void _clearSearch() {
    setState(() {
      _searchKeyword = '';
      _searchController.clear();
      _selectedCategory = '全部';
      _selectedSort = '最新';
      _currentPage = 1;
      _hasMore = true;
    });
    _loadData();
  }

  // 下拉刷新
  Future<void> _refreshData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _currentPage = 1;
    });
    try {
      await _loadCountUnread();
      final requestData = _buildRequestParams(1);
      final res = await PictureApi.getList(requestData);

      setState(() {
        _images = res.records ?? [];
        _isLoading = false;
        _currentPage = 2;
        _hasMore = (res.records?.length ?? 0) >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 标题和搜索框
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Text(
                    '龙琪图库',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications_none_outlined,
                              color: Colors.grey[700], size: 20),
                          onPressed: () {
                            Navigator.pushNamed(context, '/notification');
                          },
                        ),
                      ),
                      if (_unreadNotificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red[500],
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotificationCount > 99
                                  ? '99+'
                                  : _unreadNotificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 搜索框
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: '搜索图片...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search_outlined,
                        color: Colors.grey[600], size: 20),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
                            onPressed: _clearSearch,
                          ),
                        IconButton(
                          icon: Icon(
                            _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                            color: _showFilters ? const Color(0xFF00BCD4) : Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    setState(() {}); // 更新清除按钮显示状态
                  },
                ),
              ),
            ),
            
            // 筛选器
            if (_showFilters)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类筛选
                    const Text(
                      '分类',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00BCD4)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00BCD4)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // 排序选择
                    const Text(
                      '排序',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sortOptions.map((sort) {
                        final isSelected = sort == _selectedSort;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSort = sort;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00BCD4)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00BCD4)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              sort,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // 应用按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('应用筛选'),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),
            // 瀑布流内容
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    if (_isLoading && _images.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_images.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              '暂无图片',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _refreshData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('刷新试试'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF00BCD4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childCount: _images.length,
                        itemBuilder: (context, index) {
                          final image = _images[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: image,
                              ).then((updatedPicture) {
                                // 如果详情页返回了更新后的图片数据，更新列表中的对应图片
                                if (updatedPicture != null &&
                                    updatedPicture is PictureVO) {
                                  _updatePictureInList(updatedPicture);
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio:
                                          image.picWidth / image.picHeight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                        ),
                                        child: CachedImage(
                                          fit: BoxFit.cover,
                                          imageUrl: image.thumbnailUrl,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            image.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                image.hasLiked
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_border_outlined,
                                                size: 14,
                                                color: image.hasLiked
                                                    ? Colors.red[400]
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                image.likeCount,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00BCD4)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  image.category,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF00BCD4),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 加载更多指示器
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : !_hasMore
                                ? Center(
                                    child: Text(
                                      '没有更多图片了',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
