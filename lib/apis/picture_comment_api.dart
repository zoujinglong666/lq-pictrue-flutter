import '../model/comment.dart';
import '../model/page.dart';
import '../model/result.dart';
import '../model/add_comment_request.dart';
import '../net/request.dart';

class PictureCommentApi {
  static Future<String> addPictureComment(AddCommentRequest request) async {
    // 参数验证
    if (!request.validate()) {
      throw Exception('评论内容不合法');
    }

    final result = await Http.post<Result>(
      "/comment/add",
      data: request.toJson(),
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
