

import '../Consts/index.dart';
import '../common/helper.dart';
import 'model.dart';

class Result extends Model<Result> {
  final int code;
  final String message;
  final dynamic data;

  const Result({
    required this.code,
    required this.message,
    required this.data,
  });

  /// 更方便的构造 Result 对象，
  /// 其中的 message 如果未传递的话，会尝试使用 code 码去本地国际化资源中取值，
  /// 如果依然没有取到，则默认显示 “Unknown” 作为消息内容。
  Result.of(this.code, {String? message})
      : data = null,
        message = message  ?? "Unknown";

  /// 用于判断业务是否处理成功
  bool get success => code == Consts.request.successCode;

  /// 用于判断当前响应的数据谁否是列表
  bool get isArray => !isEmpty && data is Iterable;

  /// 用于判断当时数据是否为空
  bool get isEmpty => Helper.isEmpty(data);

  /// 用于获取当前数据的条数
  int get size => isEmpty ? 0 : (isArray ? data.length : 1);

  /// 用于将返回的统一数据转换成指定的数据类型，数据类型由 [converter] 决定；
  T toModel<T>(Converter<T> converter) => converter(data);

  /// 用于将当前数据转换成指定类型的列表，具体数据类型由 [converter] 决定。
  List<T> toArray<T>(Converter<T> converter) {
    if (isEmpty) return <T>[];
    if (isArray) {
      return data.map<T>((e) => converter(e)).toList();
    }
    return <T>[converter(data)];
  }

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "message": message,
      "data": data.toString(),
    };
  }
}