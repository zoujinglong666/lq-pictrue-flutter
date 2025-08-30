import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lq_picture/apis/user_api.dart';
import 'package:lq_picture/common/toast.dart';
import 'dart:io';
import '../utils/keyboard_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../model/user.dart';

class UserSettingsPage extends ConsumerStatefulWidget {
  const UserSettingsPage({super.key});

  @override
  ConsumerState<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends ConsumerState<UserSettingsPage> with KeyboardDismissMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userAccountController = TextEditingController();
  final TextEditingController _userProfileController = TextEditingController();
  
  String _userAvatar = '';
  String _userRole = 'user';
  String _userId = '';
  bool _isLoading = false;
  bool _isEditing = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userAccountController.dispose();
    _userProfileController.dispose();
    super.dispose();
  }

 Future<void> _loadUserInfo() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final res = await UserApi.getCurrentUser();

    // 模拟用户数据
    setState(() {
      _userNameController.text = res.userName ?? '';
      _userAccountController.text = res.userAccount ?? '';
      _userProfileController.text = res.userProfile ?? '';
      _userAvatar = res.userAvatar ?? '';
      _userRole = res.userRole ?? 'user';
      _isEditing = true;
      _isLoading = false;
      _userId = res.id ?? '';
    });
  } catch (e) {
    // 处理错误情况
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      MyToast.showError('加载用户信息失败');
    }
  }
}


  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '选择头像',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: '拍照',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: '相册',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if(_userId.isEmpty){
      MyToast.showError('用户ID不能为空');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final res = await UserApi.updateUser(
      {
        "id": _userId,
        "userName": _userNameController.text,
        "userProfile": _userProfileController.text,
      }
    );

    if(res){
      // 更新全局状态
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        final updatedUser = LoginUserVO(
          id: currentUser.id,
          userName: _userNameController.text,
          userAccount: currentUser.userAccount,
          userAvatar: currentUser.userAvatar,
          userProfile: _userProfileController.text,
          userRole: currentUser.userRole,
          createTime: currentUser.createTime,
          updateTime: currentUser.updateTime,
        );
        await ref.read(authProvider.notifier).setLoginUser(updatedUser);
      }
      
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
      if (mounted) {
        MyToast.showSuccess('用户信息保存成功');
      }
    }

  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像部分
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : _userAvatar.isNotEmpty
                            ? Image.network(
                                _userAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[100],
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 角色标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _userRole == 'admin' ? Colors.red[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _userRole == 'admin' ? '管理员' : '普通用户',
              style: TextStyle(
                fontSize: 12,
                color: _userRole == 'admin' ? Colors.red[700] : Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: controller,
              enabled: enabled && _isEditing,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[800],
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '个人信息',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: Text(
                '编辑',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _selectedImage = null;
                });
                _loadUserInfo(); // 重新加载数据
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 用户信息卡片
                  _buildInfoCard(),
                  // 表单区域
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '基本信息',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            label: '账号',
                            controller: _userAccountController,
                            icon: Icons.email_outlined,
                            enabled: false, // 账号不允许修改
                          ),
                          _buildFormField(
                            label: '用户昵称',
                            controller: _userNameController,
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入用户昵称';
                              }
                              if (value.trim().length < 2) {
                                return '用户昵称至少2个字符';
                              }
                              return null;
                            },
                          ),
                          _buildFormField(
                            label: '个人简介',
                            controller: _userProfileController,
                            icon: Icons.description_outlined,
                            maxLines: 4,
                            validator: (value) {
                              if (value != null && value.length > 200) {
                                return '个人简介不能超过200个字符';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 保存按钮
                  if (_isEditing)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveUserInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '保存修改',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
