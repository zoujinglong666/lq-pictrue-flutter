/// @author: jiangjunhui
/// @date: 2025/2/8
library;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenAdapter {
  // 初始化屏幕适配
  static void init(BuildContext context, {double width = 375, double height = 812}) {
    ScreenUtil.init(
      context,
      designSize: Size(width, height),
    );
  }

  // 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;

  // 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;

  // 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  // 获取底部安全区高度
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  // 适配宽度
  static double setWidth(double width) {
    return width.w;
  }

  // 适配高度
  static double setHeight(double height) {
    return height.h;
  }

  // 适配字体大小
  static double setSp(double fontSize) {
    return fontSize.sp;
  }
}
 
 
 
 
 
 
 
 
 
 
 
 