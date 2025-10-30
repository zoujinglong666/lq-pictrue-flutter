import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/providers/space_provider.dart';

import '../utils/index.dart';

class SpaceSettingsPage extends ConsumerStatefulWidget {
  const SpaceSettingsPage({super.key});

  @override
  ConsumerState<SpaceSettingsPage> createState() => _SpaceSettingsPageState();
}

class _SpaceSettingsPageState extends ConsumerState<SpaceSettingsPage> {
  // 接收传递的空间数据，初始化为空对象避免late初始化错误
  SpaceVO? _spaceInfo;

  final _spaceNameController = TextEditingController();
  final _spaceNameFocus = FocusNode();
  bool _isPrivate = true;
  bool _allowDownload = true;
  bool _allowShare = true;
  bool _enableWatermark = false;
  bool _isLoading = false;
  bool _isSpaceNameFocused = false;

  @override
  void initState() {
    super.initState();

    // 监听焦点变化
    _spaceNameFocus.addListener(() {
      setState(() {
        _isSpaceNameFocused = _spaceNameFocus.hasFocus;
      });
    });

    // 监听输入内容变化
    _spaceNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 在这里获取传递的参数更安全
    if (_spaceInfo == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is SpaceVO) {
        _spaceInfo = args;
        _spaceNameController.text = _spaceInfo!.spaceName;
        _isPrivate = _spaceInfo!.spaceType == 0;
      } else {
        // 如果没有传递数据，使用空对象
        _spaceInfo = SpaceVO.empty();
      }
    }
  }

  @override
  void dispose() {
    _spaceNameController.dispose();
    _spaceNameFocus.dispose();
    super.dispose();
  }

  String _getSpaceLevelName(int level) {
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

  Color _getSpaceLevelColor(int level) {
    switch (level) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.purple;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 格式化时间戳
  String _formatDateTime(int timestamp) {
    if (timestamp == 0) return '未知';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // 计算存储进度
  double _calculateProgress(int used, int max) {
    if (max <= 0) return 0.0;
    return (used / max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // 如果数据还未初始化，显示加载界面
    if (_spaceInfo == null) {
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
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final spaceInfo = _spaceInfo!;
    
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
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              // 更新空间信息
              final updatedSpace = spaceInfo.copyWith(
                spaceName: _spaceNameController.text.trim(),
                spaceType: _isPrivate ? 0 : 1,
              );

              await SpaceApi.updateSpace({
                "id": spaceInfo.id,
                "spaceName": _spaceNameController.text.trim(),
              });
              // ✅ 更新全局 Provider
              ref.read(spaceProvider.notifier).updateSpace(updatedSpace);
              
              setState(() {
                _isLoading = false;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('设置已保存'),
                    backgroundColor: Colors.green,
                  ),
                );
                // 返回上一页，Provider 会自动同步数据
                Navigator.pop(context);
              }
            },
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : Text(
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
                  _spaceNameFocus,
                  '请输入空间名称',
                  _isSpaceNameFocused,
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '空间级别',
                  _getSpaceLevelName(spaceInfo.spaceLevel),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSpaceLevelColor(spaceInfo.spaceLevel)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '升级',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSpaceLevelColor(spaceInfo.spaceLevel),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () {
                    _showUpgradeDialog();
                  },
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '创建时间',
                  _formatDateTime(spaceInfo.createTime),
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
                  '${formatFileSize(int.tryParse(spaceInfo.totalSize) ?? 0)} / ${formatFileSize(int.tryParse(spaceInfo.maxSize) ?? 0)}',
                  _calculateProgress(int.tryParse(spaceInfo.totalSize) ?? 0,
                      int.tryParse(spaceInfo.maxSize) ?? 1),
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '图片数量',
                  '${spaceInfo.totalCount} / ${spaceInfo.maxCount}',
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

  Widget _buildTextFieldItem(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    String hint,
    bool isFocused,
  ) {
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
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: (isFocused || controller.text.isNotEmpty) ? null : hint,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value,
      {Widget? trailing, VoidCallback? onTap}) {
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

  Widget _buildSwitchItem(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
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

  Widget _buildActionItem(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
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

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[600]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.upgrade,
                color: Colors.blue[600],
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '空间升级',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '升级到更高级别的空间可获得更多存储空间和功能。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildUpgradeOption('专业版', '200GB存储空间，支持水印', Colors.purple),
            const SizedBox(height: 12),
            _buildUpgradeOption('旗舰版', '500GB存储空间，团队协作', Colors.orange),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_mail,
                        color: Colors.blue[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '作者联系方式',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '点击空间升级可联系作者邮箱进行联系升级相应版本',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.blue[600],
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'author@lqpicture.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactAuthorDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '联系作者',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactAuthorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green[600]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.green[600],
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '作者联系方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      color: Colors.blue[600],
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LQ Picture 开发者',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '专业的图片管理应用开发者',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email_outlined,
              '邮箱',
              'author@lqpicture.com',
              Colors.blue,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已复制邮箱地址: author@lqpicture.com'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.phone_outlined,
              '微信',
              'lqpicture_dev',
              Colors.green,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已复制微信号: lqpicture_dev'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.language_outlined,
              '官网',
              'www.lqpicture.com',
              Colors.orange,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已复制官网地址: www.lqpicture.com'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              '关闭',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeOption(String title, String features, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: color,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  features,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm,
      {bool isDestructive = false}) {
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
