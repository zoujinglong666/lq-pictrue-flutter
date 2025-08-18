import 'dart:ui';

import 'package:lq_picture/model/picture.dart';

import '../model/page.dart';
import '../model/result.dart';
import '../net/request.dart';

class PictureApi {
  /// 获取图片列表
  static Future<Page<PictureVO>> getList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/picture/list/page/vo",
      data: data,
    );

    return result.toModel((json) => Page.fromJson(json, (item) => PictureVO.fromJson(item)));
  }
}
