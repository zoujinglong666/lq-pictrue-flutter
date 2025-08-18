

import 'dart:convert';

PictureVO PictureVOFromJson(String str) => PictureVO.fromJson(json.decode(str));

String PictureVOToJson(PictureVO data) => json.encode(data.toJson());

class PictureVO {
  final String id;
  final String url;
  final dynamic thumbnailUrl;
  final String name;
  final dynamic introduction;
  final List<dynamic> tags;
  final dynamic category;
  final String picSize;
  final int picWidth;
  final int picHeight;
  final double picScale;
  final String picFormat;
  final dynamic picColor;
  final String userId;
  final dynamic spaceId;
  final int createTime;
  final int editTime;
  final int updateTime;
  final User user;
  final List<dynamic> permissionList;

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
    required this.permissionList,
  });

  PictureVO copyWith({
    String? id,
    String? url,
    dynamic thumbnailUrl,
    String? name,
    dynamic introduction,
    List<dynamic>? tags,
    dynamic category,
    String? picSize,
    int? picWidth,
    int? picHeight,
    double? picScale,
    String? picFormat,
    dynamic picColor,
    String? userId,
    dynamic spaceId,
    int? createTime,
    int? editTime,
    int? updateTime,
    User? user,
    List<dynamic>? permissionList,
  }) =>
      PictureVO(
        id: id ?? this.id,
        url: url ?? this.url,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        name: name ?? this.name,
        introduction: introduction ?? this.introduction,
        tags: tags ?? this.tags,
        category: category ?? this.category,
        picSize: picSize ?? this.picSize,
        picWidth: picWidth ?? this.picWidth,
        picHeight: picHeight ?? this.picHeight,
        picScale: picScale ?? this.picScale,
        picFormat: picFormat ?? this.picFormat,
        picColor: picColor ?? this.picColor,
        userId: userId ?? this.userId,
        spaceId: spaceId ?? this.spaceId,
        createTime: createTime ?? this.createTime,
        editTime: editTime ?? this.editTime,
        updateTime: updateTime ?? this.updateTime,
        user: user ?? this.user,
        permissionList: permissionList ?? this.permissionList,
      );

  factory PictureVO.fromJson(Map<String, dynamic> json) => PictureVO(
    id: json["id"],
    url: json["url"],
    thumbnailUrl: json["thumbnailUrl"],
    name: json["name"],
    introduction: json["introduction"],
    tags: List<dynamic>.from(json["tags"].map((x) => x)),
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
