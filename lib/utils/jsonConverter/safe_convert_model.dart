/// @author: jiangjunhui
/// @date: 2025/2/18
library;

import 'package:flutter/foundation.dart';
import 'json_type_adapter.dart';

abstract class SafeConvertModel {
  T safeConvert<T>(dynamic value, T defaultValue, [Function? customConverter]) {
    try {
      if (value == null) return defaultValue;
      if (customConverter != null) {
        return customConverter(value) as T;
      }
      // 默认类型处理
      if (T == int) {
        return JsonTypeAdapter.safeParseNumber(value)?.toInt() as T;
      } else if (T == double) {
        return JsonTypeAdapter.safeParseNumber(value)?.toDouble() as T;
      } else if (T == DateTime) {
        return JsonTypeAdapter.safeParseDate(value) as T;
      } else if (T == bool) {
        return JsonTypeAdapter.safeParseBool(value) as T;
      }

      return value as T;
    } catch (e, stack) {
      _logError(e, stack);
      return defaultValue;
    }
  }

  void _logError(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('''
    ======== JSON 解析错误 ========
    错误类型: ${error.runtimeType}
    错误信息: $error
    堆栈跟踪:
    $stack
    ==============================
    ''');
    }
  }
}
 
 
 
 
 
 
 
 
 
 
 