// user_dto.dart
import 'dart:io';

import 'package:dio/dio.dart';

import '../model/result.dart';
import '../model/user.dart';
import '../net/request.dart';

class UserDto {
  String? id;
  String? userName;
  String? userAccount;
  String? userAvatar;
  String? userProfile;
  String? userRole;
  String? token;
  DateTime? createTime;
  DateTime? updateTime;
  DateTime? editTime;

  UserDto({
    this.id,
    this.userName,
    this.userAccount,
    this.userAvatar,
    this.userProfile,
    this.userRole,
    this.token,
    this.createTime,
    this.updateTime,
    this.editTime,
  });

 factory UserDto.fromJson(Map<String, dynamic> json) {
  return UserDto(
    id: json['id'] as String?,
    userName: json['userName'] as String?,
    userAccount: json['userAccount'] as String?,
    userAvatar: json['userAvatar'] as String?,
    userProfile: json['userProfile'] as String?,
    userRole: json['userRole'] as String?,
    token: json['token'] as String?,
    createTime: json['createTime'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['createTime'] as int),
    updateTime: json['updateTime'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['updateTime'] as int),
    editTime: json['editTime'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['editTime'] as int),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAccount': userAccount,
      'userAvatar': userAvatar,
      'userProfile': userProfile,
      'userRole': userRole,
      'token': token,
      'createTime': createTime?.millisecondsSinceEpoch,
      'updateTime': updateTime?.millisecondsSinceEpoch,
      'editTime': editTime?.millisecondsSinceEpoch,
    };
  }

}


class UserApi {


  /// 用户登录
  static Future<LoginUserVO> userLogin(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/user/login",
      data: data,
    );
    return result.toModel((json) => LoginUserVO.fromJson(json));
  }

  /// 用户注册

  static Future<String> userRegister(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/user/register",
      data: data,
    );
    return result.modelToString();
  }



  static Future<bool> userLogout() async {
    final result = await Http.post<Result>(
      "/user/logout",
    );
    return result.toBoolean() ;
  }

  /// 获取当前用户信息
  static Future<UserDto> getCurrentUser() async {
    final result = await Http.get<Result>("/user/get/login");
    return result.toModel((json) => UserDto.fromJson(json));
  }

  /// 获取用户列表
  static Future<List<UserDto>> getUserList({int page = 1, int perPage = 10}) async {
    final result = await Http.get<Result>(
      "/users",
      query: {
        'page': page,
        'per_page': perPage,
      },
    );
    return result.toArray((json) => UserDto.fromJson(json));
  }

  /// 根据ID获取用户详情
  static Future<UserDto> getUserById(String id) async {
    final result = await Http.get<Result>("/users/$id");
    return result.toModel((json) => UserDto.fromJson(json));
  }

  /// 更新用户信息
  static Future<bool> updateUser(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/user/update/info",
      data: data,
    );
    return result.success;
  }

  /// 删除用户
  static Future<bool> deleteUser(String id) async {
    final result = await Http.delete<Result>("/users/$id");
    return result.success;
  }

  /// 上传用户头像
  static Future<String> uploadAvatar(File file) async {
    try {
      final formData = FormData();

      // 添加文件，字段名必须为 'file'
      final fileName = file.path.split('/').last;
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      ));

      final result = await Http.post<Result>(
        "/user/avatar/upload",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return result.modelToString();
    } catch (e) {
      print('头像上传错误: $e');
      rethrow;
    }
  }

}
