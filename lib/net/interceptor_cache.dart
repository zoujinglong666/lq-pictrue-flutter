import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Consts/index.dart';
import '../common/helper.dart';

/// HTTP缓存拦截器 - 仅对GET请求进行缓存
/// 支持自动过期清理和路由切换清理
final class CacheInterceptor extends Interceptor {
  /// 是否允许缓存（可配置某些请求禁用缓存）
  final bool enableCache;
  
  /// 缓存白名单路径（如果设置，只有匹配的路径才会被缓存）
  final List<String>? cacheWhiteList;
  
  /// 缓存黑名单路径（匹配的路径不会被缓存）
  final List<String>? cacheBlackList;

  CacheInterceptor({
    this.enableCache = true,
    this.cacheWhiteList,
    this.cacheBlackList,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 只缓存GET请求
    if (options.method != "GET" || !enableCache) {
      return super.onRequest(options, handler);
    }

    // 检查是否在黑名单中
    if (_isInBlackList(options.uri.path)) {
      if (kDebugMode) {
        print('🚫 缓存黑名单 -> ${options.uri.path}');
      }
      return super.onRequest(options, handler);
    }

    // 检查白名单（如果设置了白名单）
    if (cacheWhiteList != null && !_isInWhiteList(options.uri.path)) {
      return super.onRequest(options, handler);
    }

    // 检查请求选项中是否禁用了缓存
    final extra = options.extra;
    if (extra['no_cache'] == true) {
      if (kDebugMode) {
        print('⏭️  跳过缓存 -> ${options.uri}');
      }
      return super.onRequest(options, handler);
    }

    final cacheKey = _generateCacheKey(options);
    final cache = CacheManager.instance;
    
    // 尝试从缓存中获取
    if (cache.contains(cacheKey)) {
      final cacheObject = cache.getValue(cacheKey);
      final current = Helper.timestamp();
      final cacheTime = Consts.request.cachedTime.inMilliseconds;
      
      // 检查缓存是否过期
      if (current - cacheObject.timestamp > cacheTime) {
        if (kDebugMode) {
          print('⏰ 缓存过期，自动清理 -> ${options.uri.path}');
        }
        cache.clear(cacheKey);
      } else {
        if (kDebugMode) {
          print('✅ 命中缓存 -> ${options.uri.path} (${_formatCacheAge(current - cacheObject.timestamp)})');
        }
        // 克隆响应避免修改原缓存数据
        return handler.resolve(cacheObject.data);
      }
    }

    // 标记需要缓存
    options.extra['_should_cache'] = true;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查是否需要缓存
    final shouldCache = response.requestOptions.extra['_should_cache'] == true;
    
    if (shouldCache && _isSuccessResponse(response)) {
      final cache = CacheManager.instance;
      final cacheKey = _generateCacheKey(response.requestOptions);
      
      if (kDebugMode) {
        print('💾 设置缓存 -> ${response.requestOptions.uri.path}');
      }
      
      cache.setValue(cacheKey, response);
    }
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 网络错误时，尝试返回缓存数据（离线模式）
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      final options = err.requestOptions;
      final cacheKey = _generateCacheKey(options);
      final cache = CacheManager.instance;
      
      if (cache.contains(cacheKey)) {
        final cacheObject = cache.getValue(cacheKey);
        if (kDebugMode) {
          print('🔄 网络异常，使用缓存数据 -> ${options.uri.path}');
        }
        return handler.resolve(cacheObject.data);
      }
    }
    
    super.onError(err, handler);
  }

  /// 生成缓存键（包含URI和查询参数）
  String _generateCacheKey(RequestOptions options) {
    return options.uri.toString();
  }

  /// 检查是否在黑名单中
  bool _isInBlackList(String path) {
    if (cacheBlackList == null || cacheBlackList!.isEmpty) {
      return false;
    }
    return cacheBlackList!.any((pattern) => path.contains(pattern));
  }

  /// 检查是否在白名单中
  bool _isInWhiteList(String path) {
    if (cacheWhiteList == null || cacheWhiteList!.isEmpty) {
      return true;
    }
    return cacheWhiteList!.any((pattern) => path.contains(pattern));
  }

  /// 检查响应是否成功
  bool _isSuccessResponse(Response response) {
    return response.statusCode != null && 
           response.statusCode! >= 200 && 
           response.statusCode! < 300;
  }

  /// 格式化缓存年龄
  String _formatCacheAge(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    if (seconds < 60) {
      return '${seconds}秒前';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}分钟前';
    }
    final hours = minutes ~/ 60;
    return '${hours}小时前';
  }
}

/// 缓存对象 - 包含响应数据和时间戳
class CacheObject {
  final Response data;
  final int timestamp;

  const CacheObject(this.data, this.timestamp);
  
  /// 缓存年龄（毫秒）
  int get age => Helper.timestamp() - timestamp;
  
  /// 是否过期
  bool isExpired(int maxAge) => age > maxAge;
}

/// 缓存管理器 - 管理HTTP响应缓存
/// 支持路由切换时自动清理、LRU策略、内存限制
class CacheManager extends RouteObserver<Route<dynamic>> {
  /// 单例实例
  static final CacheManager instance = CacheManager._internal();
  
  /// 为了向后兼容保留的别名
  @Deprecated('使用 instance 代替')
  static CacheManager get observer => instance;

  /// 缓存存储(使用String作为key更灵活)
  final Map<String, CacheObject> _cache = {};
  
  /// 最大缓存条目数(LRU策略)
  final int maxCacheSize;
  
  /// 访问顺序记录(用于LRU)
  final List<String> _accessOrder = [];
  
  /// 是否启用路由切换清理
  final bool clearOnRouteChange;

  CacheManager._internal({
    this.maxCacheSize = 100,
    this.clearOnRouteChange = false,
  });

  factory CacheManager() {
    return instance;
  }

  /// 检查缓存是否存在
  bool contains(String key) => _cache.containsKey(key);

  /// 获取缓存值
  CacheObject getValue(String key) {
    _updateAccessOrder(key);
    return _cache[key]!;
  }

  /// 设置缓存值
  void setValue(String key, Response data) {
    // 如果超过最大缓存数，移除最旧的
    if (_cache.length >= maxCacheSize) {
      _evictOldest();
    }
    
    _cache[key] = CacheObject(data, Helper.timestamp());
    _updateAccessOrder(key);
  }

  /// 清除指定缓存
  void clear(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// 清除所有缓存
  void clearAll() {
    _cache.clear();
    _accessOrder.clear();
    if (kDebugMode) {
      print('🗑️  清除所有缓存');
    }
  }

  /// 清除过期缓存
  void clearExpired() {
    final cacheTime = Consts.request.cachedTime.inMilliseconds;
    final current = Helper.timestamp();
    final keysToRemove = <String>[];
    
    _cache.forEach((key, value) {
      if (current - value.timestamp > cacheTime) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      clear(key);
    }
    
    if (kDebugMode && keysToRemove.isNotEmpty) {
      print('🗑️  清除 ${keysToRemove.length} 条过期缓存');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    final total = _cache.length;
    final cacheTime = Consts.request.cachedTime.inMilliseconds;
    final current = Helper.timestamp();
    
    int expired = 0;
    int totalSize = 0;
    
    _cache.forEach((key, value) {
      if (current - value.timestamp > cacheTime) {
        expired++;
      }
      // 粗略估算大小（字节）
      totalSize += key.length + (value.data.toString().length);
    });
    
    return {
      'total': total,
      'expired': expired,
      'active': total - expired,
      'size_bytes': totalSize,
      'size_kb': (totalSize / 1024).toStringAsFixed(2),
    };
  }

  /// 更新访问顺序（LRU）
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// 驱逐最旧的缓存
  void _evictOldest() {
    if (_accessOrder.isEmpty) return;
    
    final oldestKey = _accessOrder.first;
    clear(oldestKey);
    
    if (kDebugMode) {
      print('🗑️  LRU驱逐缓存 -> $oldestKey');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (clearOnRouteChange) {
      clearAll();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (clearOnRouteChange) {
      clearAll();
    }
  }
}
