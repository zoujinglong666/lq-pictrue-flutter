import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lq_picture/model/picture.dart';

import '../apis/picture_api.dart';
import '../model/notify.dart';
import '../services/sse_service.dart';
import '../widgets/cached_image.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  int _unreadNotificationCount = 0; // 未读消息数量
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  late SSEService _sseService;


  List<String> tagList = ["热门", "搞笑", "生活", "高清", "艺术", "校园", "背景", "简历", "创意"];
  List<String> categoryList = ["模板", "电商", "表情包", "素材", "海报"];
  List<PictureVO> _images = [

  ];

  /// 设置SSE监听器
  void _setupSSEListener() {
    // 后端SSE接口已实现，使用真实连接，传递ref用于检查登录状态
    _sseService.initialize(ref: ref);
    _sseService.addUnreadCountListener(_handleUnreadCountChange);
    _sseService.addNewNotificationListener(_handleNewNotification);
  }

  /// 处理未读数量变化
  void _handleUnreadCountChange(int count) {
    if (mounted) {
      setState(() {
        _unreadNotificationCount = count;
      });
    }
  }

  /// 处理新通知到达
  void _handleNewNotification(NotifyVO notify) {
    // 可以在这里添加本地通知或弹窗提示
    print('收到新通知: ${notify.content}');
    
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
  }
  @override
  void dispose() {
    _sseService.removeUnreadCountListener(_handleUnreadCountChange);
    _sseService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 更新列表中的图片数据
  void _updatePictureInList(PictureVO updatedPicture) {
    setState(() {
      final index = _images.indexWhere((picture) => picture.id == updatedPicture.id);
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
    final res = await PictureApi.getList({
      "current": 1,
      "pageSize": 10,
      "sortField": 'createTime',
      "sortOrder": 'descend',
    });

    setState(() {
      _images = res.records ?? [];
      _isLoading = false;
      _currentPage = 2; // 下一页为2
      _hasMore = (res.records.length ?? 0) >= 10; // 如果返回数据少于请求数量，说明没有更多了
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _loadMoreImages() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final res = await PictureApi.getList({
      "current": _currentPage,
      "pageSize": 10,
      "sortField": 'createTime',
      "sortOrder": 'descend',
    });

    setState(() {
      if (res.records != null) {
        _images.addAll(res.records!);
        _currentPage++;
        // 如果返回数据少于请求数量，说明没有更多了
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

// 添加一个新的方法用于下拉刷新
Future<void> _refreshData() async {
  if (_isLoading) return;
  setState(() {
    _isLoading = true;
    _hasMore = true;
    _currentPage = 1;
  });

  try {
    final res = await PictureApi.getList({
      "current": 1,
      "pageSize": 10,
      "sortField": 'createTime',
      "sortOrder": 'descend',
    });

    setState(() {
      _images = res.records ?? [];
      _isLoading = false;
      _currentPage = 2; // 下一页为2
      _hasMore = (res.records.length ?? 0) >= 10;
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
                          icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[700], size: 20),
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
                              _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search_outlined, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '搜索图片...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // _buildDownSimple(context),
            SizedBox(height: 8),
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
                            Icon(Icons.image_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              '暂无图片',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                                if (updatedPicture != null && updatedPicture is PictureVO) {
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
                                      aspectRatio: image.picWidth/image.picHeight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                        ),
                                        child:  CachedImage(
                                        fit: BoxFit.cover, imageUrl: image.thumbnailUrl,
                                      ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                image.hasLiked ? Icons.favorite : Icons.favorite_border_outlined,
                                                size: 14,
                                                color: image.hasLiked ? Colors.red[400] : Colors.grey[600],
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
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(10),
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

