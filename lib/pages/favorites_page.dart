import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lq_picture/apis/picture_api.dart';

import '../model/picture.dart';
import '../widgets/cached_image.dart';
import '../widgets/shimmer_effect.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;
  double _scrollOffset = 0;
  bool _isLoading = true;

  // 模拟收藏数据
  late List<PictureVO> _favoriteImages = [];

  final List<String> _categories = ['全部', '风景', '城市', '动物', '美食', '建筑', '人像'];
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    getFavoriteImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _scrollOffset = offset;
      _isAppBarVisible = offset < 100;
    });
  }

  Future getFavoriteImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await PictureApi.getMyLikes({
        "current": 1,
        "pageSize": 10,
        "sortField": 'createTime',
        "sortOrder": 'descend',
      });

      setState(() {
        _favoriteImages = res.records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PictureVO> get _filteredImages {
    if (_selectedCategory == '全部') {
      return _favoriteImages;
    }
    return _favoriteImages
        .where((image) => image.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 自定义 AppBar
            _buildCustomAppBar(isDark),
            
            // 分类标签栏
            _buildCategoryTabs(isDark),
            
            // 内容区域
            Expanded(
              child: _isLoading
                  ? _buildSkeletonGrid(isDark)
                  : _filteredImages.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildImageGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A1F3A).withOpacity(0.8),
                  const Color(0xFF0A0E21).withOpacity(0.8),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFF8F9FA).withOpacity(0.9),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : Colors.grey[800],
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD89B9B), Color(0xFFC88A8A)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '我的收藏',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${_favoriteImages.length} 张精选图片',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDark ? Colors.white : Colors.grey[700],
                size: 22,
              ),
              onPressed: _showMoreOptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A1F3A).withOpacity(0.5),
                  const Color(0xFF0A0E21).withOpacity(0.5),
                ]
              : [
                  Colors.white.withOpacity(0.7),
                  const Color(0xFFF8F9FA).withOpacity(0.7),
                ],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFD89B9B), Color(0xFFC88A8A)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD89B9B)
                      : isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD89B9B).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD89B9B).withOpacity(0.2),
                  const Color(0xFFD89B9B).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: const Color(0xFFD89B9B),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无收藏',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去收藏你喜欢的图片吧',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // 底部留白避免被导航栏遮挡
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _filteredImages.length,
        itemBuilder: (context, index) {
          final image = _filteredImages[index];
          return _buildImageCard(image, index, isDark);
        },
      ),
    );
  }

  Widget _buildImageCard(PictureVO image, int index, bool isDark) {
    return GestureDetector(
      onTap: () => _openImageDetail(image, index),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFFD89B9B).withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片容器
              AspectRatio(
                aspectRatio: image.picWidth / image.picHeight,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[100]!,
                            Colors.grey[50]!,
                          ],
                        ),
                      ),
                      child: CachedImage(
                        fit: BoxFit.cover,
                        imageUrl: image.thumbnailUrl,
                      ),
                    ),
                    // 顶部渐变遮罩
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 收藏标记
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(image),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red[400],
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 信息栏
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ]
                        : [
                            Colors.white,
                            Colors.grey[50]!,
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: 0.2,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                image.likeCount,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
  }

  double _getRandomHeight(int index) {
    final heights = [200.0, 250.0, 300.0, 350.0, 280.0, 320.0, 260.0, 380.0];
    return heights[index % heights.length];
  }

  void _toggleFavorite(PictureVO image) {
    setState(() {
      image.hasLiked = !image.hasLiked;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          image.hasLiked ? '已添加到收藏' : '已取消收藏',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _openImageDetail(PictureVO image, int index) {
    Navigator.pushNamed(
      context,
      '/detail',
      arguments: image,
    );
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1F3A).withOpacity(0.98),
                    const Color(0xFF0A0E21).withOpacity(0.98),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8F9FA),
                  ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('排序方式'),
              onTap: () {
                Navigator.pop(context);
                _showSortOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('批量下载'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('批量下载功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('清空收藏'),
              onTap: () {
                Navigator.pop(context);
                _showClearConfirmDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('排序方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('收藏时间'),
              leading: Radio(value: 0, groupValue: 0, onChanged: (v) {}),
            ),
            ListTile(
              title: const Text('点赞数量'),
              leading: Radio(value: 1, groupValue: 0, onChanged: (v) {}),
            ),
            ListTile(
              title: const Text('图片大小'),
              leading: Radio(value: 2, groupValue: 0, onChanged: (v) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空收藏'),
        content: const Text('确定要清空所有收藏的图片吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _favoriteImages.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已清空收藏')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 骨架屏网格
  Widget _buildSkeletonGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildSkeletonCard(isDark);
        },
      ),
    );
  }

  // 单个骨架屏卡片
  Widget _buildSkeletonCard(bool isDark) {
    final heights = [200.0, 250.0, 300.0, 350.0, 280.0, 320.0];
    final randomHeight = heights[DateTime.now().millisecond % heights.length];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片骨架
            ShimmerEffect(
              baseColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFFE0E0E0),
              highlightColor: isDark
                  ? Colors.white.withOpacity(0.15)
                  : const Color(0xFFF5F5F5),
              child: Container(
                height: randomHeight,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[300],
                ),
              ),
            ),
            // 信息栏骨架
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题骨架
                  ShimmerEffect(
                    baseColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE0E0E0),
                    highlightColor: isDark
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFF5F5F5),
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShimmerEffect(
                    baseColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE0E0E0),
                    highlightColor: isDark
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFF5F5F5),
                    child: Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 点赞数骨架
                  ShimmerEffect(
                    baseColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE0E0E0),
                    highlightColor: isDark
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFF5F5F5),
                    child: Container(
                      height: 24,
                      width: 60,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
