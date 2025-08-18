import 'dart:io';

import 'package:dio/dio.dart';

import '../l18n/status_code_mapping.dart';
import '../model/result.dart';

final class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("Request error -> $err");

    // 已经处理过就不再处理了，防止递归调用。
    if (err.error is Result) {
      return super.onError(err, handler);
    }

    // 将每一种错误类型包装成 Result 对象
    // 这样方便我们在展示错误信息的时候直接取值，而不需要做任何判断。
    final result = switch (err.type) {
      DioExceptionType.unknown => _unknown(err),
      DioExceptionType.connectionError => Result.of(StatusCode.NETWORK_ERROR),
      DioExceptionType.sendTimeout => Result.of(StatusCode.SEND_TIMEOUT),
      DioExceptionType.connectionTimeout =>
          Result.of(StatusCode.CONNECTION_TIMEOUT),
      DioExceptionType.receiveTimeout => Result.of(StatusCode.RECEIVE_TIMEOUT),
      DioExceptionType.badCertificate => Result.of(StatusCode.BAD_CERTIFICATE),
      DioExceptionType.badResponse => Result.of(err.response?.statusCode ?? 0),
      DioExceptionType.cancel => Result.of(StatusCode.CANCEL_REQUEST),
    };

    return handler.reject(err.copyWith(
      error: result,
      message: result.message,
    ));
  }

  /// 处理未知异常
  ///
  /// 目前已知异常类型：
  /// - HandshakeException：三次握手异常，通常由于 DNS 域名错误造成的无法请求；
  Result _unknown(DioException err) {
    Object? error = err.error;
    if (error is HandshakeException) {
      return Result.of(StatusCode.DOMAIN_ERROR);
    }
    return Result.of(StatusCode.UNKNOWN);
  }
}