import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/common/toast.dart';
import 'package:lq_picture/model/page.dart';
import 'package:lq_picture/providers/auth_provider.dart';
import 'package:lq_picture/utils/keyboard_utils.dart';
import '../widgets/pagination_widget.dart';

class SpaceManagementPage extends ConsumerStatefulWidget {
  const SpaceManagementPage({super.key});

  @override
  ConsumerState<SpaceManagementPage> createState() => _SpaceManagementPageState();
}

class _SpaceManagementPageState extends ConsumerState<SpaceManagementPage> with KeyboardDismissMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = '全部';
  List<SpaceItem> _spaces = [];
  List<SpaceItem> _filteredSpaces = [];
  bool _isLoading = false;
  
  // 分页相关
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 1;
  int _totalRecords = 0;
  Page<SpaceItem>? _pageData;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
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

  Future<void> _loadSpaces({int? page}) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requestData = {
        'current': page ?? _currentPage,
        'pageSize': _pageSize,
      } as Map<String, dynamic>;
      
      // 添加搜索条件
      if (_searchController.text.isNotEmpty) {
        requestData['searchText'] = _searchController.text;
      }
      
      // 添加级别筛选
      if (_selectedLevel != '全部') {
        int levelValue = 0;
        switch (_selectedLevel) {
          case '普通版':
            levelValue = 0;
            break;
          case '专业版':
            levelValue = 1;
            break;
          case '旗舰版':
            levelValue = 2;
            break;
        }
        requestData['spaceLevel'] = levelValue;
      }
      
      final res = await SpaceApi.getSpaceListPage(requestData);
      
      setState(() {
        _pageData = res;
        _spaces = res.records;
        _filteredSpaces = List.from(_spaces);
        _currentPage = _toInt(res.current);
        _totalPages = _toInt(res.pages);
        _totalRecords = _toInt(res.total);
      });
    } catch (e) {
      print('加载空间失败: $e');
      if (mounted) {
        MyToast.showError('加载空间失败: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSpaces() {
    // 重新加载第一页数据
    _currentPage = 1;
    _loadSpaces(page: 1);
  }
  
  void _onPageChanged(int page) {
    _loadSpaces(page: page);
  }

  void _showSpaceDetail(SpaceItem space) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.storage,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '空间详情',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基本信息
                      _buildDetailSection('基本信息', [
                        _buildDetailItem(Icons.folder_outlined, '空间名称', space.spaceName),
                        _buildDetailItem(
                          _getLevelIcon(space.spaceLevel),
                          '空间级别',
                          _getLevelText(space.spaceLevel),
                          statusColor: _getLevelColor(space.spaceLevel),
                        ),
                        _buildDetailItem(Icons.access_time, '创建时间', _formatDateTime(space.createTime)),
                      ]),
                      const SizedBox(height: 20),
                      // 容量信息
                      _buildDetailSection('容量信息', [
                        _buildDetailItem(Icons.cloud_outlined, '最大容量', _formatFileSize(int.parse(space.maxSize))),
                        _buildDetailItem(Icons.storage_outlined, '已用容量', _formatFileSize(int.parse(space.totalSize))),
                        _buildDetailItem(Icons.photo_outlined, '最大图片数', '${space.maxCount}张'),
                        _buildDetailItem(Icons.collections_outlined, '当前图片数', '${space.totalCount}张'),
                      ]),
                      const SizedBox(height: 20),
                      // 使用率统计
                      _buildDetailSection('使用率统计', [
                        _buildUsageBar('容量使用率', double.parse(space.totalSize), double.parse(space.maxSize)),
                        const SizedBox(height: 16),
                        _buildUsageBar('图片数量使用率', double.parse(space.totalCount), double.parse(space.maxCount)),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: statusColor ?? Colors.grey[600],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: statusColor ?? Colors.grey[800],
                fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(String title, double current, double max) {
    double percentage = max > 0 ? (current / max * 100).clamp(0, 100) : 0;
    Color barColor = percentage > 90 ? Colors.red : percentage > 70 ? Colors.orange : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 0:
        return Icons.star_border;
      case 1:
        return Icons.star_half;
      case 2:
        return Icons.star;
      default:
        return Icons.help_outline;
    }
  }

  String _getLevelText(int level) {
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

  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
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
          '空间管理',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '管理员',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选区域
          Container(
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
                      hintText: '搜索空间名称...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search_outlined, color: Colors.grey[600], size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterSpaces();
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
                          _filterSpaces();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // 级别筛选器
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLevel,
                      isExpanded: true,
                      hint: const Text('空间级别'),
                      items: ['全部', '普通版', '专业版', '旗舰版']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                        });
                        _filterSpaces();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 空间列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSpaces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storage_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无空间数据',
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
                      )
                    : Column(
                        children: [
                          // 分页信息
                          if (_totalRecords > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '共 $_totalRecords 个空间',
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
                            ),
                          // 空间列表
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredSpaces.length,
                              itemBuilder: (context, index) {
                                final space = _filteredSpaces[index];
                                double sizeUsage = double.parse(space.maxSize) > 0 
                                    ? (double.parse(space.totalSize) / double.parse(space.maxSize) * 100).clamp(0, 100) 
                                    : 0;
                                double countUsage = double.parse(space.maxCount) > 0 
                                    ? (double.parse(space.totalCount) / double.parse(space.maxCount) * 100).clamp(0, 100) 
                                    : 0;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 标题行
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _getLevelColor(space.spaceLevel).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.storage,
                                                color: _getLevelColor(space.spaceLevel),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    space.spaceName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: _getLevelColor(space.spaceLevel).withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          _getLevelText(space.spaceLevel),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: _getLevelColor(space.spaceLevel),
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => _showSpaceDetail(space),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                side: BorderSide(color: Colors.grey[300]!),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                '详情',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // 使用率信息
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '容量使用',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                      Text(
                                                        '${sizeUsage.toStringAsFixed(1)}%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: sizeUsage > 90 ? Colors.red : sizeUsage > 70 ? Colors.orange : Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: FractionallySizedBox(
                                                      alignment: Alignment.centerLeft,
                                                      widthFactor: sizeUsage / 100,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: sizeUsage > 90 ? Colors.red : sizeUsage > 70 ? Colors.orange : Colors.green,
                                                          borderRadius: BorderRadius.circular(2),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${_formatFileSize(int.parse(space.totalSize))} / ${_formatFileSize(int.parse(space.maxSize))}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '图片数量',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                      Text(
                                                        '${countUsage.toStringAsFixed(1)}%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: countUsage > 90 ? Colors.red : countUsage > 70 ? Colors.orange : Colors.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: FractionallySizedBox(
                                                      alignment: Alignment.centerLeft,
                                                      widthFactor: countUsage / 100,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: countUsage > 90 ? Colors.red : countUsage > 70 ? Colors.orange : Colors.green,
                                                          borderRadius: BorderRadius.circular(2),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${space.totalCount} / ${space.maxCount}张',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // 创建时间
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '创建于 ${_formatDateTime(space.createTime)}',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
      ),
    );
  }
}