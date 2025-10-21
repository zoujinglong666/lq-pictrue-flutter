import 'dart:convert';

List<CommentVO> CommentVOFromJson(String str) => List<CommentVO>.from(json.decode(str).map((x) => CommentVO.fromJson(x)));

String CommentVOToJson(List<CommentVO> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CommentVO {
  String id;
  String pictureId;
  String userId;
  String content;
  int createTime;
  User user;
  List<CommentVO> replies;

  CommentVO({
    required this.id,
    required this.pictureId,
    required this.userId,
    required this.content,
    required this.createTime,
    required this.user,
    required this.replies,
  });

  factory CommentVO.fromJson(Map<String, dynamic> json) => CommentVO(
    id: json["id"],
    pictureId: json["pictureId"],
    userId: json["userId"],
    content: json["content"],
    createTime: json["createTime"],
    user: User.fromJson(json["user"]),
    replies: List<CommentVO>.from(json["replies"].map((x) => CommentVO.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pictureId": pictureId,
    "userId": userId,
    "content": content,
    "createTime": createTime,
    "user": user.toJson(),
    "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
  };
}

class User {
  String id;
  String userAccount;
  String userName;
  dynamic userAvatar;
  dynamic userProfile;
  String userRole;
  int createTime;

  User({
    required this.id,
    required this.userAccount,
    required this.userName,
    required this.userAvatar,
    required this.userProfile,
    required this.userRole,
    required this.createTime,
  });

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
