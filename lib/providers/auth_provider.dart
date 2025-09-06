import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/user_api.dart';
import 'package:lq_picture/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../net/request.dart';

// ==== 登录状态结构 ====
class AuthState {
  final String? token;
  final LoginUserVO? user;
  final bool isInitialized; // ✅ 新增字段

  AuthState({
    this.token,
    this.user,
    this.isInitialized = false,
  });

  bool get isLoggedIn => token != null && user != null;
  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user?.toJson(),
  };

  factory AuthState.fromJson(Map<String, dynamic> json) => AuthState(
    token: json['token'],
    user: json['user'] != null ? LoginUserVO.fromJson(json['user']) : null,
    isInitialized: true,
  );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier();
  notifier.loadFromStorage(); // 👈 启动时加载
  return notifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  static const _storageKey = 'auth_data';
  final bool _isRefreshing = false; // 防止重复刷新
  AuthNotifier() : super(AuthState());


  /// ✅ 从本地加载登录信息
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      if (raw != null) {
        final map = jsonDecode(raw);
        state = AuthState.fromJson(map);
        
        // 如果已登录，启动token检查
        if (state.isLoggedIn) {
          // 可以在这里添加token验证逻辑
        }
      } else {
        state = AuthState(isInitialized: true);
      }
    } catch (e) {
      // 如果解析失败，清除存储并初始化为未登录状态
      print('加载认证状态失败: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      state = AuthState(isInitialized: true);
    }
  }

  /// ✅ 登录成功，更新状态并存储
  Future<void> login(LoginUserVO user, String token, {String? refreshToken}) async {
    state = AuthState(
      user: user,
      token: token,
      isInitialized: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  /// 刷新token
/// 修复这个方法中的 token 变量未定义问题
Future<void> setLoginUser(LoginUserVO user) async {
  state = AuthState(
    user: user,
    token: state.token, // 使用 state.token 而不是未定义的 token 变量
    isInitialized: true,
  );
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_storageKey, jsonEncode(state.toJson()));
}
  Future<void> apiLogout() async {
    final res=await UserApi.userLogout();
  }

  /// ✅ 登出
  Future<void> logout() async {
    await apiLogout();
    state = AuthState(isInitialized: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove('token');
    Http.clearToken();
  }



  // ✅ Getter
  LoginUserVO? get user => state.user;
  String? get token => state.token;
  bool get isLoggedIn => state.isLoggedIn;
  bool get isAdmin => state.user?.userRole == 'admin' || false;
  bool get isRefreshing => _isRefreshing;

  // ✅ Setter（并自动同步状态）
  set user(LoginUserVO? newUser) {
    state = AuthState(
      user: newUser,
      token: state.token,
      isInitialized: true,
    );
    _saveToStorage();
  }

  set token(String? newToken) {
    state = AuthState(
      user: state.user,
      token: newToken,
      isInitialized: true,
    );
    _saveToStorage();
  }

  set refreshToken(String? newRefreshToken) {
    state = AuthState(
      user: state.user,
      token: state.token,
      isInitialized: true,
    );
    _saveToStorage();
  }

  /// ✅ 封装的本地存储方法
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}


