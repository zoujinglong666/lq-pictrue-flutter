
import '../model/notify.dart';
import '../model/page.dart';
import '../model/result.dart';
import '../net/request.dart';

class NotifyApi {
  /// 获取通知列表
  static Future<Page<NotifyVO>> getList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/notify/list/page/vo",
      data: data,
    );

    return result.toModel(
        (json) => Page.fromJson(json, (item) => NotifyVO.fromJson(item)));
  }

  /// 标记单个通知为已读
  static Future<bool> markRead(int id) async {
    final result = await Http.post<Result>(
      "/notify/read/$id",
    );

    return result.data == true;
  }

  /// 标记所有通知为已读
  static Future<bool> markAllRead() async {
    final result = await Http.post<Result>(
      "/notify/read/all",
    );

    return result.data == true;
  }

  static Future<bool> deleteNotify(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/notify/delete",
      data: data,
    );
    return result.data == true;
  }

  /// 获取未读消息数量
  static Future<String> countUnread() async {
    final result = await Http.get<Result>(
      "/notify/count/unread",
    );
    return result.data;
  }

  /// 获取未读消息数量
  static Future<bool> unsubscribe() async {
    final result = await Http.post<Result>(
      "/notify/unsubscribe",
    );
    return result.data == true;
  }
}
