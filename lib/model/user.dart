class LoginUserVO {
  String? id;
  String? userAccount;
  String? userName;
  String? userAvatar;
  String? userProfile;
  String? userRole;
  String? token;
  int? editTime;
  int? createTime;
  int? updateTime;

  LoginUserVO({
    this.id,
    this.userAccount,
    this.userName,
    this.userAvatar,
    this.userProfile,
    this.userRole,
    this.token,
    this.editTime,
    this.createTime,
    this.updateTime,
  });

  factory LoginUserVO.fromJson(Map<String, dynamic> json) {
    return LoginUserVO(
      id: json['id']?.toString(), // 确保转换为字符串
      userAccount: json['userAccount'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      userProfile: json['userProfile'] as String?,
      userRole: json['userRole'] as String? ?? '',
      token: json['token'] as String? ?? '',
      editTime: json['editTime'] as int? ?? 0,
      createTime: json['createTime'] as int? ?? 0,
      updateTime: json['updateTime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userAccount': userAccount,
    'userName': userName,
    'userAvatar': userAvatar,
    'userProfile': userProfile,
    'userRole': userRole,
    'token': token,
    'editTime': editTime,
    'createTime': createTime,
    'updateTime': updateTime,
  };
}
