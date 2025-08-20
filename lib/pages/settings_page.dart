import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/widgets/SimpleWebView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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
    try {
      setState(() {
        _cacheSize = '计算中...';
      });

      // 获取应用缓存目录
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();
      
      int totalSize = 0;
      
      // 计算临时目录大小
      if (await tempDir.exists()) {
        totalSize += await _calculateDirectorySize(tempDir);
      }
      
      // 计算缓存目录大小
      if (await cacheDir.exists()) {
        totalSize += await _calculateDirectorySize(cacheDir);
      }
      
      // 计算网络图片缓存大小（Flutter的默认缓存位置）
      final appDir = await getApplicationSupportDirectory();
      final flutterCacheDir = Directory('${appDir.path}/flutter_cache');
      if (await flutterCacheDir.exists()) {
        totalSize += await _calculateDirectorySize(flutterCacheDir);
      }

      setState(() {
        _cacheSize = _formatBytes(totalSize);
      });
    } catch (e) {
      setState(() {
        _cacheSize = '计算失败';
      });
    }
  }

  Future<int> _calculateDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (e) {
              // 忽略无法访问的文件
            }
          }
        }
      }
    } catch (e) {
      // 忽略无法访问的目录
    }
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
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
              await _performClearCache();
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

  Future<void> _performClearCache() async {
    try {
      setState(() {
        _cacheSize = '清除中...';
      });

      // 清除临时目录
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _clearDirectory(tempDir);
      }

      // 清除应用缓存目录
      final cacheDir = await getApplicationCacheDirectory();
      if (await cacheDir.exists()) {
        await _clearDirectory(cacheDir);
      }

      // 清除Flutter网络图片缓存
      final appDir = await getApplicationSupportDirectory();
      final flutterCacheDir = Directory('${appDir.path}/flutter_cache');
      if (await flutterCacheDir.exists()) {
        await _clearDirectory(flutterCacheDir);
      }

      // 清除Flutter的图片缓存
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 重新计算缓存大小
      await _calculateCacheSize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('缓存清除成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _cacheSize = '清除失败';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('缓存清除失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearDirectory(Directory directory) async {
    try {
      if (await directory.exists()) {
        await for (final entity in directory.list()) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            // 忽略无法删除的文件/目录
          }
        }
      }
    } catch (e) {
      // 忽略无法访问的目录
    }
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

    // 执行登出操作
    final authNotifier = ref.read(authProvider.notifier);
    authNotifier.logout();
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
            
            // 账号安全
            _buildSectionTitle('账号安全'),
            _buildSettingCard([
              _buildActionTile(
                icon: Icons.lock_reset_outlined,
                title: '忘记密码',
                subtitle: '通过邮箱或手机号重置密码',
                onTap: () {
                  Navigator.pushNamed(context, '/forgot_password');
                },
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.security_outlined,
                title: '修改密码',
                subtitle: '更改当前账户密码',
                onTap: () {
                  // TODO: 实现修改密码功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('修改密码功能开发中')),
                  );
                },
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.phone_android_outlined,
                title: '绑定手机',
                subtitle: '绑定手机号用于安全验证',
                onTap: () {
                  // TODO: 实现绑定手机功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('绑定手机功能开发中')),
                  );
                },
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.email_outlined,
                title: '绑定邮箱',
                subtitle: '绑定邮箱用于密码找回',
                onTap: () {
                  // TODO: 实现绑定邮箱功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('绑定邮箱功能开发中')),
                  );
                },
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