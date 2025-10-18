import 'package:flutter/material.dart' hide Page;
import '../model/page.dart';
import '../utils/keyboard_utils.dart';
import 'pagination_widget.dart';

/// 通用分页列表组件
/// T: 数据项类型
class PaginatedListWidget<T> extends StatefulWidget {
  /// API调用函数，传入请求参数，返回分页数据
  final Future<Page<T>> Function(Map<String, dynamic> params) apiCall;
  
  /// 列表项构建器
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// 搜索框提示文本
  final String searchHint;
  
  /// 筛选器配置
  final List<FilterConfig>? filters;
  
  /// 每页大小
  final int pageSize;
  
  /// 空状态显示
  final Widget? emptyWidget;
  
  /// 加载状态显示
  final Widget? loadingWidget;
  
  /// 额外的搜索参数构建器
  final Map<String, dynamic> Function(String searchText, Map<String, String> filterValues)? searchParamsBuilder;

  const PaginatedListWidget({
    super.key,
    required this.apiCall,
    required this.itemBuilder,
    required this.searchHint,
    this.filters,
    this.pageSize = 10,
    this.emptyWidget,
    this.loadingWidget,
    this.searchParamsBuilder,
  });

  @override
  State<PaginatedListWidget<T>> createState() => _PaginatedListWidgetState<T>();
}

class _PaginatedListWidgetState<T> extends State<PaginatedListWidget<T>> with KeyboardDismissMixin {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _filterValues = {};
  
  List<T> _items = [];
  bool _isLoading = false;
  
  // 分页相关
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  Page<T>? _pageData;

  @override
  void initState() {
    super.initState();
    // 初始化筛选器默认值
    if (widget.filters != null) {
      for (final filter in widget.filters!) {
        _filterValues[filter.key] = filter.defaultValue;
      }
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _loadData({int? page}) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requestData = {
        'current': page ?? _currentPage,
        'pageSize': widget.pageSize,
      } as Map<String, dynamic>;
      
      // 使用自定义搜索参数构建器或默认实现
      if (widget.searchParamsBuilder != null) {
        final customParams = widget.searchParamsBuilder!(_searchController.text, _filterValues);
        requestData.addAll(customParams);
      } else {
        // 默认搜索参数
        if (_searchController.text.isNotEmpty) {
          requestData['searchText'] = _searchController.text;
        }
        
        // 添加筛选参数
        _filterValues.forEach((key, value) {
          if (value != '全部' && value.isNotEmpty) {
            requestData[key] = value;
          }
        });
      }
      
      final res = await widget.apiCall(requestData);
      
      setState(() {
        _pageData = res;
        _items = res.records;
        _currentPage = _toInt(res.current);
        _totalPages = _toInt(res.pages);
        _totalRecords = _toInt(res.total);
      });
    } catch (e) {
      print('加载数据失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    _currentPage = 1;
    _loadData(page: 1);
  }
  
  void _onPageChanged(int page) {
    _loadData(page: page);
  }

  Widget _buildSearchAndFilter() {
    return Container(
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
          const Text(
            '搜索与筛选',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // 搜索框
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search_outlined, color: Colors.grey[600], size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
                // 延迟执行搜索，避免频繁请求
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _onSearch();
                  }
                });
              },
            ),
          ),
          // 筛选器
          if (widget.filters != null && widget.filters!.isNotEmpty) ...[
            const SizedBox(height: 16),
            if (widget.filters!.length == 1)
              // 单个筛选器
              _buildSingleFilter(widget.filters!.first)
            else
              // 多个筛选器
              Row(
                children: widget.filters!.map((filter) {
                  final index = widget.filters!.indexOf(filter);
                  return Expanded(
                    child: Row(
                      children: [
                        if (index > 0) const SizedBox(width: 12),
                        Expanded(child: _buildSingleFilter(filter)),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleFilter(FilterConfig filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterValues[filter.key],
          isExpanded: true,
          hint: Text(filter.hint),
          items: filter.options
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _filterValues[filter.key] = value!;
            });
            _onSearch();
          },
        ),
      ),
    );
  }

  Widget _buildPaginationInfo() {
    if (_totalRecords == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '共 $_totalRecords 条记录',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '第 $_currentPage/$_totalPages 页',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索和筛选区域
        _buildSearchAndFilter(),
        
        // 列表内容
        Expanded(
          child: _isLoading
              ? (widget.loadingWidget ?? const Center(child: CircularProgressIndicator()))
              : _items.isEmpty
                  ? (widget.emptyWidget ?? _buildDefaultEmptyWidget())
                  : Column(
                      children: [
                        // 分页信息
                        _buildPaginationInfo(),
                        
                        // 列表
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              return widget.itemBuilder(context, _items[index], index);
                            },
                          ),
                        ),
                        
                        // 分页组件
                        if (_totalPages > 1)
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: PaginationWidget(
                              currentPage: _currentPage,
                              totalPages: _totalPages,
                              onPageChanged: _onPageChanged,
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildDefaultEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试调整搜索条件',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// 筛选器配置
class FilterConfig {
  final String key;
  final String hint;
  final List<String> options;
  final String defaultValue;

  const FilterConfig({
    required this.key,
    required this.hint,
    required this.options,
    this.defaultValue = '全部',
  });
}