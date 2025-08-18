import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MySpacePage extends StatefulWidget {
  const MySpacePage({super.key});

  @override
  State<MySpacePage> createState() => _MySpacePageState();
}

class _MySpacePageState extends State<MySpacePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  // 模拟空间信息
  final Map<String, dynamic> _spaceInfo = {
    'id': 1,
    'spaceName': '我的摄影作品集',
    'spaceLevel': 1, // 0-普通版 1-专业版 2-旗舰版
    'spaceType': 0, // 0-私有 1-团队
    'maxSize': 107374182400, // 100GB
    'maxCount': 10000,
    'totalSize': 21474836480, // 20GB
    'totalCount': 156,
    'createTime': '2024-01-15',
    'user': {
      'username': '摄影师小王',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
    },
    'permissionList': ['upload', 'edit', 'delete', 'share'],
  };

  // 模拟图片数据
  List<Map<String, dynamic>> _images = [
    {
      'id': '1',
      'url': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'title': '山景风光',
      'size': '2.5MB',
      'uploadTime': '2024-03-15',
      'aspectRatio': 0.8,
    },
    {
      'id': '2',
      'url': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
      'title': '办公空间',
      'size': '1.8MB',
      'uploadTime': '2024-03-14',
      'aspectRatio': 1.2,
    },
    {
      'id': '3',
      'url': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      'title': '自然风光',
      'size': '3.2MB',
      'uploadTime': '2024-03-13',
      'aspectRatio': 1.0,
    },
    {
      'id': '4',
      'url': 'https://images.unsplash.com/photo-1486312338219-ce68e2c6b7d3?w=400',
      'title': '科技办公',
      'size': '2.1MB',
      'uploadTime': '2024-03-12',
      'aspectRatio': 0.9,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreImages();
    }
  }

  Future<void> _loadMoreImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    // 模拟加载更多数据
    List<Map<String, dynamic>> newImages = [
      {
        'id': '${_images.length + 1}',
        'url': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400',
        'title': '城市建筑 ${_images.length + 1}',
        'size': '2.8MB',
        'uploadTime': '2024-03-${10 - (_images.length % 10)}',
        'aspectRatio': 1.3,
      },
      {
        'id': '${_images.length + 2}',
        'url': 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=400',
        'title': '代码界面 ${_images.length + 2}',
        'size': '1.5MB',
        'uploadTime': '2024-03-${9 - (_images.length % 10)}',
        'aspectRatio': 0.7,
      },
    ];

    setState(() {
      _images.addAll(newImages);
      _isLoading = false;
      _currentPage++;
      // 模拟没有更多数据
      if (_currentPage > 5) {
        _hasMore = false;
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _getSpaceLevelName(int level) {
    switch (level) {
      case 0: return '普通版';
      case 1: return '专业版';
      case 2: return '旗舰版';
      default: return '未知';
    }
  }

  Color _getSpaceLevelColor(int level) {
    switch (level) {
      case 0: return Colors.blue;
      case 1: return Colors.purple;
      case 2: return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[800],
          ),
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
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.grey[700],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/space_settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _currentPage = 1;
            _hasMore = true;
          });
          await _loadMoreImages();
        },
        child: CustomScrollView(
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
                                _spaceInfo['spaceName'],
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
                                      color: _getSpaceLevelColor(_spaceInfo['spaceLevel']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getSpaceLevelName(_spaceInfo['spaceLevel']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getSpaceLevelColor(_spaceInfo['spaceLevel']),
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
                                      _spaceInfo['spaceType'] == 0 ? '私有' : '团队',
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
                          backgroundImage: NetworkImage(_spaceInfo['user']['avatar']),
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
                              '${_formatFileSize(_spaceInfo['totalSize'])} / ${_formatFileSize(_spaceInfo['maxSize'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _spaceInfo['totalSize'] / _spaceInfo['maxSize'],
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getSpaceLevelColor(_spaceInfo['spaceLevel']),
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
                            '${_spaceInfo['totalCount']} / ${_spaceInfo['maxCount']}',
                            Icons.photo_library_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            '创建时间',
                            _spaceInfo['createTime'],
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/upload');
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
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create_space');
                      },
                      icon: const Icon(Icons.add_outlined),
                      label: const Text('新建空间'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

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

            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

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
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: {
                          'id': image['id'],
                          'url': image['url'],
                          'title': image['title'],
                          'likes': 0,
                          'category': '我的图片',
                          'aspectRatio': image['aspectRatio'],
                        },
                      );
                    },
                    child: Container(
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
                            AspectRatio(
                              aspectRatio: image['aspectRatio'],
                              child: Image.network(
                                image['url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    image['title'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        image['size'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        image['uploadTime'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
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
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
}