/// @author: jiangjunhui
/// @date: 2025/2/17
library;
import 'package:json_annotation/json_annotation.dart';

class SafeDateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  const SafeDateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json is DateTime) return json;
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) => date?.toIso8601String();
}
