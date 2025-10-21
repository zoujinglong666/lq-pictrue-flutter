import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lq_picture/model/picture.dart';

import '../model/page.dart';
import '../model/result.dart';
import '../net/request.dart';
class PictureUploadVO {
  String? id;
  String? url;
  String? thumbnailUrl;
  String? name;
  String? introduction;
  List<dynamic>? tags;
  dynamic category;
  String? picSize;
  int? picWidth;
  int? picHeight;
  double? picScale;
  String? picFormat;
  String? picColor;
  String? userId;
  String? spaceId;
  dynamic createTime;
  dynamic editTime;
  dynamic updateTime;
  dynamic user;
  List<dynamic>? permissionList;

  PictureUploadVO({
    this.id,
    this.url,
    this.thumbnailUrl,
    this.name,
    this.introduction,
    this.tags,
    this.category,
    this.picSize,
    this.picWidth,
    this.picHeight,
    this.picScale,
    this.picFormat,
    this.picColor,
    this.userId,
    this.spaceId,
    this.createTime,
    this.editTime,
    this.updateTime,
    this.user,
    this.permissionList,
  });

  factory PictureUploadVO.fromJson(Map<String, dynamic> json) {
    return PictureUploadVO(
      id: json['id'] as String?,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      name: json['name'] as String?,
      introduction: json['introduction'] as String?,
      tags: json['tags'] as List<dynamic>?,
      category: json['category'],
      picSize: json['picSize'] as String?,
      picWidth: json['picWidth'] as int?,
      picHeight: json['picHeight'] as int?,
      picScale: (json['picScale'] as num?)?.toDouble(),
      picFormat: json['picFormat'] as String?,
      picColor: json['picColor'] as String?,
      userId: json['userId'] as String?,
      spaceId: json['spaceId'] as String?,
      createTime: json['createTime'],
      editTime: json['editTime'],
      updateTime: json['updateTime'],
      user: json['user'],
      permissionList: json['permissionList'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['thumbnailUrl'] = thumbnailUrl;
    data['name'] = name;
    data['introduction'] = introduction;
    data['tags'] = tags;
    data['category'] = category;
    data['picSize'] = picSize;
    data['picWidth'] = picWidth;
    data['picHeight'] = picHeight;
    data['picScale'] = picScale;
    data['picFormat'] = picFormat;
    data['picColor'] = picColor;
    data['userId'] = userId;
    data['spaceId'] = spaceId;
    data['createTime'] = createTime;
    data['editTime'] = editTime;
    data['updateTime'] = updateTime;
    data['user'] = user;
    data['permissionList'] = permissionList;
    return data;
  }
}
PictureItem pictureItemFromJson(String str) => PictureItem.fromJson(json.decode(str));

String pictureItemToJson(PictureItem data) => json.encode(data.toJson());

class PictureItem {
  final String id;
  final String url;
  final dynamic thumbnailUrl;
  final String name;
  final dynamic introduction;
  final dynamic category;
  final dynamic tags;
  final String picSize;
  final int picWidth;
  final int picHeight;
  final double picScale;
  final String picFormat;
  final String userId;
  final dynamic spaceId;
  final int reviewStatus;
  final dynamic reviewMessage;
  final String reviewerId;
  final DateTime reviewTime;
  final DateTime createTime;
  final DateTime editTime;
  final DateTime updateTime;
  final int isDelete;
  final int likeCount;
  final bool hasLiked;
  final int commentCount;

  PictureItem({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.name,
    required this.introduction,
    required this.category,
    required this.tags,
    required this.picSize,
    required this.picWidth,
    required this.picHeight,
    required this.picScale,
    required this.picFormat,
    required this.userId,
    required this.spaceId,
    required this.reviewStatus,
    required this.reviewMessage,
    required this.reviewerId,
    required this.reviewTime,
    required this.createTime,
    required this.editTime,
    required this.updateTime,
    required this.isDelete,
    required this.likeCount,
    required this.hasLiked,
    required this.commentCount,
  });
// 在 PictureItem 类中添加以下静态辅助方法
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  PictureItem copyWith({
    String? id,
    String? url,
    dynamic thumbnailUrl,
    String? name,
    dynamic introduction,
    dynamic category,
    dynamic tags,
    String? picSize,
    int? picWidth,
    int? picHeight,
    double? picScale,
    String? picFormat,
    String? userId,
    dynamic spaceId,
    int? reviewStatus,
    dynamic reviewMessage,
    String? reviewerId,
    DateTime? reviewTime,
    DateTime? createTime,
    DateTime? editTime,
    DateTime? updateTime,
    int? isDelete,
    int? likeCount,
    bool? hasLiked,
    int? commentCount,

  }) =>
      PictureItem(
        id: id ?? this.id,
        url: url ?? this.url,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        name: name ?? this.name,
        introduction: introduction ?? this.introduction,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        picSize: picSize ?? this.picSize,
        picWidth: picWidth ?? this.picWidth,
        picHeight: picHeight ?? this.picHeight,
        picScale: picScale ?? this.picScale,
        picFormat: picFormat ?? this.picFormat,
        userId: userId ?? this.userId,
        spaceId: spaceId ?? this.spaceId,
        reviewStatus: reviewStatus ?? this.reviewStatus,
        reviewMessage: reviewMessage ?? this.reviewMessage,
        reviewerId: reviewerId ?? this.reviewerId,
        reviewTime: reviewTime ?? this.reviewTime,
        createTime: createTime ?? this.createTime,
        editTime: editTime ?? this.editTime,
        updateTime: updateTime ?? this.updateTime,
        isDelete: isDelete ?? this.isDelete,
        commentCount: commentCount??this.commentCount,
        hasLiked: hasLiked??this.hasLiked,
        likeCount: likeCount??this.likeCount,
      );

factory PictureItem.fromJson(Map<String, dynamic> json) => PictureItem(
  id: json["id"],
  url: json["url"],
  thumbnailUrl: json["thumbnailUrl"],
  name: json["name"],
  introduction: json["introduction"],
  category: json["category"],
  tags: json["tags"],
  picSize: json["picSize"],
  picWidth: _toInt(json["picWidth"]) ?? 0,
  picHeight: _toInt(json["picHeight"]) ?? 0,
  picScale: _toDouble(json["picScale"]) ?? 0.0,
  picFormat: json["picFormat"],
  userId: json["userId"],
  spaceId: json["spaceId"],
  reviewStatus: _toInt(json["reviewStatus"]) ?? 0,
  reviewMessage: json["reviewMessage"],
  reviewerId: json["reviewerId"] ?? "",
  reviewTime: json["reviewTime"] != null
      ? DateTime.fromMillisecondsSinceEpoch(_toInt(json["reviewTime"]) ?? 0)
      : DateTime.now(),
  createTime: json["createTime"] != null
      ? DateTime.fromMillisecondsSinceEpoch(_toInt(json["createTime"]) ?? 0)
      : DateTime.now(),
  editTime: json["editTime"] != null
      ? DateTime.fromMillisecondsSinceEpoch(_toInt(json["editTime"]) ?? 0)
      : DateTime.now(),
  updateTime: json["updateTime"] != null
      ? DateTime.fromMillisecondsSinceEpoch(_toInt(json["updateTime"]) ?? 0)
      : DateTime.now(),
  isDelete: _toInt(json["isDelete"]) ?? 0,
  likeCount: _toInt(json["likeCount"]) ?? 0,
  hasLiked: json["hasLiked"] as bool? ?? false,
  commentCount: _toInt(json["commentCount"]) ?? 0,
);




  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "thumbnailUrl": thumbnailUrl,
    "name": name,
    "introduction": introduction,
    "category": category,
    "tags": tags,
    "picSize": picSize,
    "picWidth": picWidth,
    "picHeight": picHeight,
    "picScale": picScale,
    "picFormat": picFormat,
    "userId": userId,
    "spaceId": spaceId,
    "reviewStatus": reviewStatus,
    "reviewMessage": reviewMessage,
    "reviewerId": reviewerId,
    "reviewTime": reviewTime.millisecondsSinceEpoch,
    "createTime": createTime.millisecondsSinceEpoch,
    "editTime": editTime.millisecondsSinceEpoch,
    "updateTime": updateTime.millisecondsSinceEpoch,
    "isDelete": isDelete,
    "likeCount": likeCount,
    "hasLiked": hasLiked,
    "commentCount": commentCount,
  };
}
class PictureApi {
  /// 获取图片列表
  static Future<Page<PictureVO>> getList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/picture/list/page/vo",
      data: data,
    );

    return result.toModel((json) => Page.fromJson(json, (item) => PictureVO.fromJson(item)));
  }

  static Future<PictureUploadVO> uploadPictureByUrl(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/picture/upload/url",
      data: data,
    );

    return  result.toModel((json) => PictureUploadVO.fromJson(json));
  }



  static Future<Page<PictureItem>> getAllList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/picture/list/page",
      data: data,
    );

    return result.toModel((json) => Page.fromJson(json, (item) => PictureItem.fromJson(item)));
  }

  static Future<Page<PictureVO>> getMyLikes(Map<String, dynamic> data) async {
    final result = await Http.get<Result>(
      "/picture/my/likes/v4",
      query: data,
    );
    return result.toModel((json) => Page.fromJson(json, (item) => PictureVO.fromJson(item)));
  }

  static Future<Page<PictureItem>> getReviewStatusList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/picture/review/list/page/vo",
      data: data,
    );
    return result.toModel((json) => Page.fromJson(json, (item) => PictureItem.fromJson(item)));
  }
static Future<bool> editPicture(Map<String, dynamic> data) async {
  final result = await Http.post<Result>(
    "/picture/edit",
    data: data,
  );

  // 直接访问 data 字段中的布尔值
  try {
    if (result.data is Map<String, dynamic>) {
      return (result.data as Map<String, dynamic>)['data'] as bool? ?? false;
    }
    return result.data as bool? ?? false;
  } catch (e) {
    print('解析编辑响应错误: $e');
    return false;
  }
}

  static Future<bool> reviewPicture(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/picture/review",
      data: data,
    );

    // 直接访问 data 字段中的布尔值
    try {
      if (result.data is Map<String, dynamic>) {
        return (result.data as Map<String, dynamic>)['data'] as bool? ?? false;
      }
      return result.data as bool? ?? false;
    } catch (e) {
      print('解析编辑响应错误: $e');
      return false;
    }
  }



  /// 上传图片
  static Future<PictureUploadVO> uploadPicture({
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    List<File>? files,
  }) async {
    try {
      // 如果有文件，使用 FormData 进行文件上传
      if (files != null && files.isNotEmpty) {
        final formData = FormData();
        
        // 添加文件
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'file', // 后端接收文件的字段名
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ));
        }
        
        // 添加其他字段
        if (body != null) {
          body.forEach((key, value) {
            if (value != null) {
              formData.fields.add(MapEntry(key, value.toString()));
            }
          });
        }
        
        final result = await Http.post<Result>(
          "/picture/upload",
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );
        return result.toModel((json) => PictureUploadVO.fromJson(json));
      } else {
        // 没有文件的情况（比如URL上传）
        final requestData = <String, dynamic>{};
        
        if (params != null) {
          requestData.addAll(params);
        }
        
        if (body != null) {
          requestData.addAll(body);
        }
        
        final result = await Http.post<Result>(
          "/picture/upload",
          data: requestData,
        );
        return result.toModel((json) => PictureUploadVO.fromJson(json));
      }
    } catch (e) {
      print('上传API错误: $e');
      rethrow;
    }
  }






}
