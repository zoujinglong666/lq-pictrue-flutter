import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/common/toast.dart';
import 'package:lq_picture/model/page.dart';
import 'package:lq_picture/providers/auth_provider.dart';
import 'package:lq_picture/utils/keyboard_utils.dart';
import '../widgets/paginated_list_widget.dart';

class SpaceManagementPageNew extends ConsumerStatefulWidget {
  const SpaceManagementPageNew({super.key});

  @override
  ConsumerState<SpaceManagementPageNew> createState() => _SpaceManagementPageNewState();
}

class _SpaceManagementPageNewState extends ConsumerState<SpaceManagementPageNew> with KeyboardDismissMixin {

  // API调用函数
  Future<Page<SpaceItem>> _loadSpaces(Map<String, dynamic> params) async {
    return await SpaceApi.getSpaceListPage(params);
  }

  // 自定义搜索参数构建器
  Map<String, dynamic> _buildSearchParams(String searchText, Map<String, String> filterValues) {
    final params = <String, dynamic>{};
    
    // 添加搜索条件
    if (searchText.isNotEmpty) {
      params['searchText'] = searchText;
    }
    
    // 添加级别筛选
    final level = filterValues['spaceLevel'];
    if (level != null && level != '全部') {
      int levelValue = 0;
      switch (level) {
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
      params['spaceLevel'] = levelValue;
    }
    
    return params;
  }

  // 列表项构建器
  Widget _buildSpaceItem(BuildContext context, SpaceItem space, int index) {
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
                  child: _buildUsageInfo('容量使用', sizeUsage, 
                    '${_formatFileSize(int.parse(space.totalSize))} / ${_formatFileSize(int.parse(space.maxSize))}'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildUsageInfo('图片数量', countUsage, 
                    '${space.totalCount} / ${space.maxCount}张'),
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
  }

  Widget _buildUsageInfo(String title, double usage, String detail) {
    Color usageColor = usage > 90 ? Colors.red : usage > 70 ? Colors.orange : Colors.green;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${usage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: usageColor,
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
            widthFactor: usage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: usageColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showSpaceDetail(SpaceItem space) {
    // 详情弹窗实现...
    MyToast.showSuccess('查看空间详情: ${space.spaceName}');
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 0: return Colors.grey;
      case 1: return Colors.blue;
      case 2: return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _getLevelText(int level) {
    switch (level) {
      case 0: return '普通版';
      case 1: return '专业版';
      case 2: return '旗舰版';
      default: return '未知';
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
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
      body: PaginatedListWidget<SpaceItem>(
        apiCall: _loadSpaces,
        itemBuilder: _buildSpaceItem,
        searchHint: '搜索空间名称...',
        searchParamsBuilder: _buildSearchParams,
        filters: [
          FilterConfig(
            key: 'spaceLevel',
            hint: '空间级别',
            options: ['全部', '普通版', '专业版', '旗舰版'],
          ),
        ],
        emptyWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storage_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '暂无空间数据',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '请尝试调整搜索条件',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}