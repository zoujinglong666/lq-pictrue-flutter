import '../common/helper.dart';
import 'model.dart';

class Page<T> extends Model<Page<T>> {
  final List<T> records;  // 修改为 List<T>
  final String total;
  final String size;
  final String current;
  final String pages;

  Page({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.pages,
  });

  bool get isEmpty => Helper.isEmpty(records);

  Page copyWith({
    List<T>? records,  // 修改为 List<T>
    String? total,
    String? size,
    String? current,
    String? pages,
  }) =>
      Page(
        records: records ?? this.records,
        total: total ?? this.total,
        size: size ?? this.size,
        current: current ?? this.current,
        pages: pages ?? this.pages,
      );

  factory Page.fromJson(Map<String, dynamic> json, Converter<T> converter) {
    final List<dynamic>? records = json["records"];
    return Page(
      total: (json["total"] ?? 0).toString(),  // 确保类型一致性
      size: (json["size"] ?? 0).toString(),    // 确保类型一致性
      current: (json["current"] ?? 0).toString(), // 确保类型一致性
      pages: (json["pages"] ?? 0).toString(),   // 确保类型一致性
      records: records?.map((e) => converter(e)).toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "records": records?.map((e) => e.toString()).toList(),
        "total": total,
        "size": size,
        "current": current,
        "pages": pages,
      };
}
