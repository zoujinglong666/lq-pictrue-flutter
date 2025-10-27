import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/common/toast.dart';
import 'package:lq_picture/providers/auth_provider.dart';

import '../apis/user_api.dart';
import '../net/request.dart';
import '../utils/keyboard_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with KeyboardDismissMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginRes = await UserApi.userLogin({
        'userAccount': _usernameController.text,
        'userPassword': _passwordController.text,
      });
      if (loginRes != null) {
        ref.read(authProvider.notifier).login(loginRes, loginRes.token!);
        Http.setToken(loginRes.token!);
        MyToast.showSuccess("登录成功");
        // 登录成功后跳转到主页
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: buildWithKeyboardDismiss(
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5F5F5), // 奶白
                Color(0xFFE8EDF2), // 浅蓝灰
                Color(0xFFF0E6E8), // 淡粉白
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // 抽象几何背景装饰 - 左上角
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB8C5D6).withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // 右下角柔和圆形
              Positioned(
                bottom: -100,
                right: -80,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4B5C0).withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // 主内容
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const SizedBox(height: 60),
                    // Logo 区域 - 莫兰迪风格
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  const Color(0xFFFAFAFA).withOpacity(0.9),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9CA8B5).withOpacity(0.15),
                                  offset: const Offset(0, 12),
                                  blurRadius: 30,
                                  spreadRadius: -5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(0, -2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.photo_library_rounded,
                              color: Color(0xFF8A9BAE),
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '龙琪图库',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF8A9BAE),
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '欢迎回来',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFFA8B5C7),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 登录表单卡片
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.95),
                            const Color(0xFFFAFAFA).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9CA8B5).withOpacity(0.12),
                            offset: const Offset(0, 12),
                            blurRadius: 30,
                            spreadRadius: -5,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            offset: const Offset(0, -2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // 用户名输入框
                            _buildInputField(
                              controller: _usernameController,
                              label: '用户名',
                              hint: '请输入用户名',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入用户名';
                                }
                                if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$').hasMatch(value)) {
                                  return '用户名必须以字母开头，只能包含字母和数字';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // 密码输入框
                            _buildInputField(
                              controller: _passwordController,
                              label: '密码',
                              hint: '请输入密码',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入密码';
                                }
                                if (value.length < 6) {
                                  return '密码长度至少6位';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]*$').hasMatch(value)) {
                                  return '密码只能包含字母、数字和特殊字符';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // 登录按钮
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF6DD5ED),
                                        Color(0xFF2193B0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2193B0).withOpacity(0.3),
                                        offset: const Offset(0, 8),
                                        blurRadius: 20,
                                        spreadRadius: -4,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            '登 录',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 8,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 忘记密码
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgot_password');
                              },
                              child: const Text(
                                '忘记密码?',
                                style: TextStyle(
                                  color: Color(0xFF8A9BAE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 注册提示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '还没有账号?',
                          style: TextStyle(
                            color: Color(0xFF9CA8B5),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            '立即注册',
                            style: TextStyle(
                              color: Color(0xFF6DD5ED),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // 莫兰迪风格输入框
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8F9FA).withOpacity(0.8),
            const Color(0xFFFFFFFF).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EDF2).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA8B5).withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(
          color: Color(0xFF2D3436),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFFA8B5C7),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFFB8C5D6).withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF8A9BAE),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: const Color(0xFF8A9BAE),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF6DD5ED),
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE17055),
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE17055),
              width: 1.5,
            ),
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFE17055),
            fontSize: 12,
            height: 1.5,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
