
import 'package:lq_picture/model/picture.dart';

import '../model/page.dart';
import '../model/result.dart';
import '../net/request.dart';
import 'dart:convert';

SpaceVO SpaceVOFromJson(String str) => SpaceVO.fromJson(json.decode(str));

String SpaceVOToJson(SpaceVO data) => json.encode(data.toJson());

class SpaceVO {
  final String id;
  final String spaceName;
  final int spaceLevel;
  final dynamic spaceType;
  final String maxSize;
  final String maxCount;
  final String totalSize;
  final String totalCount;
  final String userId;
  final int createTime;
  final int editTime;
  final int updateTime;
  final User user;
  final List<dynamic> permissionList;

  SpaceVO({
    required this.id,
    required this.spaceName,
    required this.spaceLevel,
    required this.spaceType,
    required this.maxSize,
    required this.maxCount,
    required this.totalSize,
    required this.totalCount,
    required this.userId,
    required this.createTime,
    required this.editTime,
    required this.updateTime,
    required this.user,
    required this.permissionList,
  });

  SpaceVO copyWith({
    String? id,
    String? spaceName,
    int? spaceLevel,
    dynamic spaceType,
    String? maxSize,
    String? maxCount,
    String? totalSize,
    String? totalCount,
    String? userId,
    int? createTime,
    int? editTime,
    int? updateTime,
    User? user,
    List<dynamic>? permissionList,
  }) =>
      SpaceVO(
        id: id ?? this.id,
        spaceName: spaceName ?? this.spaceName,
        spaceLevel: spaceLevel ?? this.spaceLevel,
        spaceType: spaceType ?? this.spaceType,
        maxSize: maxSize ?? this.maxSize,
        maxCount: maxCount ?? this.maxCount,
        totalSize: totalSize ?? this.totalSize,
        totalCount: totalCount ?? this.totalCount,
        userId: userId ?? this.userId,
        createTime: createTime ?? this.createTime,
        editTime: editTime ?? this.editTime,
        updateTime: updateTime ?? this.updateTime,
        user: user ?? this.user,
        permissionList: permissionList ?? this.permissionList,
      );

  factory SpaceVO.fromJson(Map<String, dynamic> json) => SpaceVO(
    id: json["id"] ?? "",
    spaceName: json["spaceName"] ?? "",
    spaceLevel: json["spaceLevel"] ?? 0,
    spaceType: json["spaceType"],
    maxSize: json["maxSize"] ?? "0",
    maxCount: json["maxCount"] ?? "0",
    totalSize: json["totalSize"] ?? "0",
    totalCount: json["totalCount"] ?? "0",
    userId: json["userId"] ?? "",
    createTime: json["createTime"] ?? 0,
    editTime: json["editTime"] ?? 0,
    updateTime: json["updateTime"] ?? 0,
    user: User.fromJson(json["user"]),
    permissionList: List<dynamic>.from(json["permissionList"]?.map((x) => x) ?? []),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "spaceName": spaceName,
    "spaceLevel": spaceLevel,
    "spaceType": spaceType,
    "maxSize": maxSize,
    "maxCount": maxCount,
    "totalSize": totalSize,
    "totalCount": totalCount,
    "userId": userId,
    "createTime": createTime,
    "editTime": editTime,
    "updateTime": updateTime,
    "user": user.toJson(),
    "permissionList": List<dynamic>.from(permissionList.map((x) => x)),
  };

  /// ✅ 提供一个空对象，避免 null 崩溃
  factory SpaceVO.empty() => SpaceVO(
    id: "",
    spaceName: "",
    spaceLevel: 0,
    spaceType: null,
    maxSize: "0",
    maxCount: "0",
    totalSize: "0",
    totalCount: "0",
    userId: "",
    createTime: 0,
    editTime: 0,
    updateTime: 0,
    user: User.empty(),
    permissionList: [],
  );
}

class User {
  final String id;
  final String userAccount;
  final String userName;
  final dynamic userAvatar;
  final String userProfile;
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
  /// ✅ 提供一个空对象
  factory User.empty() => User(
    id: "",
    userAccount: "",
    userName: "",
    userAvatar: null,
    userProfile: "",
    userRole: "",
    createTime: 0,
  );
  User copyWith({
    String? id,
    String? userAccount,
    String? userName,
    dynamic userAvatar,
    String? userProfile,
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
    id: json["id"] ?? "",
    userAccount: json["userAccount"] ?? "",
    userName: json["userName"] ?? "",
    userAvatar: json["userAvatar"],
    userProfile: json["userProfile"] ?? "",
    userRole: json["userRole"] ?? "",
    createTime: json["createTime"] ?? 0,
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

// To parse this JSON data, do
//
//     final spaceItem = spaceItemFromJson(jsonString);


SpaceItem spaceItemFromJson(String str) => SpaceItem.fromJson(json.decode(str));

String spaceItemToJson(SpaceItem data) => json.encode(data.toJson());

class SpaceItem {
  final String id;
  final String spaceName;
  final int spaceLevel;
  final String maxSize;
  final String maxCount;
  final String totalSize;
  final String totalCount;
  final String userId;
  final int createTime;
  final int editTime;
  final int updateTime;
  final int isDelete;

  SpaceItem({
    required this.id,
    required this.spaceName,
    required this.spaceLevel,
    required this.maxSize,
    required this.maxCount,
    required this.totalSize,
    required this.totalCount,
    required this.userId,
    required this.createTime,
    required this.editTime,
    required this.updateTime,
    required this.isDelete,
  });

  SpaceItem copyWith({
    String? id,
    String? spaceName,
    int? spaceLevel,
    String? maxSize,
    String? maxCount,
    String? totalSize,
    String? totalCount,
    String? userId,
    int? createTime,
    int? editTime,
    int? updateTime,
    int? isDelete,
  }) =>
      SpaceItem(
        id: id ?? this.id,
        spaceName: spaceName ?? this.spaceName,
        spaceLevel: spaceLevel ?? this.spaceLevel,
        maxSize: maxSize ?? this.maxSize,
        maxCount: maxCount ?? this.maxCount,
        totalSize: totalSize ?? this.totalSize,
        totalCount: totalCount ?? this.totalCount,
        userId: userId ?? this.userId,
        createTime: createTime ?? this.createTime,
        editTime: editTime ?? this.editTime,
        updateTime: updateTime ?? this.updateTime,
        isDelete: isDelete ?? this.isDelete,
      );

  factory SpaceItem.fromJson(Map<String, dynamic> json) => SpaceItem(
    id: json["id"],
    spaceName: json["spaceName"],
    spaceLevel: json["spaceLevel"],
    maxSize: json["maxSize"],
    maxCount: json["maxCount"],
    totalSize: json["totalSize"],
    totalCount: json["totalCount"],
    userId: json["userId"],
    createTime: json["createTime"],
    editTime: json["editTime"],
    updateTime: json["updateTime"],
    isDelete: json["isDelete"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "spaceName": spaceName,
    "spaceLevel": spaceLevel,
    "maxSize": maxSize,
    "maxCount": maxCount,
    "totalSize": totalSize,
    "totalCount": totalCount,
    "userId": userId,
    "createTime": createTime,
    "editTime": editTime,
    "updateTime": updateTime,
    "isDelete": isDelete,
  };
}


class SpaceApi {
  static Future<Page<SpaceVO>> getList(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/space/list/page/vo",
      data: data,
    );

    return result.toModel((json) => Page.fromJson(json, (item) => SpaceVO.fromJson(item)));
  }
  static Future<Result> addSpace(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/space/create",
      data: data,
    );

    return result;
  }
  static Future<SpaceVO> updateSpace(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/space/update",
      data: data,
    );
    return result.toModel((json) => SpaceVO.fromJson(json));
  }
  static Future<Page<SpaceItem>> getSpaceListPage(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/space/list/page",
      data: data,
    );

    return result.toModel((json) => Page.fromJson(json, (item) => SpaceItem.fromJson(item)));
  }

}
