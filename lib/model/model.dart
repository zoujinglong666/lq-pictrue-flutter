import 'dart:convert';

/// 类型转换器，提供将 JSON 数据转换指定类型的实体
typedef Converter<T> = T Function(Map<String, dynamic>);

abstract class Model<T extends Model<T>> {
  const Model();

  /// 为了访问模型实例的 id，具体数据类型由你的业务决定，
  /// 这主要用于通用方法中获取模型类的 id 使用的。
  String get id => "0";

  Map<String, dynamic> toJson();

  @override
  String toString() => json.encode(this);
}