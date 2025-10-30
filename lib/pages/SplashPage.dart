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

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isNavigating = false;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));
    
    // 滑入动画
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    
    // 启动动画
    _animationController.forward();
    
    // 延迟执行认证检查，确保动画有足够时间展示
    _checkAuthStatus();
  }

Future<void> _checkAuthStatus() async {
  try {
    if (!mounted) return;
    
    // 最小显示时间，确保用户能看到启动页（避免闪现）
    const minDisplayDuration = Duration(milliseconds: 1800);
    final startTime = DateTime.now();
    
    // 等待 auth provider 初始化完成
    final authNotifier = ref.read(authProvider.notifier);
    
    // 确保状态已经从存储中加载，但设置超时防止无限等待
    int waitCount = 0;
    const maxWaitCount = 30; // 最多等待3秒
    
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
    
    // 确保启动页显示足够时间
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < minDisplayDuration) {
      await Future.delayed(minDisplayDuration - elapsedTime);
    }
    
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    
    // 添加淡出动画效果的页面过渡
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 淡入淡出 + 轻微缩放效果
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));
          
          final scaleAnimation = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  } catch (e) {
    debugPrint('启动时发生错误: $e');
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    
    Http.clearToken();
    
    // 确保最小显示时间
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // 错误时导航到登录页，同样使用平滑过渡
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
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
                // 抽象几何背景装饰 - 左上角圆角矩形（带动画）
                Positioned(
                  top: -80,
                  left: -60,
                  child: Opacity(
                    opacity: _fadeAnimation.value * 0.6,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
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
                  ),
                ),
                // 右下角柔和圆形（带动画）
                Positioned(
                  bottom: -100,
                  right: -80,
                  child: Opacity(
                    opacity: _fadeAnimation.value * 0.5,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
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
                  ),
                ),
                // 中央小圆形装饰（带动画）
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  right: 40,
                  child: Opacity(
                    opacity: _fadeAnimation.value * 0.4,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
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
                  ),
                ),
                // 主内容区（带滑入和淡入动画）
                Center(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 悬浮图标容器 - 轻盈感设计（带缩放动画）
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
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
                                    color: Color(0xFF9CA8B5).withOpacity(0.15 * _fadeAnimation.value),
                                    offset: Offset(0, 12),
                                    blurRadius: 30,
                                    spreadRadius: -5,
                                  ),
                                  // 光晕效果
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8 * _fadeAnimation.value),
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
                          ),
                          const SizedBox(height: 50),
                          // 标题 - 极简优雅
                          Text(
                            '龙琪图库',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF4A5568).withOpacity(_fadeAnimation.value), // 深灰
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
                                color: Color(0xFF9CA8B5).withOpacity(_fadeAnimation.value), // 莫兰迪灰
                                letterSpacing: 3,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          // 加载指示器 - 极简设计（带脉冲效果）
                          Opacity(
                            opacity: _fadeAnimation.value,
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFB8C5D6), // 莫兰迪蓝
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
