import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/net/request.dart';
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

    // 等待 auth provider 初始化完成
    final authNotifier = ref.read(authProvider.notifier);

    // 确保状态已经从存储中加载，但设置超时防止无限等待
    int waitCount = 0;
    const maxWaitCount = 50; // 最多等待5秒
    
    while (!authNotifier.state.isInitialized && waitCount < maxWaitCount) {
      await Future.delayed(const Duration(milliseconds: 100));
      waitCount++;
      if (!mounted) return;
    }

    // 如果超时仍未初始化，强制初始化为未登录状态
    if (!authNotifier.state.isInitialized) {
      debugPrint('认证状态初始化超时，使用默认状态');
    }

    // 监听 auth 状态变化
    final authState = ref.read(authProvider);
    if (!mounted) return;
    
    // 根据认证状态导航
    final targetPage = authState.isLoggedIn
        ? const MainPage()
        : const LoginPage();

    if (!mounted) return;
    
    // 只有在已登录且token不为空时才设置token
    if (authState.isLoggedIn && authState.token != null) {
      Http.setToken(authState.token!);
    } else {
      Http.clearToken();
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetPage),
    );
  } catch (e) {
    debugPrint('启动时发生错误: $e');
    if (!mounted) return;
    Http.clearToken();
    // 错误时导航到登录页
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5), // 奶白
              Color(0xFFE8EDF2), // 浅蓝灰
              Color(0xFFF0E6E8), // 淡粉白
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 抽象几何背景装饰 - 左上角圆角矩形
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFB8C5D6).withOpacity(0.15), // 莫兰迪蓝
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 右下角柔和圆形
            Positioned(
              bottom: -100,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFD4B5C0).withOpacity(0.12), // 莫兰迪粉
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 中央小圆形装饰
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFA8B8C8).withOpacity(0.1), // 莫兰迪灰蓝
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 主内容区
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 悬浮图标容器 - 轻盈感设计
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Color(0xFFFAFAFA).withOpacity(0.9),
                        ],
                      ),
                      boxShadow: [
                        // 主阴影 - 柔和深度
                        BoxShadow(
                          color: Color(0xFF9CA8B5).withOpacity(0.15),
                          offset: Offset(0, 12),
                          blurRadius: 30,
                          spreadRadius: -5,
                        ),
                        // 光晕效果
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          offset: Offset(0, -2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      size: 50,
                      color: Color(0xFF8A9BAE), // 莫兰迪蓝灰
                    ),
                  ),
                  const SizedBox(height: 50),
                  // 标题 - 极简优雅
                  Text(
                    '龙琪图库',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF4A5568), // 深灰
                      letterSpacing: 6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 副标题 - 意境表达
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '照片 · 回忆 · 美好',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF9CA8B5), // 莫兰迪灰
                        letterSpacing: 3,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  // 加载指示器 - 极简设计
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFB8C5D6), // 莫兰迪蓝
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
