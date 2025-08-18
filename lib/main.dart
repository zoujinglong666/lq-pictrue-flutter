import 'package:flutter/material.dart';
import 'package:lq_picture/pages/SplashPage.dart';
import 'package:lq_picture/pages/detail_page.dart';
import 'package:lq_picture/pages/search_page.dart';
import 'package:lq_picture/pages/image_preview_page.dart';
import 'package:lq_picture/pages/login_page.dart';
import 'package:lq_picture/pages/register_page.dart';
import 'package:lq_picture/pages/notification_page.dart';
import 'package:lq_picture/pages/MainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const SplashPage(), // 修改为跳转逻辑页
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => DetailPage(imageData: args),
          );
        } else if (settings.name == '/search') {
          return MaterialPageRoute(
            builder: (context) => const SearchPage(),
          );
        } else if (settings.name == '/preview') {
          final imageUrl = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ImagePreviewPage(imageUrl: imageUrl),
          );
        } else if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => const LoginPage(),
          );
        } else if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => const MainPage(),
          );
        } else if (settings.name == '/register') {
          return MaterialPageRoute(
            builder: (context) => const RegisterPage(),
          );
        } else if (settings.name == '/notification') {
          return MaterialPageRoute(
            builder: (context) => const NotificationPage(),
          );
        }
        return null;
      },
    );
  }
}









