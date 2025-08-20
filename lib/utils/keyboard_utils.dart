import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 键盘管理工具类
class KeyboardUtils {
  /// 隐藏键盘
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    // 强制隐藏系统键盘
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// 显示键盘
  static void showKeyboard(FocusNode focusNode) {
    focusNode.requestFocus();
  }

  /// 为Widget添加点击隐藏键盘的功能
  static Widget wrapWithKeyboardDismiss({
    required Widget child,
    bool dismissOnTap = true,
  }) {
    if (!dismissOnTap) return child;
    
    return GestureDetector(
      onTap: () => hideKeyboard(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  /// 检查键盘是否显示
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// 获取键盘高度
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// 在页面切换时自动隐藏键盘的Mixin
  static void handlePageTransition() {
    // 延迟执行，确保页面切换动画完成
    Future.delayed(const Duration(milliseconds: 50), () {
      hideKeyboard();
    });
  }
}

/// 可以在StatefulWidget中使用的Mixin
mixin KeyboardDismissMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    // 页面初始化时隐藏键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      KeyboardUtils.hideKeyboard();
    });
  }

  @override
  void dispose() {
    // 页面销毁时隐藏键盘
    KeyboardUtils.hideKeyboard();
    super.dispose();
  }

  /// 包装Scaffold以自动处理键盘隐藏
  Widget buildWithKeyboardDismiss({
    required Widget body,
    AppBar? appBar,
    Widget? floatingActionButton,
    Widget? drawer,
    Widget? endDrawer,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
  }) {
    return KeyboardUtils.wrapWithKeyboardDismiss(
      child: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
        endDrawer: endDrawer,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}