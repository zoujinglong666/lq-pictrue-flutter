import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/pages/MainPage.dart';
import 'package:lq_picture/pages/login_page.dart';

import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 给用户一些启动反馈
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      // 监听 auth 状态变化
      final authState = ref.read(authProvider);

      if (!mounted) return;

      // 根据认证状态导航
      final targetPage = (authState.token != null && authState.token!.isNotEmpty)
          ? const MainPage()
          : const LoginPage();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => targetPage),
      );
    } catch (e) {
      debugPrint('启动时发生错误: $e');
      if (!mounted) return;

      // 错误时导航到登录页
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '龙琪图库',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('正在加载...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
