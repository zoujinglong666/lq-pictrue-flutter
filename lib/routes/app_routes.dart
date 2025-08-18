import 'package:flutter/material.dart';
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
  };

  // 获取路由映射表
  static Map<String, WidgetBuilder> get routes => _routes;

  // 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // 处理需要参数的路由
    switch (settings.name) {
      case detail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => DetailPage(imageData: args),
          settings: settings,
        );
      
      case preview:
        final imageUrl = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => ImagePreviewPage(imageUrl: imageUrl),
          settings: settings,
        );
      
      default:
        // 处理普通路由
        final builder = _routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }
        return null;
    }
  }

  // 未知路由处理
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, home);
                },
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}