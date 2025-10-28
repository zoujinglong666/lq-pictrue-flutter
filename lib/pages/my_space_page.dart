import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/model/picture.dart';
import 'package:lq_picture/pages/image_edit_page.dart';
import 'package:lq_picture/pages/upload_page.dart';
import 'package:lq_picture/providers/space_provider.dart';

import '../apis/picture_api.dart';
import '../providers/auth_provider.dart';
import '../widgets/cached_image.dart';
import '../utils/keyboard_utils.dart';

class MySpacePage extends ConsumerStatefulWidget {
  final VoidCallback? onRefresh;

  const MySpacePage({super.key, this.onRefresh});

  @override
  ConsumerState<MySpacePage> createState() => _MySpacePageState();
}

class _MySpacePageState extends ConsumerState<MySpacePage>
    with KeyboardDismissMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _selectedImageId;
  bool _showActionOverlay = false;

  // 图片列表数据
  List<PictureVO> _images = [];

  @override
  void initState() {
    super.initState();
    
    _scrollController.addListener(_onScroll);
    
    // 延迟加载，确保 Provider 已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }
  
  /// 初始化数据
  Future<void> _initData() async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null && user.id != null) {
      // 使用 Provider 加载空间数据
      await ref.read(spaceProvider.notifier).loadMySpace(user.id!);
      // 加载图片列表
      await _loadData();
    }
    
    // 如果有刷新回调，调用它
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreImages();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    // 从 Provider 获取空间数据
    final spaceState = ref.read(spaceProvider);
    final spaceData = spaceState.space;

    if (spaceData == null || spaceData.id.isEmpty) {
      setState(() {
        _images = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _images.clear(); // ✅ 刷新时清空旧数据
      _currentPage = 1; // ✅ 重置页码
    });

    try {
      final res = await PictureApi.getList({
        "current": 1,
        "pageSize": 10,
        "spaceId": spaceData.id,
      });

      setState(() {
        _images = res.records ?? [];
        _isLoading = false;
        _currentPage = 2; // ✅ 下一页
        _hasMore = _images.length >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载失败，请重试')));
    }
  }

  Future<void> _loadMoreImages() async {
    if (_isLoading || !_hasMore) return;

    // 从 Provider 获取空间数据
    final spaceState = ref.read(spaceProvider);
    final spaceData = spaceState.space;
    
    if (spaceData == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await PictureApi.getList({
        "current": _currentPage,
        "pageSize": 10,
        "spaceId": spaceData.id,
      });

      setState(() {
        if (res.records != null && res.records!.isNotEmpty) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载更多失败，请重试')));
    }
  }

  void _hideActionOverlay() {
    setState(() {
      _showActionOverlay = false;
      _selectedImageId = null;
    });
  }

  void _showImageActions(String imageId) {
    setState(() {
      _selectedImageId = imageId;
      _showActionOverlay = true;
    });
  }

  Future<void> _deleteImage(String imageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确定要删除这张图片吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _images.removeWhere((image) => image.id == imageId);
      });
      _hideActionOverlay();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片已删除'), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _moveToTrash(String imageId) {
    setState(() {
      final image = _images.firstWhere((img) => img.id == imageId);
      // image.isInTrash= true;
    });
    _hideActionOverlay();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('图片已移至回收站'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: '撤销',
            onPressed: () {
              setState(() {
                final image = _images.firstWhere((img) => img.id == imageId);
                // image.isInTrash = false;
              });
            },
          ),
        ),
      );
    }
  }

  void _shareImage(String imageId) {
    _hideActionOverlay();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中...'), backgroundColor: Colors.blue),
    );
  }

  void _downloadImage(String imageId) {
    _hideActionOverlay();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片下载中...'), backgroundColor: Colors.green),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '未知';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getSpaceLevelName(int level) {
    switch (level) {
      case 0:
        return '普通版';
      case 1:
        return '专业版';
      case 2:
        return '旗舰版';
      default:
        return '未知';
    }
  }

  Color _getSpaceLevelColor(int level) {
    switch (level) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.purple;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '我的空间',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
            onPressed: () async {
              // 从 Provider 获取当前空间数据
              final spaceState = ref.read(spaceProvider);
              final currentSpace = spaceState.space;
              
              if (currentSpace != null) {
                // 传递空间数据到设置页面
                await Navigator.pushNamed(
                  context,
                  '/space_settings',
                  arguments: currentSpace,
                );
                
                // 设置页面会直接更新 Provider，所以这里不需要手动处理返回值
                // Provider 会自动通知所有监听者更新 UI
                
                // 刷新图片列表
                await _loadData();
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_showActionOverlay) {
            _hideActionOverlay();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _currentPage = 1;
              _hasMore = true;
            });
            // 刷新空间数据
            final authState = ref.read(authProvider);
            final user = authState.user;
            if (user != null && user.id != null) {
              await ref.read(spaceProvider.notifier).refresh(user.id!);
            }
            // 刷新图片列表
            await _loadData();
          },
          child: Consumer(
            builder: (context, ref, child) {
              // 监听空间状态变化
              final spaceState = ref.watch(spaceProvider);
              final spaceData = spaceState.space ?? SpaceVO.empty();
              
              double total = double.tryParse(spaceData.totalSize ?? '') ?? 0;
              double max = double.tryParse(spaceData.maxSize ?? '') ?? 1;
              double progress = (max > 0) ? (total / max).clamp(0.0, 1.0) : 0.0;
              
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 空间信息卡片
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 空间标题和级别
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      spaceData.spaceName ?? '未命名空间',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getSpaceLevelColor(
                                              spaceData!.spaceLevel,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getSpaceLevelName(
                                              spaceData!.spaceLevel,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getSpaceLevelColor(
                                                spaceData.spaceLevel,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            (spaceData.spaceType == 0 ||
                                                    spaceData.spaceType == null)
                                                ? '私有'
                                                : '团队',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  spaceData.user.userAvatar ??
                                      'https://picsum.photos/200',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 存储使用情况
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '存储使用情况',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${_formatFileSize(int.tryParse(spaceData.totalSize) ?? 0)} / ${_formatFileSize(int.tryParse(spaceData.maxSize) ?? 0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getSpaceLevelColor(spaceData?.spaceLevel ?? 0),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 统计信息
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  '图片数量',
                                  '${spaceData.totalCount} / ${spaceData.maxCount}',
                                  Icons.photo_library_outlined,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatItem(
                                  '创建时间',
                                  _formatDate(spaceData.createTime),
                                  Icons.calendar_today_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 操作按钮
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UploadPage(spaceId: spaceData.id!),
                                  ),
                                );
                                
                                // 如果上传成功返回，刷新图片列表
                                if (result == true) {
                                  _loadData();
                                }
                              },
                              icon: const Icon(Icons.add_photo_alternate_outlined),
                              label: const Text('上传图片'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // 图片标题
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            '我的图片',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              // 切换视图模式
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('切换视图模式')),
                              );
                            },
                            icon: Icon(
                              Icons.view_module_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            label: Text(
                              '网格',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // 图片瀑布流
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childCount: _images.length,
                      itemBuilder: (context, index) {
                        final image = _images[index];
                        final isSelected = _selectedImageId == image.id;

                        return GestureDetector(
                          onTap: () {
                            if (_showActionOverlay) {
                              _hideActionOverlay();
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: image,
                              );
                            }
                          },
                          onLongPress: () {
                            _showImageActions(image.id);
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          AspectRatio(
                                            aspectRatio:
                                                image.picWidth / image.picHeight,
                                            child: CachedImage(
                                              imageUrl:
                                                  image.thumbnailUrl ?? image.url,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          // 编辑按钮
                                          if (!_showActionOverlay)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  // 跳转到编辑页面并等待返回结果
                                                  final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageEditPage(
                                                        imageData: image,
                                                      ),
                                                    ),
                                                  );
                                                  
                                                  // 如果编辑成功返回，刷新列表中对应的图片数据
                                                  if (result != null && result is Map<String, dynamic>) {
                                                    setState(() {
                                                      // 找到对应的图片并更新数据
                                                      final imageIndex = _images.indexWhere((img) => img.id == result['id']);
                                                      if (imageIndex != -1) {
                                                        _images[imageIndex] = _images[imageIndex].copyWith(
                                                          name: result['name'] ?? _images[imageIndex].name,
                                                          introduction: result['introduction'] ?? _images[imageIndex].introduction,
                                                          category: result['category'] ?? _images[imageIndex].category,
                                                          tags: result['tags'] != null ? List<String>.from(result['tags']) : _images[imageIndex].tags,
                                                        );
                                                      }
                                                    });
                                                    
                                                    // 显示更新成功提示
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('图片信息已更新'),
                                                          backgroundColor: Colors.green,
                                                          duration: Duration(seconds: 2),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(
                                                      0.1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Row(
                                            //   children: [
                                            //     Text(
                                            //       image.picSize,
                                            //       style: TextStyle(
                                            //         fontSize: 12,
                                            //         color: Colors.grey[600],
                                            //       ),
                                            //     ),
                                            //     const Spacer(),
                                            //     Text(
                                            //       image.updateTime.toString(),
                                            //       style: TextStyle(
                                            //         fontSize: 12,
                                            //         color: Colors.grey[500],
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 操作遮罩
                              if (isSelected && _showActionOverlay)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight:
                                              MediaQuery.of(context).size.height *
                                                  0.2,
                                        ),
                                        child: IntrinsicHeight(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 8),
                                              // 操作按钮网格 - 使用更紧凑的布局
                                              Flexible(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  alignment: WrapAlignment.center,
                                                  children: [
                                                    _buildCompactActionButton(
                                                      icon: Icons.share_outlined,
                                                      label: '分享',
                                                      color: Colors.blue,
                                                      onTap: () =>
                                                          _shareImage(image.id),
                                                    ),
                                                    _buildCompactActionButton(
                                                      icon: Icons.download_outlined,
                                                      label: '下载',
                                                      color: Colors.green,
                                                      onTap: () => _downloadImage(
                                                        image.id,
                                                      ),
                                                    ),
                                                    _buildCompactActionButton(
                                                      icon: Icons.delete_outline,
                                                      label: '回收站',
                                                      color: Colors.orange,
                                                      onTap: () => _moveToTrash(
                                                        image.id,
                                                      ),
                                                    ),
                                                    _buildCompactActionButton(
                                                      icon: Icons
                                                          .delete_forever_outlined,
                                                      label: '删除',
                                                      color: Colors.red,
                                                      onTap: () => _deleteImage(
                                                        image.id,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // 取消按钮
                                              GestureDetector(
                                                onTap: _hideActionOverlay,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(
                                                      0.2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '取消',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
                          ? const Center(child: CircularProgressIndicator())
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
