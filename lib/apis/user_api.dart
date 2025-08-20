// user_dto.dart
import '../model/result.dart';
import '../model/user.dart';
import '../net/request.dart';

class UserDto {
  int? id;
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
      id: json['id'] as int?,
      userName: json['userName'] as String?,
      userAccount: json['userAccount'] as String?,
      userAvatar: json['userAvatar'] as String?,
      userProfile: json['userProfile'] as String?,
      userRole: json['userRole'] as String?,
      token: json['token'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      editTime: json['editTime'] == null
          ? null
          : DateTime.parse(json['editTime'] as String),
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
      'createTime': createTime?.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'editTime': editTime?.toIso8601String(),
    };
  }
}


class UserApi {
  /// 用户注册
  static Future<UserDto> userRegister(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/auth/register",
      data: data,
    );
    return result.toModel((json) => UserDto.fromJson(json));
  }

  /// 用户登录
  static Future<LoginUserVO> userLogin(Map<String, dynamic> data) async {
    final result = await Http.post<Result>(
      "/user/login",
      data: data,
    );
    return result.toModel((json) => LoginUserVO.fromJson(json));
  }


  static Future<bool> userLogout() async {
    final result = await Http.post<Result>(
      "/user/logout",
    );
    return result.toBoolean() ;
  }

  /// 获取当前用户信息
  static Future<UserDto> getCurrentUser() async {
    final result = await Http.get<Result>("/user/current");
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
  static Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    final result = await Http.put<Result>(
      "/users/$id",
      data: data,
    );
    return result.success;
  }

  /// 删除用户
  static Future<bool> deleteUser(String id) async {
    final result = await Http.delete<Result>("/users/$id");
    return result.success;
  }
}
