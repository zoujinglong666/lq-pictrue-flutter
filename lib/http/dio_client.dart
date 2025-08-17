import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import '../Consts/index.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/loading_interceptor.dart';
import 'interceptors/token_interceptor.dart';
import 'interceptors/adapter_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: Consts.request.baseUrl,
      connectTimeout: Consts.request.connectTimeout,
      receiveTimeout: Consts.request.receiveTimeout,
      headers: {'Accept': 'application/json', 'version': '1.0.0'},
    );

    dio = Dio(options);
    // 配置缓存拦截器

    /// 在不同环境下加载不同的请求基础路径
    void changeBaseUrl(String url) => dio.options.baseUrl = url;

    /// 重置基础路径
    void resetBaseUrl() => changeBaseUrl(Consts.request.baseUrl);
    dio.interceptors.addAll([
      AdapterInterceptorHandler(),
      LogInterceptorHandler(),
      LoadingInterceptorHandler(),
      TokenInterceptorHandler(dio),
    ]);

    dio.httpClientAdapter =
        DefaultHttpClientAdapter()
          ..onHttpClientCreate = (client) {
            client.findProxy = (uri) => "DIRECT";
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          };
  }


}
