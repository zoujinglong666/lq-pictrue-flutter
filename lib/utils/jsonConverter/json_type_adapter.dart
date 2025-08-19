/// @author: jiangjunhui
/// @date: 2025/2/18
library;

class JsonTypeAdapter {
  // 安全转换数字（处理int/double/字符串数字混合场景）
  static num? safeParseNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  // 安全日期解析（支持多种日期格式）
  static DateTime? safeParseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  // 布尔类型安全转换
  static bool safeParseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }
}
 
 
 
 
 
 
 
 
 
 
 