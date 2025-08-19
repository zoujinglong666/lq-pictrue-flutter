/// @author: jiangjunhui
/// @date: 2025/2/18
library;
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

class SafeMapConverter extends JsonConverter<Map<String, dynamic>, dynamic> {
  const SafeMapConverter();

  @override
  Map<String, dynamic> fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    try {
      if (json is String) {
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      // 处理解析异常
    }
    return {};
  }

  @override
  dynamic toJson(Map<String, dynamic> object) {
    return object;
  }
}
