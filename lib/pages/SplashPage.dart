import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/pages/MainPage.dart';
import 'package:lq_picture/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // 启动缓冲
      final prefs = await SharedPreferences.getInstance();
      final authState = ref.read(authProvider);

      // 步骤3: 导航到相应页面（减少延迟）
      await Future.delayed(const Duration(milliseconds: 50)); // 进一步减少到50ms


      if (!mounted) return; // 确保页面仍在树中
      final targetPage = (authState.token  != null && authState.token!.isNotEmpty)
          ? const MainPage()
          : const LoginPage();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => targetPage),
      );
    } catch (e) {
      debugPrint('启动时发生错误: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('初始化失败，请重启 App')),
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
            SizedBox(height: 8),
            Text('正在加载...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
