import 'package:flutter/material.dart';
import 'package:lq_picture/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4FC3F7);
    
    return MaterialApp(
      title: '龙琪图库',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: primaryColor,
        
        // AppBar主题
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),
        
        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // 文本按钮主题
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // 输入框主题
        // inputDecorationTheme: InputDecorationTheme(
        //   focusedBorder: OutlineInputBorder(
        //     borderSide: BorderSide(color: primaryColor, width: 2),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   enabledBorder: OutlineInputBorder(
        //     borderSide: BorderSide(color: Colors.grey.shade300),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   errorBorder: OutlineInputBorder(
        //     borderSide: const BorderSide(color: Colors.red),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   focusedErrorBorder: OutlineInputBorder(
        //     borderSide: const BorderSide(color: Colors.red, width: 2),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // ),
        
        // 浮动操作按钮主题
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // 进度指示器主题
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: primaryColor,
          linearTrackColor: primaryColor.withOpacity(0.2),
          circularTrackColor: primaryColor.withOpacity(0.2),
        ),
        
        // 选择框主题
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: BorderSide(color: Colors.grey.shade400),
        ),
        
        // 单选框主题
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey.shade400;
          }),
        ),
        
        // 开关主题
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.grey.shade400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return Colors.grey.shade300;
          }),
        ),
        
        // 滑块主题
        sliderTheme: SliderThemeData(
          activeTrackColor: primaryColor,
          inactiveTrackColor: primaryColor.withOpacity(0.3),
          thumbColor: primaryColor,
          overlayColor: primaryColor.withOpacity(0.2),
        ),
        
        // 标签页主题
        tabBarTheme: TabBarTheme(
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
        ),
        
        // 底部导航栏主题
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}









