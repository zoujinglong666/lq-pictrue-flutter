import 'package:flutter/material.dart';

class SpaceManagementPage extends StatefulWidget {
  const SpaceManagementPage({super.key});

  @override
  State<SpaceManagementPage> createState() => _SpaceManagementPageState();
}

class _SpaceManagementPageState extends State<SpaceManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = '全部';
  List<SpaceItem> _spaces = [];
  List<SpaceItem> _filteredSpaces = [];
  bool _isLoading = false;

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

  Future<void> _loadSpaces() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    // 模拟数据
    _spaces = [
      SpaceItem(
        id: 1,
        spaceName: '风景摄影空间',
        spaceLevel: 0,
        maxSize: 1073741824, // 1GB
        maxCount: 1000,
        totalSize: 536870912, // 512MB
        totalCount: 256,
        userId: 1001,
        userName: '张三',
        createTime: DateTime.now().subtract(const Duration(days: 30)),
      ),
      SpaceItem(
        id: 2,
        spaceName: '人像摄影工作室',
        spaceLevel: 1,
        maxSize: 5368709120, // 5GB
        maxCount: 5000,
        totalSize: 2684354560, // 2.5GB
        totalCount: 1200,
        userId: 1002,
        userName: '李四',
        createTime: DateTime.now().subtract(const Duration(days: 15)),
      ),
      SpaceItem(
        id: 3,
        spaceName: '商业摄影空间',
        spaceLevel: 2,
        maxSize: 21474836480, // 20GB
        maxCount: 20000,
        totalSize: 10737418240, // 10GB
        totalCount: 5600,
        userId: 1003,
        userName: '王五',
        createTime: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SpaceItem(
        id: 4,
        spaceName: '个人相册',
        spaceLevel: 0,
        maxSize: 1073741824, // 1GB
        maxCount: 1000,
        totalSize: 858993459, // 819MB
        totalCount: 890,
        userId: 1004,
        userName: '赵六',
        createTime: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    _filteredSpaces = List.from(_spaces);

    setState(() {
      _isLoading = false;
    });
  }

  void _filterSpaces() {
    setState(() {
      _filteredSpaces = _spaces.where((space) {
        bool matchesSearch = _searchController.text.isEmpty ||
            space.spaceName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            space.userName.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesLevel = _selectedLevel == '全部' ||
            (_selectedLevel == '普通版' && space.spaceLevel == 0) ||
            (_selectedLevel == '专业版' && space.spaceLevel == 1) ||
            (_selectedLevel == '旗舰版' && space.spaceLevel == 2);

        return matchesSearch && matchesLevel;
      }).toList();
    });
  }

  void _showSpaceDetail(SpaceItem space) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
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
                        _buildDetailItem(Icons.person_outline, '创建用户', space.userName),
                        _buildDetailItem(Icons.access_time, '创建时间', _formatDateTime(space.createTime)),
                      ]),
                      const SizedBox(height: 20),
                      // 容量信息
                      _buildDetailSection('容量信息', [
                        _buildDetailItem(Icons.cloud_outlined, '最大容量', _formatFileSize(space.maxSize)),
                        _buildDetailItem(Icons.storage_outlined, '已用容量', _formatFileSize(space.totalSize)),
                        _buildDetailItem(Icons.photo_outlined, '最大图片数', '${space.maxCount}张'),
                        _buildDetailItem(Icons.collections_outlined, '当前图片数', '${space.totalCount}张'),
                      ]),
                      const SizedBox(height: 20),
                      // 使用率统计
                      _buildDetailSection('使用率统计', [
                        _buildUsageBar('容量使用率', space.totalSize.toDouble(), space.maxSize.toDouble()),
                        const SizedBox(height: 16),
                        _buildUsageBar('图片数量使用率', space.totalCount.toDouble(), space.maxCount.toDouble()),
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
    double percentage = (current / max * 100).clamp(0, 100);
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
                      hintText: '搜索空间名称或用户名...',
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
                      _filterSpaces();
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
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredSpaces.length,
                        itemBuilder: (context, index) {
                          final space = _filteredSpaces[index];
                          double sizeUsage = (space.totalSize / space.maxSize * 100).clamp(0, 100);
                          double countUsage = (space.totalCount / space.maxCount * 100).clamp(0, 100);
                          
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
                                                Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  space.userName,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
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
                                              '${_formatFileSize(space.totalSize)} / ${_formatFileSize(space.maxSize)}',
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
        ],
      ),
    );
  }
}

class SpaceItem {
  final int id;
  final String spaceName;
  final int spaceLevel; // 0-普通版, 1-专业版, 2-旗舰版
  final int maxSize;
  final int maxCount;
  final int totalSize;
  final int totalCount;
  final int userId;
  final String userName;
  final DateTime createTime;

  SpaceItem({
    required this.id,
    required this.spaceName,
    required this.spaceLevel,
    required this.maxSize,
    required this.maxCount,
    required this.totalSize,
    required this.totalCount,
    required this.userId,
    required this.userName,
    required this.createTime,
  });
}