import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/model/picture.dart';
import 'package:lq_picture/pages/SplashPage.dart';
import 'package:lq_picture/pages/detail_page.dart';
import 'package:lq_picture/pages/forgot_password_page.dart';
import 'package:lq_picture/pages/search_page.dart';
import 'package:lq_picture/pages/image_preview_page.dart';
import 'package:lq_picture/pages/login_page.dart';
import 'package:lq_picture/pages/register_page.dart';
import 'package:lq_picture/pages/notification_page.dart';
import 'package:lq_picture/pages/create_space_page.dart';
import 'package:lq_picture/pages/my_space_page.dart';
import 'package:lq_picture/pages/space_settings_page.dart';
import 'package:lq_picture/pages/picture_management_page.dart';
import 'package:lq_picture/pages/space_management_page.dart';
import 'package:lq_picture/pages/user_settings_page.dart';
import 'package:lq_picture/pages/user_management_page.dart';
import 'package:lq_picture/pages/settings_page.dart';
import 'package:lq_picture/pages/upload_page.dart';
import 'package:lq_picture/pages/MainPage.dart';
import 'package:lq_picture/pages/forbidden_page.dart';
import 'package:lq_picture/pages/image_edit_page.dart';
import 'package:lq_picture/pages/image_review_status_page.dart';
import 'package:lq_picture/pages/favorites_page.dart';
import 'package:lq_picture/pages/ai_search_page.dart';

/// 动画类型枚举
enum RouteTransitionType {
  /// Cupertino风格（iOS原生）
  cupertino,
  /// 淡入淡出
  fade,
  /// 从右向左滑入（默认）
  slideRight,
  /// 从底部向上滑入
  slideUp,
  /// 从顶部向下滑入
  slideDown,
  /// 缩放
  scale,
  /// 缩放+淡入组合
  scaleWithFade,
  /// 旋转（不常用）
  rotate,
}

class AppRoutes {
  // 路由名称常量
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String search = '/search';
  static const String preview = '/preview';
  static const String notification = '/notification';
  static const String createSpace = '/create_space';
  static const String mySpace = '/my_space';
  static const String spaceSettings = '/space_settings';
  static const String pictureManagement = '/picture_management';
  static const String spaceManagement = '/space_management';
  static const String userManagement = '/user_management';
  static const String userSettings = '/user_settings';
  static const String settings = '/settings';
  static const String upload = '/upload';
  static const String forgotPassword = '/forgot_password';
  static const String forbidden = '/forbidden';
  static const String imageEdit = '/image_edit';
  static const String imageReviewStatus = '/image_review_status';
  static const String favorites = '/favorites';
  static const String aiSearch = '/ai_search';

  // 创建自定义页面路由
  static PageRoute _createPageRoute({
    required Widget page,
    required RouteSettings settings,
    RouteTransitionType transitionType = RouteTransitionType.cupertino,
  }) {
    // 如果是 Cupertino 风格，直接使用 CupertinoPageRoute
    if (transitionType == RouteTransitionType.cupertino) {
      return CupertinoPageRoute(
        builder: (context) => page,
        settings: settings,
      );
    }

    // 其他动画类型使用 PageRouteBuilder
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          transitionType: transitionType,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  // 构建过渡动画
  static Widget _buildTransition({
    required RouteTransitionType transitionType,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    switch (transitionType) {
      case RouteTransitionType.cupertino:
        // 不会走到这里，因为已经在上面处理了
        return child;

      case RouteTransitionType.fade:
        // 淡入淡出动画
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case RouteTransitionType.slideRight:
        // 从右向左滑入（类似iOS）
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.easeIn,
          )),
          child: child,
        );

      case RouteTransitionType.slideUp:
        // 从底部向上滑入
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        );

      case RouteTransitionType.slideDown:
        // 从顶部向下滑入
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          )),
          child: child,
        );

      case RouteTransitionType.scale:
        // 缩放动画
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: child,
        );

      case RouteTransitionType.scaleWithFade:
        // 缩放+淡入组合动画
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.85,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );

      case RouteTransitionType.rotate:
        // 旋转动画（不常用）
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }

  // 根据路由名称获取动画类型
  static RouteTransitionType _getTransitionType(String? routeName) {
    switch (routeName) {
      // 启动页：淡入
      case splash:
        return RouteTransitionType.fade;

      // 登录、注册、忘记密码：从底部滑入
      case login:
      case register:
      case forgotPassword:
        return RouteTransitionType.slideUp;

      // 上传、创建空间：从底部滑入（模态效果）
      case upload:
      case createSpace:
        return RouteTransitionType.slideUp;

      // 详情、预览：缩放+淡入
      case detail:
      case preview:
        return RouteTransitionType.scaleWithFade;

      // AI搜索：缩放+淡入
      case aiSearch:
        return RouteTransitionType.scaleWithFade;

      // 其他页面：使用原生Cupertino动画
      default:
        return RouteTransitionType.cupertino;
    }
  }

  // 路由映射表
  static final Map<String, WidgetBuilder> _routes = {
    splash: (context) => const SplashPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const MainPage(),
    search: (context) => const SearchPage(),
    notification: (context) => const NotificationPage(),
    createSpace: (context) => const CreateSpacePage(),
    mySpace: (context) => const MySpacePage(),
    spaceSettings: (context) => const SpaceSettingsPage(),
    pictureManagement: (context) => const PictureManagementPage(),
    spaceManagement: (context) => const SpaceManagementPage(),
    userManagement: (context) => const UserManagementPage(),
    userSettings: (context) => const UserSettingsPage(),
    settings: (context) => const SettingsPage(),
    upload: (context) => const UploadPage(),
    forgotPassword: (context) => const ForgotPasswordPage(),
    forbidden: (context) => const ForbiddenPage(),
    imageEdit: (context) => const ImageEditPage(),
    imageReviewStatus: (context) => const ImageReviewStatusPage(),
    favorites: (context) => const FavoritesPage(),
    aiSearch: (context) => const AiSearchPage(),
  };

  // 获取路由映射表
  static Map<String, WidgetBuilder> get routes => _routes;

  // 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final transitionType = _getTransitionType(settings.name);

    // 处理需要参数的路由
    switch (settings.name) {
      case detail:
        final args = settings.arguments as PictureVO?;
        return _createPageRoute(
          page: DetailPage(imageData: args),
          settings: settings,
          transitionType: transitionType,
        );

      case preview:
        final imageUrl = settings.arguments as String;
        return _createPageRoute(
          page: ImagePreviewPage(imageUrl: imageUrl),
          settings: settings,
          transitionType: transitionType,
        );

      case imageEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createPageRoute(
          page: ImageEditPage(
            imageData: args?['imageData'],
          ),
          settings: settings,
          transitionType: transitionType,
        );
        
      case mySpace:
        return _createPageRoute(
          page: MySpacePage(),
          settings: settings,
          transitionType: transitionType,
        );
        
      default:
        // 处理普通路由
        final builder = _routes[settings.name];
        if (builder != null) {
          // 创建一个临时Widget来获取context
          return _createPageRoute(
            page: Builder(
              builder: (context) => builder(context),
            ),
            settings: settings,
            transitionType: transitionType,
          );
        }
        return null;
    }
  }

  // 未知路由处理
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '页面未找到: ${settings.name}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  // 便捷的导航方法
  static Future<T?> pushNamed<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
        TO? result,
      }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      BuildContext context,
      String newRouteName,
      bool Function(Route<dynamic>) predicate, {
        Object? arguments,
      }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }
}