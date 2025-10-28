import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/space_api.dart';

/// 空间状态 Provider
/// 用于全局管理用户的私有空间数据
final spaceProvider = StateNotifierProvider<SpaceNotifier, SpaceState>((ref) {
  return SpaceNotifier(ref);
});

/// 空间状态类
class SpaceState {
  final SpaceVO? space;
  final bool isLoading;
  final String? error;

  SpaceState({
    this.space,
    this.isLoading = false,
    this.error,
  });

  SpaceState copyWith({
    SpaceVO? space,
    bool? isLoading,
    String? error,
  }) {
    return SpaceState(
      space: space ?? this.space,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// 是否有空间数据
  bool get hasSpace => space != null && space!.id.isNotEmpty;
}

/// 空间状态管理器
class SpaceNotifier extends StateNotifier<SpaceState> {
  final Ref ref;

  SpaceNotifier(this.ref) : super(SpaceState());

  /// 加载用户的私有空间
  Future<void> loadMySpace(String userId) async {
    // 如果正在加载，避免重复请求
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await SpaceApi.getList({
        "current": 1,
        "pageSize": 10,
        "spaceType": 0, // 私有空间
        "userId": userId,
      });

      if (res.records.isNotEmpty) {
        state = SpaceState(
          space: res.records[0],
          isLoading: false,
          error: null,
        );
      } else {
        state = SpaceState(
          space: null,
          isLoading: false,
          error: null,
        );
      }
    } catch (e) {
      state = SpaceState(
        space: null,
        isLoading: false,
        error: e.toString(),
      );
      print('加载空间数据失败: $e');
    }
  }

  /// 更新空间信息
  void updateSpace(SpaceVO newSpace) {
    state = SpaceState(
      space: newSpace,
      isLoading: false,
      error: null,
    );
  }

  /// 更新空间名称
  void updateSpaceName(String newName) {
    if (state.space != null) {
      final updatedSpace = state.space!.copyWith(spaceName: newName);
      state = state.copyWith(space: updatedSpace);
    }
  }

  /// 更新空间类型
  void updateSpaceType(int newType) {
    if (state.space != null) {
      final updatedSpace = state.space!.copyWith(spaceType: newType);
      state = state.copyWith(space: updatedSpace);
    }
  }

  /// 清空空间数据（登出时使用）
  void clear() {
    state = SpaceState();
  }

  /// 刷新空间数据
  Future<void> refresh(String userId) async {
    await loadMySpace(userId);
  }

  /// 获取当前空间
  SpaceVO? get space => state.space;

  /// 是否有空间
  bool get hasSpace => state.hasSpace;

  /// 是否正在加载
  bool get isLoading => state.isLoading;
}
