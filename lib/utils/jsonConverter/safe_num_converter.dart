/// @author: jiangjunhui
/// @date: 2025/2/17
library;

import 'package:json_annotation/json_annotation.dart';

class SafeNumConverter extends JsonConverter<num, dynamic> {
  final num defaultValue;

  const SafeNumConverter({this.defaultValue = -10086});

  @override
  num fromJson(dynamic json) {
    if (json is num) {
      return json;
    }
    if (json is String) {
      try {
        return num.parse(json);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  @override
  dynamic toJson(num object) {
    return object;
  }
}
