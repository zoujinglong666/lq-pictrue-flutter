import '../model/comment.dart';
import '../model/page.dart';
import '../model/result.dart';
import '../net/request.dart';
class PictureCommentApi {
  static Future<String> addPictureComment(
      Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/comment/add",
      data: data,
    );
    return result.modelToString();
  }
  static Future<Page<CommentVO>> getCommentList(
      Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/comment/list/page/vo",
      data: data,
    );
    return result.toModel((json) => Page.fromJson(json, (item) => CommentVO.fromJson(item)));
  }
}
