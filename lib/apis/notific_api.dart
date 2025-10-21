import '../model/notify.dart';
import '../model/page.dart';
import '../model/result.dart';
import '../net/request.dart';

class NotifyApi {
  /// 获取图片列表
  static Future<Page<NotifyVO>> getList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/notify/list/page/vo",
      data: data,
    );

    return result.toModel((json) => Page.fromJson(json, (item) => NotifyVO.fromJson(item)));
  }


}
