import 'package:lq_picture/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCommentRequest {
  final String pictureId;
  final String content;
  final String? parentId;

  AddCommentRequest({
    required this.pictureId,
    required this.content,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'pictureId': pictureId,
      'content': content,
    };
    if (parentId != null) {
      data['parentId'] = parentId;
    }
    return data;
  }

  // 验证方法 - 根据后端逻辑
  bool validate() {
    if (content.trim().isEmpty) {
      return false;
    }
    if (content.trim().length > 1000) {
      return false;
    }
    return true;
  }

  // 检查用户是否登录
  static bool isUserLoggedIn(WidgetRef ref) {
    final authState = ref.read(authProvider);
    return authState.isLoggedIn;
  }

  // 获取当前用户ID
  static String? getCurrentUserId(WidgetRef ref) {
    final authState = ref.read(authProvider);
    return authState.user?.id;
  }
}