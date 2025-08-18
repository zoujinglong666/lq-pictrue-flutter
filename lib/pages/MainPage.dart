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
                activeColor: theme.colorScheme.primary,
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
    this.activeColor = const Color(0xFF26C6DA),
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 56;

    return Container(
      height: barHeight,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 24,
                        color: isSelected
                            ? activeColor
                            : Colors.black.withOpacity(0.45),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected
                              ? activeColor
                              : Colors.black.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
