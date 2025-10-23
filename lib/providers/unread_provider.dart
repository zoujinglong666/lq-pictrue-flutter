import 'package:flutter_riverpod/flutter_riverpod.dart';

// 全局未读消息数量 Provider
final unreadCountProvider = StateProvider<int>((ref) => 0);
