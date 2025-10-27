import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/widgets/SimpleWebView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../apis/notific_api.dart';
import '../providers/auth_provider.dart';
import '../services/sse_service.dart';

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
        await for (final entity
            in directory.list(recursive: true, followLinks: false)) {
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
    try {
      // 关闭SSE连接
      await NotifyApi.unsubscribe();
      final sseService = SSEService();
      await sseService.disconnect();
      print('SSE连接已关闭');
    } catch (e) {
      print('关闭SSE连接时出错: $e');
    }

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
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // 渐变AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6DD5ED),
                    Color(0xFF2193B0),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  '设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 通知与存储
                _buildModernCard(
                  children: [
                    _buildModernSwitchTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFF6DD5ED),
                      title: '推送通知',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _saveSettings();
                      },
                    ),
                    _buildDivider(),
                    _buildModernSwitchTile(
                      icon: Icons.cloud_download_outlined,
                      iconColor: const Color(0xFF2193B0),
                      title: '自动保存',
                      value: _autoSaveEnabled,
                      onChanged: (value) {
                        setState(() => _autoSaveEnabled = value);
                        _saveSettings();
                      },
                    ),
                    _buildDivider(),
                    _buildModernTile(
                      icon: Icons.storage_rounded,
                      iconColor: const Color(0xFF4FACFE),
                      title: '缓存管理',
                      subtitle: _cacheSize,
                      onTap: _clearCache,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 账号安全
                _buildModernCard(
                  children: [
                    _buildModernTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFFFF6B9D),
                      title: '忘记密码',
                      onTap: () => Navigator.pushNamed(context, '/forgot_password'),
                    ),
                    _buildDivider(),
                    _buildModernTile(
                      icon: Icons.vpn_key_outlined,
                      iconColor: const Color(0xFFFFA07A),
                      title: '修改密码',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('修改密码功能开发中')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildModernTile(
                      icon: Icons.phone_iphone_rounded,
                      iconColor: const Color(0xFF96E6A1),
                      title: '绑定手机',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('绑定手机功能开发中')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildModernTile(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFFB4A7D6),
                      title: '绑定邮箱',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('绑定邮箱功能开发中')),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 关于
                _buildModernCard(
                  children: [
                    _buildModernTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF9795B5),
                      title: '应用版本',
                      trailing: const Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: Color(0xFF9795B5),
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildModernTile(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF8E94A9),
                      title: '用户协议',
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
                    ),
                    _buildDivider(),
                    _buildModernTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: const Color(0xFFA8B5C7),
                      title: '隐私政策',
                      onTap: () {
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
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 退出登录
                _buildModernCard(
                  children: [
                    _buildModernTile(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFE17055),
                      title: '退出登录',
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // 极简卡片容器
  Widget _buildModernCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2193B0).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  // 极简开关项
  Widget _buildModernSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withOpacity(0.15),
                  iconColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3436),
                letterSpacing: 0.2,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
              activeTrackColor: iconColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  // 极简点击项
  Widget _buildModernTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withOpacity(0.15),
                    iconColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3436),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF95A5A6),
                ),
              ),
            if (trailing != null) trailing,
            if (subtitle == null && trailing == null)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBDC3C7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // 分割线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 80),
      height: 0.5,
      color: const Color(0xFFF0F3F6),
    );
  }
}
