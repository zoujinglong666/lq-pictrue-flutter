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
      DioExceptionType.connectionError => Result.of(StatusCode.NETWORK_ERROR,message: "网络异常，请稍后再试"),
      DioExceptionType.sendTimeout => Result.of(StatusCode.SEND_TIMEOUT,message: "网络请求超时"),
      DioExceptionType.connectionTimeout =>
          Result.of(StatusCode.CONNECTION_TIMEOUT,message: "网络请求超时"),
      DioExceptionType.receiveTimeout => Result.of(StatusCode.RECEIVE_TIMEOUT,message: "网络请求超时"),
      DioExceptionType.badCertificate => Result.of(StatusCode.BAD_CERTIFICATE,message: "证书错误"),
      DioExceptionType.badResponse => Result.of(err.response?.statusCode ?? -1,),
      DioExceptionType.cancel => Result.of(StatusCode.CANCEL_REQUEST,message: "取消请求"),
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
      return Result.of(StatusCode.DOMAIN_ERROR,message: "域名错误，请检查域名是否正确！");
    }
    return Result.of(StatusCode.UNKNOWN,message: "未知错误，请稍后再试！");
  }
}