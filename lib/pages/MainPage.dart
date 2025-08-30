import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lq_picture/pages/home_page.dart';
import 'package:lq_picture/pages/profile_page.dart';
import 'package:lq_picture/pages/upload_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  final List<Widget> pages = const [HomePage(),UploadPage(),ProfilePage()];

  final List<_TabItem> tabs = const [
    _TabItem(icon: Icons.home, label: '首页'),
    _TabItem(icon: Icons.send, label: '上传'),
    _TabItem(icon: Icons.settings, label: '我的'),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 给页面内容预留底部空间
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: IndexedStack(index: selectedIndex, children: pages),
          ),

          // 底部导航栏加 SafeArea
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: _CustomTabBar(
                tabs: tabs,
                selectedIndex: selectedIndex,
                onTap: onTabTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _TabItem {
  final IconData icon;
  final String label;

  const _TabItem({required this.icon, required this.label});
}

class _CustomTabBar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int selectedIndex;
  final Function(int) onTap;
  final Color activeColor;

  const _CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.activeColor = const Color(0xFF4FC3F7),
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 64;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: barHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // 主阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          // 内阴影效果
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
          child: Container(
            decoration: BoxDecoration(
              // 更精致的液态玻璃渐变背景
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.15),
                      ]
                    : [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.3),
                      ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              // 精致的双层边框
              border: Border.all(
                width: 1.2,
                color: Colors.white.withOpacity(0.35),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = index == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: isSelected
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              // iOS风格的液态玻璃渐变
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.4),
                                  Colors.white.withOpacity(0.2),
                                  activeColor.withOpacity(0.15),
                                  Colors.white.withOpacity(0.1),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ),
                              // 精致的边框
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.1,
                              ),
                              // 多层阴影效果
                              boxShadow: [
                                // 主要阴影
                                BoxShadow(
                                  color: activeColor.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                  spreadRadius: -2,
                                ),
                                // 内发光效果
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                  spreadRadius: -3,
                                ),
                                // 底部深度阴影
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                  spreadRadius: -1,
                                ),
                              ],
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            transform: Matrix4.identity()
                              ..scale(isSelected ? 1.1 : 1.0),
                            child: Icon(
                              tab.icon,
                              size: 24,
                              color: isSelected
                                  ? activeColor
                                  : (isDark 
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.6)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            style: TextStyle(
                              fontSize: isSelected ? 12 : 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? activeColor
                                  : (isDark 
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.6)),
                            ),
                            child: Text(tab.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
