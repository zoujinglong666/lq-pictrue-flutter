import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../apis/picture_api.dart';
import '../model/picture.dart';
import '../widgets/cached_image.dart';
import '../utils/keyboard_utils.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with KeyboardDismissMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<PictureVO> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _hasMore = true;
  int _currentPage = 1;
  
  // 过滤选项
  bool _showFilters = false;
  String _selectedCategory = '全部';
  String _selectedSort = '最新';
  
  final List<String> _categories = ['全部', '模板', '电商', '表情包', '素材', '海报'];
  final List<String> _sortOptions = ['最新', '热门'];
  
  // 热门标签示例
  final List<String> _popularTags = ['风景', '人像', '城市', '自然', '黑白', '街拍', '建筑', '美食', '旅行', '动物'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 自动聚焦搜索框
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreResults();
    }
  }
  
  // 执行搜索
  Future<void> _performSearch({bool loadMore = false}) async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;
    
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _hasSearched = true;
        _currentPage = 1;
        _searchResults = [];
      });
    } else {
      if (_isLoading || !_hasMore) return;
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final params = <String, dynamic>{
        'current': loadMore ? _currentPage : 1,
        'pageSize': 20,
        'searchText': keyword,
        'sortField': _selectedSort == '热门' ? 'likeCount' : 'createTime',
        'sortOrder': 'descend',
      };
      
      if (_selectedCategory != '全部') {
        params['category'] = _selectedCategory;
      }
      
      final res = await PictureApi.getList(params);
      
      setState(() {
        if (loadMore) {
          _searchResults.addAll(res.records ?? []);
        } else {
          _searchResults = res.records ?? [];
        }
        _currentPage = loadMore ? _currentPage + 1 : 2;
        _hasMore = (res.records?.length ?? 0) >= 20;
        _isLoading = false;
      });
      
      _searchFocusNode.unfocus();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }
  
  Future<void> _loadMoreResults() async {
    await _performSearch(loadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
      body: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Container(
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
                hintText: '搜索高质量图片...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _hasSearched = false;
                            _searchResults = [];
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                          color: _showFilters ? const Color(0xFF00BCD4) : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                setState(() {}); // 更新UI
              },
            ),
          ),
        ),
        body: Column(
          children: [
            // 过滤器部分
            if (_showFilters)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类选择
                    _buildFilterSection('分类', _categories, _selectedCategory, (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }),
                    
                    const SizedBox(height: 16),
                    
                    // 排序选择
                    _buildFilterSection('排序', _sortOptions, _selectedSort, (value) {
                      setState(() {
                        _selectedSort = value;
                      });
                    }),
                    
                    const SizedBox(height: 16),
                    
                    // 应用按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = false;
                          });
                          _performSearch();
                        },
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
            
            // 主内容区域
            Expanded(
              child: _hasSearched
                  ? _buildSearchResults()
                  : _buildSearchSuggestions(),
            ),
          ],
        ),
      ),
    );
  }
  
  // 搜索结果
  Widget _buildSearchResults() {
    if (_isLoading && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '没有找到相关图片',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词或调整筛选条件',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Text(
              '找到 ${_searchResults.length} 个结果',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childCount: _searchResults.length,
            itemBuilder: (context, index) {
              final image = _searchResults[index];
              return _buildImageCard(image);
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasMore
                    ? Center(
                        child: Text(
                          '没有更多图片了',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
  
  // 搜索建议（未搜索时显示）
  Widget _buildSearchSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '热门标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularTags.map((tag) {
            return ActionChip(
              label: Text(tag),
              backgroundColor: Colors.grey[100],
              side: BorderSide(color: Colors.grey.shade300),
              onPressed: () {
                _searchController.text = tag;
                _performSearch();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          '搜索提示',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildSearchTips(),
      ],
    );
  }
  
  List<Widget> _buildSearchTips() {
    final tips = [
      '输入关键词搜索图片',
      '使用筛选器缩小搜索范围',
      '尝试点击热门标签快速搜索',
    ];
    
    return tips.map((tip) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              tip,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }
  
  // 图片卡片
  Widget _buildImageCard(PictureVO image) {
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
                aspectRatio: image.picWidth / image.picHeight,
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
                          image.hasLiked
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
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
  }
  
  Widget _buildFilterSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF4FC3F7),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}