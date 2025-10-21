import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/routes/app_routes.dart';
import 'package:lq_picture/utils/screenutil/screen_adapter.dart';
import 'net/interceptor_cache.dart';
import 'net/request.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 启用沉浸式系统 UI（Edge-to-Edge）
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // 透明状态栏与导航栏，去除底部黑色背景小白条
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
final botToastBuilder = BotToastInit();
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // 初始化屏幕适配
    ScreenAdapter.init(context);
    return GestureDetector(
      // 全局点击监听器，点击空白区域时取消焦点
      onTap: () {
        // 取消当前焦点，隐藏键盘
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: '龙琪图库',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
        navigatorObservers: [
          CacheManager.observer, // 像这样注册进去就可以了
          // 添加路由观察者来处理页面切换时的焦点管理
          _KeyboardFocusObserver(),
          BotToastNavigatorObserver(),
        ],
        builder: (context, child) {
          // 确保在构建时取消任何残留的焦点
          child = botToastBuilder(context, child);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child,
          );
        },
      ),
    );
  }
}

// 自定义路由观察者，用于处理页面切换时的键盘焦点问题
class _KeyboardFocusObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // 页面推入时取消焦点
    _unfocusKeyboard();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // 页面弹出时取消焦点
    _unfocusKeyboard();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // 页面替换时取消焦点
    _unfocusKeyboard();
  }

  void _unfocusKeyboard() {
    // 延迟执行，确保页面切换动画完成后再取消焦点
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }
}









