import 'package:flutter/material.dart';

class SpaceSettingsPage extends StatefulWidget {
  const SpaceSettingsPage({super.key});

  @override
  State<SpaceSettingsPage> createState() => _SpaceSettingsPageState();
}

class _SpaceSettingsPageState extends State<SpaceSettingsPage> {
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
  };

  final _spaceNameController = TextEditingController();
  bool _isPrivate = true;
  bool _allowDownload = true;
  bool _allowShare = true;
  bool _enableWatermark = false;

  @override
  void initState() {
    super.initState();
    _spaceNameController.text = _spaceInfo['spaceName'];
    _isPrivate = _spaceInfo['spaceType'] == 0;
  }

  @override
  void dispose() {
    _spaceNameController.dispose();
    super.dispose();
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
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
          '空间设置',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 保存设置
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置已保存')),
              );
              Navigator.pop(context);
            },
            child: Text(
              '保存',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            _buildSectionCard(
              '基本信息',
              [
                _buildTextFieldItem(
                  '空间名称',
                  _spaceNameController,
                  '请输入空间名称',
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '空间级别',
                  _getSpaceLevelName(_spaceInfo['spaceLevel']),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSpaceLevelColor(_spaceInfo['spaceLevel']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '升级',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSpaceLevelColor(_spaceInfo['spaceLevel']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('跳转到升级页面')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '创建时间',
                  _spaceInfo['createTime'],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 存储信息
            _buildSectionCard(
              '存储信息',
              [
                _buildStorageItem(
                  '已用存储',
                  '${_formatFileSize(_spaceInfo['totalSize'])} / ${_formatFileSize(_spaceInfo['maxSize'])}',
                  _spaceInfo['totalSize'] / _spaceInfo['maxSize'],
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '图片数量',
                  '${_spaceInfo['totalCount']} / ${_spaceInfo['maxCount']}',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 隐私设置
            _buildSectionCard(
              '隐私设置',
              [
                _buildSwitchItem(
                  '私有空间',
                  '开启后只有你可以查看空间内容',
                  _isPrivate,
                  (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSwitchItem(
                  '允许下载',
                  '允许其他用户下载空间内的图片',
                  _allowDownload,
                  (value) {
                    setState(() {
                      _allowDownload = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSwitchItem(
                  '允许分享',
                  '允许其他用户分享空间内的图片',
                  _allowShare,
                  (value) {
                    setState(() {
                      _allowShare = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSwitchItem(
                  '启用水印',
                  '为空间内的图片自动添加水印',
                  _enableWatermark,
                  (value) {
                    setState(() {
                      _enableWatermark = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 管理操作
            _buildSectionCard(
              '管理操作',
              [
                _buildActionItem(
                  '清理缓存',
                  '清理空间缓存文件',
                  Icons.cleaning_services_outlined,
                  Colors.blue,
                  () {
                    _showConfirmDialog(
                      '清理缓存',
                      '确定要清理空间缓存吗？这将释放一些存储空间。',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('缓存清理完成')),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionItem(
                  '导出数据',
                  '导出空间内的所有图片数据',
                  Icons.download_outlined,
                  Colors.green,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('开始导出数据...')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionItem(
                  '删除空间',
                  '永久删除此空间及其所有内容',
                  Icons.delete_outline,
                  Colors.red,
                  () {
                    _showConfirmDialog(
                      '删除空间',
                      '确定要删除此空间吗？此操作不可恢复，所有图片和数据将被永久删除。',
                      () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('空间已删除')),
                        );
                      },
                      isDestructive: true,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFieldItem(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue[600],
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm, {bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}