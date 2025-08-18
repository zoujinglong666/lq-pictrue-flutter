import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../Consts/index.dart';
import '../common/helper.dart';

final class CacheInterceptor extends Interceptor {
  bool isCaching = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method != "GET") {
      return super.onRequest(options, handler);
    }
    isCaching = false;

    final cacheKey = options.uri;
    final cache = CacheManager.observer;
    if (cache.contains(cacheKey)) {
      print("命中缓存 -> $cacheKey");
      final cacheObject = cache.getValue(cacheKey);
      final current = Helper.timestamp();
      final cacheTime = Consts.request.cachedTime.inMilliseconds;
      if (current - cacheObject.timestamp > cacheTime) {
        print("缓存超时，自动清理 -> $cacheKey");
        cache.clear(cacheKey);
        return super.onRequest(options, handler);
      }
      return handler.resolve(cacheObject.data);
    }

    isCaching = true;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isCaching) {
      final cache = CacheManager.observer;
      final options = response.requestOptions;
      final cacheKey = options.uri;
      print("设置缓存 -> $cacheKey");
      cache.setValue(cacheKey, response);
    }
    super.onResponse(response, handler);
  }
}

class CacheObject {
  final Response data;
  final int timestamp;

  const CacheObject(this.data, this.timestamp);
}

class CacheManager extends RouteObserver<Route<dynamic>> {
  CacheManager._();

  static final CacheManager observer = CacheManager._();

  final cached = <Uri, CacheObject>{};

  bool contains(Uri key) => cached.containsKey(key);

  CacheObject getValue(Uri key) => cached[key]!;

  void setValue(Uri key, Response data) =>
      cached[key] = CacheObject(data, Helper.timestamp());

  void clear(Uri key) => cached.remove(key);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    cached.clear();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    cached.clear();
  }
}
