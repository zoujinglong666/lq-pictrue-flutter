import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lq_picture/apis/picture_api.dart';

import '../model/picture.dart';

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
    final res = await PictureApi.getMyLikes({
      "current": 1,
      "pageSize": 10,
      "sortField": 'createTime',
      "sortOrder": 'descend',
    });

    setState(() {
      _favoriteImages = res.records;
    });
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 自定义AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // 搜索功能
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  _showMoreOptions();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: _scrollOffset > 50 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Text(
                  '我的收藏',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '我的收藏',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_favoriteImages.length} 张图片',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 分类标签栏
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabDelegate(
              tabController: _tabController,
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),

          // 瀑布流图片网格
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: _filteredImages.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无收藏',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childCount: _filteredImages.length,
                    itemBuilder: (context, index) {
                      final image = _filteredImages[index];
                      return _buildImageCard(image, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(PictureVO image, int index) {
    return GestureDetector(
      onTap: () => _openImageDetail(image, index),
      child: Hero(
        tag: 'favorite_image_${image.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // 图片
                Container(
                  width: double.infinity,
                  height: _getRandomHeight(index),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    image: DecorationImage(
                      image: NetworkImage(image.url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 渐变遮罩
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // 图片信息
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              image.user.userName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.red[400],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                image.likeCount,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 收藏按钮
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(image),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        image.hasLiked ? Icons.favorite : Icons.favorite_border,
                        color: image.hasLiked ? Colors.red[400] : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FavoriteImageDetailPage(
          image: image,
          images: _filteredImages,
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
}

// 分类标签栏代理
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  _CategoryTabDelegate({
    required this.tabController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      color: Colors.black,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          onCategoryChanged(categories[index]);
        },
        tabs: categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  @override
  double get maxExtent => 48.0;

  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

// 收藏图片详情页面
class FavoriteImageDetailPage extends StatefulWidget {
  final PictureVO image;
  final List<PictureVO> images;
  final int initialIndex;

  const FavoriteImageDetailPage({
    super.key,
    required this.image,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FavoriteImageDetailPage> createState() =>
      _FavoriteImageDetailPageState();
}

class _FavoriteImageDetailPageState extends State<FavoriteImageDetailPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片浏览器
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return Hero(
                tag: 'favorite_image_${image.id}',
                child: InteractiveViewer(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(image.url),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 顶部工具栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        _showImageOptions();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部信息栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.images[_currentIndex].name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '作者: ${widget.images[_currentIndex].user.userName}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red[400],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.images[_currentIndex].likeCount,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              leading: const Icon(Icons.download),
              title: const Text('下载图片'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('开始下载图片...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享图片'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('分享功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('取消收藏'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已取消收藏')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
