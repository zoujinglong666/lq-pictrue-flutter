import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../Consts/index.dart';
import '../common/helper.dart';
import '../l18n/status_code_mapping.dart';
import '../model/result.dart';
import 'interceptor_cache.dart';
import 'interceptor_error.dart';
import 'interceptor_response.dart';

final class Http {
  late final Dio _dio;

  static Http? _instance;
  factory Http() => _instance ??= Http._();

  Http._() {
    _dio = Dio(BaseOptions(
      baseUrl: Consts.request.baseUrl,
      headers: {"version": "1.0.0", "flutter": "3.10.0"},
      sendTimeout: Consts.request.sendTimeout,
      connectTimeout: Consts.request.connectTimeout,
      receiveTimeout: Consts.request.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));

    // Log printer
    _dio.interceptors.add(PrettyDioLogger(
      enabled: true, // 启用
      request: false, // 不打印请求信息
      requestHeader: false, // 不打印请求头
      requestBody: false, // 不打印请求体
      responseHeader: false, // 不打印响应头
      responseBody: false, // 不打印响应体
    ));

    // Interceptor
    _dio.interceptors.add(CacheInterceptor());
    _dio.interceptors.add(ResponseInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// 提供外部访问集中设置过的 dio 实例
  static Dio get dio => Http()._dio;

  /// 在不同环境下加载不同的请求基础路径
  static void changeBaseUrl(String url) => dio.options.baseUrl = url;

  /// 重置基础路径
  static void resetBaseUrl() => changeBaseUrl(Consts.request.baseUrl);

  static Future<T> get<T>(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return _fetch(
      delay,
      dio.get<T>(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  static Future<T> post<T>(
      String path, {
        Object? data,
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return _fetch(
      delay,
      dio.post<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  static Future<T> put<T>(
      String path, {
        Object? data,
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return _fetch(
      delay,
      dio.put<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  static Future<T> delete<T>(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return _fetch(
      delay,
      dio.delete<T>(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  static Future<T> head<T>(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return _fetch(
      delay,
      dio.head<T>(
        path,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }
  /// ✅ 动态设置请求头（比如 token）
  static void setToken(String token) {
    dio.options.headers["satoken"] = "Bearer $token";
    // 或者如果你后端要求 satoken
    // dio.options.headers["satoken"] = "Bearer $token";
  }

  /// 清除 token
  static void clearToken() {
    dio.options.headers.remove("Authorization");
    dio.options.headers.remove("satoken");
  }
  /// 统一处理请求的响应内容，比如：数据提取、异常捕获等等；
  static Future<T> _fetch<T>(Duration? delay, Future<Response> future) {
    final start = Helper.timestamp();
    return future.then<T>((resp) {
      // 为了避免网络速度过快导致的加载动画一闪而过
      // 延迟指定时间可以更好的展示加载动画
      // 当然了，如果时间大于指定的时间，则不会进行等待，仅当过快时才会延迟等待时间。
      final usedTime = Helper.timestamp() - start;
      final waitingTime = Consts.request.minWaitingTime.inMilliseconds;
      if (delay == null || usedTime > waitingTime) {
        return resp.data!;
      }
      final remaining = Duration(milliseconds: waitingTime - usedTime);
      return Future.delayed(remaining, () => resp.data!);
    }).catchError((err) {
      // 统一捕获异常信息并集中信息提示
      Result result;
      if (err is DioException && err.error is Result) {
        result = err.error as Result;
      } else {
        result = Result.of(StatusCode.UNKNOWN, message: err.toString());
      }
      // 你可以统一进行错误提示，比如使用 Toast 进行展示。
      print("统一异常：$result");
      // Toast.showMessage(result.message);

      // 使用 throw 关键字可以将错误信息抛出
      // 这样后续调用者还可以继续处理此错误，不然其他地方将收不到任何异常信息；
      throw result;
    });
  }
}