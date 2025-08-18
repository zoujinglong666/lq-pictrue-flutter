import 'package:dio/dio.dart';
import 'package:lq_picture/net/request.dart';

import '../model/model.dart';
import '../model/result.dart';

class HttpApi<M extends Model<M>> {
  final Converter<M> converter;
  const HttpApi(this.converter);

  Future<M> get(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return Http.get<Result>(
      path,
      query: query,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    ).then((res) => res.toModel(converter)); // 统一转换成 Model 类
  }

  Future<List<M>> getList(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) {
    return Http.get<Result>(
      path,
      query: query,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    ).then((res) => res.toArray(converter)); // 转换成 Model 列表
  }

  // Future<Pager<M>> getPageList(
  //     String path, {
  //       Duration? delay,
  //       Map<String, dynamic>? query,
  //       Options? options,
  //       CancelToken? cancelToken,
  //       ProgressCallback? onReceiveProgress,
  //     }) {
  //   return Http.get<Result>(
  //     path,
  //     query: query,
  //     options: options,
  //     cancelToken: cancelToken,
  //     onReceiveProgress: onReceiveProgress,
  //   ).then((res) => res.toModel((data) => Pager<M>.fromJson(data, converter)));
  // }

  Future<bool> post(
      String path, {
        Object? data,
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return Http.post<Result>(
      path,
      data: _dataExpand(data),
      query: query,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ).then((res) => res.success);
  }

  Future<bool> put(
      String path, {
        Object? data,
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return Http.put<Result>(
      path,
      data: _dataExpand(data),
      query: query,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ).then((res) => res.success);
  }

  Future<bool> delete(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return Http.delete<Result>(
      path,
      query: query,
      options: options,
      cancelToken: cancelToken,
    ).then((res) => res.success);
  }

  Future<bool> head(
      String path, {
        Duration? delay,
        Map<String, dynamic>? query,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return Http.head<Result>(
      path,
      query: query,
      options: options,
      cancelToken: cancelToken,
    ).then((res) => res.success);
  }

  static Object? _dataExpand(Object? data) {
    return data == null ? null : (data is Model ? data.toJson() : data);
  }
}