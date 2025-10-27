import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../apis/notific_api.dart';

// 全局未读消息数量 Provider
final unreadCountProvider = StateProvider<int>((ref) => 0);

// 未读消息刷新通知器 - 用于触发手动刷新
final unreadRefreshNotifierProvider =
    StateNotifierProvider<UnreadRefreshNotifier, int>(
  (ref) => UnreadRefreshNotifier(ref),
);

class UnreadRefreshNotifier extends StateNotifier<int> {
  final Ref ref;

  UnreadRefreshNotifier(this.ref) : super(0);

  // 手动刷新未读数
  Future<void> refresh() async {
    try {
      final res = await NotifyApi.countUnread();
      final count = int.parse(res);
      // 更新全局未读数
      ref.read(unreadCountProvider.notifier).state = count;
      // 更新状态,触发监听
      state = count;
    } catch (e) {
      print('刷新未读数失败: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      // 更新全局未读数
      ref.read(unreadCountProvider.notifier).state = 0;
      // 更新状态,触发监听
      state = 0;
    } catch (e) {
      print('刷新未读数失败: $e');
    }
  }
}
