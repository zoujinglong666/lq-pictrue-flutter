import '../model/result.dart';
import '../net/request.dart';

class PictureLikeResult {
  final bool liked;
  final int likeCount;

  PictureLikeResult({required this.liked, required this.likeCount});

  factory PictureLikeResult.fromJson(Map<String, dynamic> json) {
    return PictureLikeResult(
      liked: json['liked'] as bool,
      likeCount: int.tryParse(json['likeCount'].toString()) ?? 0, // ✅ 安全转换
    );
  }

}

class PictureLikeApi {
  /// 图片点赞 / 取消点赞
  static Future<PictureLikeResult> pictureLikeToggle(
      Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/like/picture/toggle",
      data: data,
    );
    return result.toModel((json) => PictureLikeResult.fromJson(json));
  }
}
