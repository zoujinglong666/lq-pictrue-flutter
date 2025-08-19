/// @author: jiangjunhui
/// @date: 2025/2/8
library;

import 'package:flutter_screenutil/flutter_screenutil.dart';
/*
* px（像素）和 rpx（响应式像素）是在前端开发和移动端应用开发中用于度量尺寸的单位
* px 是固定像素单位，它代表屏幕上的一个物理像素点
* rpx 是一种相对的、响应式的长度单位，其设计目的是为了在不同尺寸的屏幕上实现元素的等比例缩放。
* 规定在 750px 宽的屏幕上，1rpx = 1px。在不同宽度的屏幕上，rpx 会按照屏幕宽度的比例进行缩放
* 。例如，在 375px 宽的屏幕上，750rpx 就等于 375px，此时 1rpx = 0.5px；
* 在 1080px 宽的屏幕上，750rpx 等于 1080px，此时 1rpx = 1.44px。
*
* */



// 为 int 类型添加扩展
extension IntScreenExtensions on int {
  /// 转换为适配后的像素值
  double get px => toDouble().w;

  /// 转换为适配后的响应式像素值（这里使用与 px 相同逻辑，可按需调整）
  double get rpx => toDouble().w;
}

// 为 double 类型添加扩展
extension DoubleScreenExtensions on double {
  /// 转换为适配后的像素值
  double get px => w;

  /// 转换为适配后的响应式像素值（这里使用与 px 相同逻辑，可按需调整）
  double get rpx => w;
}
 
 
 
 
 
 
 
 
 
 