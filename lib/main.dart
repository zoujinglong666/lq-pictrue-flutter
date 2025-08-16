import 'package:flutter/material.dart';
import 'package:lq_picture/pages/SplashPage.dart';
import 'package:lq_picture/pages/detail_page.dart';
import 'package:lq_picture/pages/search_page.dart';
import 'package:lq_picture/pages/image_preview_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '摄图网',
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
        }
        return null;
      },
    );
  }
}









