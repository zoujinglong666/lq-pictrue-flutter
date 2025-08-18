import 'package:flutter/material.dart';
import 'package:lq_picture/widgets/SimpleWebView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  String _cacheSize = '计算中...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _autoSaveEnabled = prefs.getBool('auto_save_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setBool('auto_save_enabled', _autoSaveEnabled);
  }

  Future<void> _calculateCacheSize() async {
    // 模拟计算缓存大小
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _cacheSize = '128.5 MB';
    });
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text('清除缓存'),
          ],
        ),
        content: const Text('确定要清除所有缓存数据吗？这将删除已下载的图片缓存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 模拟清除缓存
              setState(() {
                _cacheSize = '清除中...';
              });
              await Future.delayed(const Duration(seconds: 2));
              setState(() {
                _cacheSize = '0 MB';
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('缓存清除成功'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定清除'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('退出登录'),
          ],
        ),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定退出'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // 清除用户数据
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_info');
    
    if (mounted) {
      // 显示退出成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已退出登录'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 跳转到登录页面并清除所有路由栈
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
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
          '设置',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // 通知设置
            _buildSectionTitle('通知设置'),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: '推送通知',
                subtitle: '接收新消息和系统通知',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // 显示设置
            _buildSectionTitle('显示设置'),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: '深色模式',
                subtitle: '使用深色主题界面',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // 存储设置
            _buildSectionTitle('存储设置'),
            _buildSettingCard([
              _buildSwitchTile(
                icon: Icons.save_outlined,
                title: '自动保存',
                subtitle: '自动保存浏览过的图片',
                value: _autoSaveEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoSaveEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.storage_outlined,
                title: '缓存管理',
                subtitle: '当前缓存大小：$_cacheSize',
                onTap: _clearCache,
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // 关于应用
            _buildSectionTitle('关于应用'),
            _buildSettingCard([
              _buildActionTile(
                icon: Icons.info_outline,
                title: '应用版本',
                subtitle: 'v1.0.0',
                onTap: () {},
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.description_outlined,
                title: '用户协议',
                subtitle: '查看用户服务协议',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SimpleWebView(
                        url: 'https://baidu.com/',
                        title: '用户协议',
                      ),
                    ),
                  );
                },
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                subtitle: '查看隐私保护政策',
                onTap: () {
                  // 1. 简单用法
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SimpleWebView(
                        url: 'https://jd.com/',
                        title: '隐私政策',
                      ),
                    ),
                  );
                },
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // 账户操作
            _buildSectionTitle('账户操作'),
            _buildSettingCard([
              _buildActionTile(
                icon: Icons.logout,
                title: '退出登录',
                subtitle: '退出当前账户',
                onTap: _showLogoutDialog,
                trailing: Icon(Icons.chevron_right, color: Colors.red[400]),
                titleColor: Colors.red[600],
              ),
            ]),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[600], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: titleColor?.withOpacity(0.1) ?? Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon, 
          color: titleColor ?? Colors.grey[600], 
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}