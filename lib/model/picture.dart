

import 'dart:convert';

PictureVO pictureVoFromJson(String str) => PictureVO.fromJson(json.decode(str));

String pictureVoToJson(PictureVO data) => json.encode(data.toJson());

class PictureVO {
  String id;
  String url;
  String thumbnailUrl;
  String name;
  String introduction;
  List<String> tags;
  String category;
  String picSize;
  int picWidth;
  int picHeight;
  double picScale;
  String picFormat;
  dynamic picColor;
  String userId;
  dynamic spaceId;
  int createTime;
  int editTime;
  int updateTime;
  User user;
  String likeCount;
  bool hasLiked;
  String commentCount;
  List<dynamic> permissionList;

  PictureVO({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.name,
    required this.introduction,
    required this.tags,
    required this.category,
    required this.picSize,
    required this.picWidth,
    required this.picHeight,
    required this.picScale,
    required this.picFormat,
    required this.picColor,
    required this.userId,
    required this.spaceId,
    required this.createTime,
    required this.editTime,
    required this.updateTime,
    required this.user,
    required this.likeCount,
    required this.hasLiked,
    required this.commentCount,
    required this.permissionList,
  });

  factory PictureVO.fromJson(Map<String, dynamic> json) => PictureVO(
    id: json["id"],
    url: json["url"],
    thumbnailUrl: json["thumbnailUrl"],
    name: json["name"],
    introduction: json["introduction"],
    tags: List<String>.from(json["tags"].map((x) => x)),
    category: json["category"],
    picSize: json["picSize"],
    picWidth: json["picWidth"],
    picHeight: json["picHeight"],
    picScale: json["picScale"]?.toDouble(),
    picFormat: json["picFormat"],
    picColor: json["picColor"],
    userId: json["userId"],
    spaceId: json["spaceId"],
    createTime: json["createTime"],
    editTime: json["editTime"],
    updateTime: json["updateTime"],
    user: User.fromJson(json["user"]),
    likeCount: json["likeCount"],
    hasLiked: json["hasLiked"],
    commentCount: json["commentCount"],
    permissionList: List<dynamic>.from(json["permissionList"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "thumbnailUrl": thumbnailUrl,
    "name": name,
    "introduction": introduction,
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "category": category,
    "picSize": picSize,
    "picWidth": picWidth,
    "picHeight": picHeight,
    "picScale": picScale,
    "picFormat": picFormat,
    "picColor": picColor,
    "userId": userId,
    "spaceId": spaceId,
    "createTime": createTime,
    "editTime": editTime,
    "updateTime": updateTime,
    "user": user.toJson(),
    "likeCount": likeCount,
    "hasLiked": hasLiked,
    "commentCount": commentCount,
    "permissionList": List<dynamic>.from(permissionList.map((x) => x)),
  };
}

class User {
  final String id;
  final String userAccount;
  final String userName;
  final dynamic userAvatar;
  final dynamic userProfile;
  final String userRole;
  final int createTime;

  User({
    required this.id,
    required this.userAccount,
    required this.userName,
    required this.userAvatar,
    required this.userProfile,
    required this.userRole,
    required this.createTime,
  });

  User copyWith({
    String? id,
    String? userAccount,
    String? userName,
    dynamic userAvatar,
    dynamic userProfile,
    String? userRole,
    int? createTime,
  }) =>
      User(
        id: id ?? this.id,
        userAccount: userAccount ?? this.userAccount,
        userName: userName ?? this.userName,
        userAvatar: userAvatar ?? this.userAvatar,
        userProfile: userProfile ?? this.userProfile,
        userRole: userRole ?? this.userRole,
        createTime: createTime ?? this.createTime,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    userAccount: json["userAccount"],
    userName: json["userName"],
    userAvatar: json["userAvatar"],
    userProfile: json["userProfile"],
    userRole: json["userRole"],
    createTime: json["createTime"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userAccount": userAccount,
    "userName": userName,
    "userAvatar": userAvatar,
    "userProfile": userProfile,
    "userRole": userRole,
    "createTime": createTime,
  };
}
