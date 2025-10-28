import 'package:flutter/material.dart';
import 'package:lq_picture/common/toast.dart';
import '../apis/user_api.dart';
import '../utils/keyboard_utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with KeyboardDismissMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isUsernameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    // 监听焦点变化
    _usernameFocus.addListener(() {
      setState(() {
        _isUsernameFocused = _usernameFocus.hasFocus;
      });
    });
    _emailFocus.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocus.hasFocus;
      });
    });
    _passwordFocus.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocus.hasFocus;
      });
    });
    _confirmPasswordFocus.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocus.hasFocus;
      });
    });
    // 监听输入内容变化，实时更新UI
    _usernameController.addListener(() {
      setState(() {});
    });
    _emailController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      MyToast.showInfo('请同意用户协议和隐私政策');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try{
      final res = await UserApi.userRegister({
        'userAccount': _usernameController.text,
        'userPassword': _passwordController.text,
        'checkPassword': _confirmPasswordController.text
      });
      if (res.isNotEmpty) {
        MyToast.showSuccess('注册成功');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    }catch(e){
      setState(() {
        _isLoading = false;
      });
      MyToast.showError('注册失败');
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: buildWithKeyboardDismiss(
        backgroundColor: Colors.transparent,
        body: Container(
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
              // 返回按钮
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF8A9BAE),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
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
                              '创建账号',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF8A9BAE),
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '加入我们，开始您的图片之旅',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFFA8B5C7),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // 注册表单卡片
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
                                focusNode: _usernameFocus,
                                label: '用户名',
                                hint: '请输入用户名',
                                icon: Icons.person_outline_rounded,
                                isFocused: _isUsernameFocused,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '请输入用户名';
                                  }
                                  if (value.length < 3) {
                                    return '用户名长度至少3位';
                                  }
                                  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$').hasMatch(value)) {
                                    return '用户名必须以字母开头，只能包含字母和数字';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // 邮箱输入框
                              _buildInputField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: '邮箱',
                                hint: '请输入邮箱',
                                icon: Icons.email_outlined,
                                isFocused: _isEmailFocused,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '请输入邮箱';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return '请输入有效的邮箱地址';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // 密码输入框
                              _buildInputField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                label: '密码',
                                hint: '请输入密码',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                isFocused: _isPasswordFocused,
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

                              const SizedBox(height: 18),

                              // 确认密码输入框
                              _buildInputField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                label: '确认密码',
                                hint: '请再次输入密码',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                isConfirmPassword: true,
                                isFocused: _isConfirmPasswordFocused,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '请确认密码';
                                  }
                                  if (value != _passwordController.text) {
                                    return '两次输入的密码不一致';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // 用户协议
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _agreeToTerms = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF6DD5ED),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF9CA8B5),
                                        ),
                                        children: [
                                          TextSpan(text: '我已阅读并同意'),
                                          TextSpan(
                                            text: '《用户协议》',
                                            style: TextStyle(
                                              color: Color(0xFF6DD5ED),
                                            ),
                                          ),
                                          TextSpan(text: '和'),
                                          TextSpan(
                                            text: '《隐私政策》',
                                            style: TextStyle(
                                              color: Color(0xFF6DD5ED),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // 注册按钮
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleRegister,
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
                                              '注 册',
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
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 登录提示
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '已有账号?',
                            style: TextStyle(
                              color: Color(0xFF9CA8B5),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              '立即登录',
                              style: TextStyle(
                                color: Color(0xFF6DD5ED),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
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
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isFocused,
    bool isPassword = false,
    bool isConfirmPassword = false,
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
        focusNode: focusNode,
        obscureText: isPassword && (isConfirmPassword ? !_isConfirmPasswordVisible : !_isPasswordVisible),
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
          hintText: (isFocused || controller.text.isNotEmpty) ? null : hint,
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
                    (isConfirmPassword ? _isConfirmPasswordVisible : _isPasswordVisible)
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: const Color(0xFF8A9BAE),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirmPassword) {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      } else {
                        _isPasswordVisible = !_isPasswordVisible;
                      }
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
