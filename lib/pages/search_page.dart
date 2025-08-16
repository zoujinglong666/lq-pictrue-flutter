import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ['风景', '人像摄影', '城市建筑', '自然'];
  final List<String> _popularTags = ['风景', '人像', '城市', '自然', '黑白', '街拍', '建筑', '美食', '旅行', '动物'];
  
  // 过滤选项
  bool _showFilters = false;
  String _selectedCategory = '全部';
  String _selectedSort = '最新';
  String _selectedLicense = '全部';
  
  final List<String> _categories = ['全部', '风景', '人物', '动物', '建筑', '美食'];
  final List<String> _sortOptions = ['最新', '热门', '推荐'];
  final List<String> _licenseOptions = ['全部', '免费', '付费', '编辑精选'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 搜索头部
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.95),
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索高质量图片...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF4FC3F7)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                          color: _showFilters ? const Color(0xFF4FC3F7) : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (value) {
                      // 处理搜索
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // 过滤器部分
          if (_showFilters)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '过滤选项',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
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
                    
                    // 许可选择
                    _buildFilterSection('许可', _licenseOptions, _selectedLicense, (value) {
                      setState(() {
                        _selectedLicense = value;
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7),
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
            ),
          
          // 最近搜索
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '最近搜索',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 清除最近搜索
                        },
                        child: const Text(
                          '清除',
                          style: TextStyle(
                            color: Color(0xFF4FC3F7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentSearches.map((search) {
                      return Chip(
                        label: Text(search),
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(color: Colors.grey.shade300),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          // 删除搜索记录
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          // 热门标签
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '热门标签',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularTags.map((tag) {
                      return ActionChip(
                        label: Text(tag),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        onPressed: () {
                          _searchController.text = tag;
                          // 执行搜索
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}