import 'dart:io';

import 'package:dio/dio.dart';

final class Consts {
  Consts._();

  /// Empty function constant
  static void doNothing() {}

  /// About network request
  static const request = (
  baseUrl: "http://10.9.17.161:8123/api",
  port:8123 ,
  socketUrl: "http://10.9.17.161:8123",
  minWaitingTime: Duration(milliseconds: 500),
  cachedTime: Duration(milliseconds: 2000),
  sendTimeout: Duration(seconds: 5),
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  successCode: 0,
  pageSize: 10,
  );





  /// 动态获取 socketUrl
  static Future<String> getSocketUrl({int port = 8123}) async {
    final ip = await NetworkUtils.getLocalIpAddress() ?? "127.0.0.1";
    return "http://$ip:$port";
  }

// 选项2：按功能命名
  static const pictureOptions = (
  tagList: ["热门", "搞笑", "生活", "高清", "艺术", "校园", "背景", "简历", "创意"],
  categoryList: ["模板", "电商", "表情包", "素材", "海报"],
  );

}


class NetworkUtils {
  /// 获取本机的 IPv4 地址（局域网内可用）
  static Future<String?> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
          return addr.address; // 例如 "192.168.0.23"
        }
      }
    }
    return null;
  }
}
