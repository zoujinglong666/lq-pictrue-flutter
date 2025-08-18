import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  int _unreadNotificationCount = 2; // 未读消息数量
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<Map<String, dynamic>> _images = [
    {
      'id': '1',
      'url': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      'title': '美丽的山景风光',
      'likes': 128,
      'category': '风景',
      'aspectRatio': 0.8,
    },
    {
      'id': '2',
      'url': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
      'title': '现代办公空间设计',
      'likes': 89,
      'category': '商务',
      'aspectRatio': 1.2,
    },
    {
      'id': '3',
      'url': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400',
      'title': '自然风光摄影',
      'likes': 256,
      'category': '自然',
      'aspectRatio': 1.0,
    },
    {
      'id': '4',
      'url': 'https://images.unsplash.com/photo-1486312338219-ce68e2c6b7d3?w=400',
      'title': '科技办公环境',
      'likes': 167,
      'category': '科技',
      'aspectRatio': 0.9,
    },
    {
      'id': '5',
      'url': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400',
      'title': '城市建筑景观',
      'likes': 203,
      'category': '建筑',
      'aspectRatio': 1.3,
    },
    {
      'id': '6',
      'url': 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=400',
      'title': '编程代码界面',
      'likes': 145,
      'category': '技术',
      'aspectRatio': 0.7,
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
        'url': 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400',
        'title': '湖泊风景 ${_images.length + 1}',
        'likes': 89 + (_images.length * 10),
        'category': '风景',
        'aspectRatio': 1.1,
      },
      {
        'id': '${_images.length + 2}',
        'url': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400',
        'title': '星空摄影 ${_images.length + 2}',
        'likes': 156 + (_images.length * 8),
        'category': '自然',
        'aspectRatio': 0.75,
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
                    '摄图网',
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
                            Navigator.pushNamed(context, '/notification').then((_) {
                              // 从消息页面返回时，可以更新未读消息数量
                              setState(() {
                                _unreadNotificationCount = 0;
                              });
                            });
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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

            // 瀑布流内容
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _currentPage = 1;
                    _hasMore = true;
                    _images = _images.take(6).toList(); // 重置为初始数据
                  });
                  await _loadMoreImages();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
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
                              );
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
                                      aspectRatio: image['aspectRatio'],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                        ),
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
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.favorite_border_outlined,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                image['likes'].toString(),
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
                                                  image['category'],
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