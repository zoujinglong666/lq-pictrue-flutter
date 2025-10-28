# 空间状态全局管理 - SpaceProvider

## 📌 概述

使用 Riverpod Provider 进行全局空间状态管理，实现多页面间的自动数据同步。

## 🎯 核心优势

### 1. **全局状态管理**
- 空间数据统一存储在 `SpaceProvider` 中
- 所有页面共享同一份数据，避免重复请求
- 数据更新自动通知所有监听页面

### 2. **自动同步**
- 空间设置页面修改数据后，直接更新 Provider
- 我的空间页面、个人中心页面自动接收最新数据
- 无需手动传递返回值或调用刷新方法

### 3. **性能优化**
- 避免重复加载相同数据
- 使用 `Consumer` 精确监听状态变化
- 减少不必要的 setState 调用

## 📁 文件结构

```
lib/providers/
  └── space_provider.dart          # 空间状态管理器

lib/pages/
  ├── profile_page.dart             # 个人中心（初始化加载空间数据）
  ├── my_space_page.dart            # 我的空间（监听空间状态）
  └── space_settings_page.dart     # 空间设置（更新空间数据）
```

## 🔧 使用方法

### 1. **SpaceProvider 定义**

```dart
// lib/providers/space_provider.dart

/// 空间状态 Provider
final spaceProvider = StateNotifierProvider<SpaceNotifier, SpaceState>((ref) {
  return SpaceNotifier(ref);
});

/// 空间状态类
class SpaceState {
  final SpaceVO? space;        // 空间数据
  final bool isLoading;         // 加载状态
  final String? error;          // 错误信息
  
  bool get hasSpace => space != null && space!.id.isNotEmpty;
}

/// 空间状态管理器
class SpaceNotifier extends StateNotifier<SpaceState> {
  // 加载用户空间
  Future<void> loadMySpace(String userId);
  
  // 更新空间信息
  void updateSpace(SpaceVO newSpace);
  
  // 刷新空间数据
  Future<void> refresh(String userId);
  
  // 清空数据（登出时）
  void clear();
}
```

### 2. **个人中心页面 - 初始化加载**

```dart
// lib/pages/profile_page.dart

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null) {
      // ✅ 使用 Provider 加载空间数据
      await ref.read(spaceProvider.notifier).loadMySpace(user.id);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // ✅ 监听空间状态变化
    final spaceState = ref.watch(spaceProvider);
    final spaceData = spaceState.space ?? SpaceVO.empty();
    
    return Scaffold(
      // ... 使用 spaceData 展示数据
    );
  }
}
```

### 3. **我的空间页面 - 监听状态**

```dart
// lib/pages/my_space_page.dart

class _MySpacePageState extends ConsumerState<MySpacePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }
  
  Future<void> _initData() async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null) {
      // ✅ 使用 Provider 加载空间数据
      await ref.read(spaceProvider.notifier).loadMySpace(user.id);
      await _loadData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () async {
              // ✅ 从 Provider 获取当前空间数据
              final spaceState = ref.read(spaceProvider);
              final currentSpace = spaceState.space;
              
              if (currentSpace != null) {
                await Navigator.pushNamed(
                  context,
                  '/space_settings',
                  arguments: currentSpace,
                );
                // ✅ Provider 会自动同步，无需手动处理返回值
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ✅ 刷新空间数据
          final authState = ref.read(authProvider);
          final user = authState.user;
          if (user != null) {
            await ref.read(spaceProvider.notifier).refresh(user.id);
          }
        },
        child: Consumer(
          builder: (context, ref, child) {
            // ✅ 监听空间状态变化
            final spaceState = ref.watch(spaceProvider);
            final spaceData = spaceState.space ?? SpaceVO.empty();
            
            return CustomScrollView(
              // ... 使用 spaceData 展示数据
            );
          },
        ),
      ),
    );
  }
}
```

### 4. **空间设置页面 - 更新状态**

```dart
// lib/pages/space_settings_page.dart

class _SpaceSettingsPageState extends ConsumerState<SpaceSettingsPage> {
  late SpaceVO _spaceInfo;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ 接收路由参数
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is SpaceVO) {
        setState(() {
          _spaceInfo = args;
          _spaceNameController.text = _spaceInfo.spaceName;
        });
      }
    });
  }
  
  Future<void> _saveSettings() async {
    // 更新空间信息
    final updatedSpace = _spaceInfo.copyWith(
      spaceName: _spaceNameController.text.trim(),
      spaceType: _isPrivate ? 0 : 1,
    );
    
    // TODO: 调用 API 保存到后端
    // await SpaceApi.updateSpace(updatedSpace);
    
    // ✅ 更新全局 Provider
    ref.read(spaceProvider.notifier).updateSpace(updatedSpace);
    
    // ✅ 返回上一页，Provider 会自动同步数据
    Navigator.pop(context);
  }
}
```

## 🔄 数据流转示意图

```
用户登录
    ↓
个人中心页面
    ├─→ loadMySpace(userId)      // 首次加载
    └─→ spaceProvider.loadMySpace()
            ↓
        SpaceProvider 存储数据
            ↓
    ┌───────┴───────┐
    ↓               ↓
我的空间页面    空间设置页面
    ↓               ↓
ref.watch()    ref.read()
    ↓               ↓
获取数据        修改数据
                    ↓
            updateSpace()
                    ↓
        SpaceProvider 更新数据
                    ↓
            自动通知所有监听者
                    ↓
        ┌───────────┴───────────┐
        ↓                       ↓
    我的空间页面            个人中心页面
    UI 自动更新             UI 自动更新
```

## ✨ 智能优化

### 1. **智能输入框**
所有输入框都支持智能提示文字：
- 点击输入框 → 提示文字保持
- 开始输入 → 提示文字立即消失
- 清空内容 → 提示文字重新显示

### 2. **加载状态管理**
```dart
final spaceState = ref.watch(spaceProvider);

if (spaceState.isLoading) {
  return Center(child: CircularProgressIndicator());
}

if (spaceState.error != null) {
  return Center(child: Text('加载失败: ${spaceState.error}'));
}

final spaceData = spaceState.space;
// 使用数据...
```

### 3. **登出时清空**
```dart
// 在 AuthProvider 的 logout 方法中
Future<void> logout() async {
  await apiLogout();
  state = AuthState(isInitialized: true);
  
  // ✅ 清空空间数据
  ref.read(spaceProvider.notifier).clear();
  
  // 清空其他数据...
}
```

## 🎨 最佳实践

### 1. **使用 Consumer 精确监听**
```dart
// ✅ 好的做法：只在需要的地方使用 Consumer
Consumer(
  builder: (context, ref, child) {
    final spaceState = ref.watch(spaceProvider);
    return Text(spaceState.space?.spaceName ?? '');
  },
)

// ❌ 避免：在整个页面使用 Consumer
Consumer(
  builder: (context, ref, child) {
    return Scaffold(...);  // 整个页面都会重建
  },
)
```

### 2. **读取 vs 监听**
```dart
// ✅ 一次性读取（不监听变化）
final spaceData = ref.read(spaceProvider).space;

// ✅ 持续监听（数据变化时重建）
final spaceData = ref.watch(spaceProvider).space;
```

### 3. **条件渲染**
```dart
final spaceState = ref.watch(spaceProvider);

if (!spaceState.hasSpace) {
  return _buildCreateSpaceButton();
}

return _buildSpaceContent(spaceState.space!);
```

## 🚀 扩展功能

### 1. **添加更多状态管理方法**
```dart
class SpaceNotifier extends StateNotifier<SpaceState> {
  // 更新存储使用量
  void updateStorageUsage(String totalSize) {
    if (state.space != null) {
      final updated = state.space!.copyWith(totalSize: totalSize);
      state = state.copyWith(space: updated);
    }
  }
  
  // 增加图片数量
  void incrementPictureCount() {
    if (state.space != null) {
      final currentCount = int.tryParse(state.space!.totalCount) ?? 0;
      final updated = state.space!.copyWith(
        totalCount: (currentCount + 1).toString(),
      );
      state = state.copyWith(space: updated);
    }
  }
}
```

### 2. **本地持久化**
```dart
class SpaceNotifier extends StateNotifier<SpaceState> {
  // 保存到本地
  Future<void> _saveToLocal() async {
    if (state.space != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('space_data', jsonEncode(state.space!.toJson()));
    }
  }
  
  // 从本地加载
  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('space_data');
    if (data != null) {
      final space = SpaceVO.fromJson(jsonDecode(data));
      state = SpaceState(space: space);
    }
  }
}
```

## 📝 注意事项

1. **页面初始化时机**
   - 使用 `WidgetsBinding.instance.addPostFrameCallback` 确保 Provider 已初始化

2. **避免重复加载**
   - 检查 `isLoading` 状态避免重复请求
   - 使用 `hasSpace` 判断是否已有数据

3. **错误处理**
   - 捕获异常并更新 error 状态
   - 在 UI 中显示友好的错误提示

4. **性能优化**
   - 使用 `select` 精确监听特定字段
   - 避免在 Consumer 中执行耗时操作

## 🎉 总结

使用 Provider 进行全局状态管理后：
- ✅ 数据自动同步，无需手动传递
- ✅ 代码更简洁，逻辑更清晰
- ✅ 性能更优，避免重复请求
- ✅ 维护更容易，单一数据源

现在，您只需在一个地方更新数据，所有页面都会自动获得最新状态！
