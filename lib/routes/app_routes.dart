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

// 动画类型枚举
enum AnimationType {
  iosStyle,        // iOS风格动画（默认）
  slideFromBottom, // 从底部滑入
  fadeIn,          // 淡入
  scaleIn,         // 缩放进入
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

  // 创建iOS风格的页面路由
  static PageRouteBuilder _createIOSRoute({
    required Widget page,
    required RouteSettings settings,
    AnimationType animationType = AnimationType.iosStyle,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (animationType) {
          case AnimationType.iosStyle:
          // iOS风格的滑动动画，支持交互式返回手势
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end);
            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            // 主页面滑入动画
            var slideTransition = SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );

            // 如果有前一个页面，添加阴影效果
            if (secondaryAnimation.status != AnimationStatus.dismissed) {
              return Stack(
                children: [
                  // 前一个页面稍微向左移动并变暗
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset.zero,
                      end: const Offset(-0.3, 0.0),
                    ).animate(secondaryAnimation),
                    child: Container(
                      color: Colors.black.withOpacity(0.1 * secondaryAnimation.value),
                    ),
                  ),
                  slideTransition,
                ],
              );
            }

            return slideTransition;

          case AnimationType.slideFromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            );

          case AnimationType.fadeIn:
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

          case AnimationType.scaleIn:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.9,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutBack,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
        }
      },
    );
  }

  // 根据路由名称获取动画类型
  static AnimationType _getAnimationType(String? routeName) {
    switch (routeName) {
      case splash:
        return AnimationType.fadeIn;

      case login:
      case register:
      case forgotPassword:
        return AnimationType.slideFromBottom;

      case upload:
      case createSpace:
        return AnimationType.slideFromBottom;

      case detail:
      case preview:
        return AnimationType.scaleIn;

      default:
        return AnimationType.iosStyle; // 默认使用iOS风格
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
  };

  // 获取路由映射表
  static Map<String, WidgetBuilder> get routes => _routes;

  // 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final animationType = _getAnimationType(settings.name);

    // 处理需要参数的路由
    switch (settings.name) {
      case detail:
        final args = settings.arguments as PictureVO?;
        return _createIOSRoute(
          page: DetailPage(imageData: args),
          settings: settings,
          animationType: animationType,
        );

      case preview:
        final imageUrl = settings.arguments as String;
        return _createIOSRoute(
          page: ImagePreviewPage(imageUrl: imageUrl),
          settings: settings,
          animationType: animationType,
        );

      case imageEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createIOSRoute(
          page: ImageEditPage(
            imageId: args?['imageId'],
            imageData: args?['imageData'],
          ),
          settings: settings,
          animationType: animationType,
        );
      case mySpace:
        final args = settings.arguments as SpaceVO?;
        return _createIOSRoute(
          page: MySpacePage(spaceVO: args),
          settings: settings,
          animationType: animationType,
        );
      default:
      // 处理普通路由
        final builder = _routes[settings.name];
        if (builder != null) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => builder(context),
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              switch (animationType) {
                case AnimationType.iosStyle:
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end);
                  var curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: curve,
                  );

                  var slideTransition = SlideTransition(
                    position: tween.animate(curvedAnimation),
                    child: child,
                  );

                  if (secondaryAnimation.status != AnimationStatus.dismissed) {
                    return Stack(
                      children: [
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset.zero,
                            end: const Offset(-0.3, 0.0),
                          ).animate(secondaryAnimation),
                          child: Container(
                            color: Colors.black.withOpacity(0.1 * secondaryAnimation.value),
                          ),
                        ),
                        slideTransition,
                      ],
                    );
                  }

                  return slideTransition;

                case AnimationType.slideFromBottom:
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    )),
                    child: child,
                  );

                case AnimationType.fadeIn:
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

                case AnimationType.scaleIn:
                  return ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.9,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutBack,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
              }
            },
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
                  Navigator.pushReplacementNamed(context, home);
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