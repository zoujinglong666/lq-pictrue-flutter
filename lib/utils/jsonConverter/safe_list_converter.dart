/// @author: jiangjunhui
/// @date: 2025/2/18
library;
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

class SafeListConverter extends JsonConverter<List<dynamic>, dynamic> {
  const SafeListConverter();

  @override
  List<dynamic> fromJson(dynamic json) {
    if (json is List<dynamic>) {
      return json;
    }
    try {
      if (json is String) {
        final decoded = jsonDecode(json);
        if (decoded is List<dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      // 捕获解析过程中可能出现的异常
    }
    return [];
  }

  @override
  dynamic toJson(List<dynamic> object) {
    return object;
  }
}
