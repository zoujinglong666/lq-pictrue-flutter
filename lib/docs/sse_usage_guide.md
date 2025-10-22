# SSE工具使用指南

## 概述
本项目封装了一个完整的SSE（Server-Sent Events）工具，用于实现实时消息推送功能。SSE管理器支持连接管理、消息接收、自动重连和事件分发。

## 核心组件

### 1. SSEManager (lib/net/sse_manager.dart)
核心SSE管理器，负责：
- SSE连接建立和维护
- 消息解析和处理
- 自动重连机制
- 连接状态管理

### 2. SSEService (lib/services/sse_service.dart)
服务层封装，提供：
- 简化的API接口
- 未读消息数量管理
- 事件监听器管理
- Widget树集成支持

### 3. 集成示例 (lib/pages/home_page.dart)
首页集成示例，展示如何：
- 初始化SSE服务
- 监听未读消息数量变化
- 处理新消息到达
- 重置未读数量

## 快速开始

### 1. 基本使用

```dart
// 初始化SSE服务
final sseService = SSEService();
sseService.initialize();

// 添加监听器
sseService.addUnreadCountListener((count) {
  // 处理未读数量变化
  setState(() {
    _unreadCount = count;
  });
});

sseService.addNewNotificationListener((notify) {
  // 处理新通知
  print('收到新通知: ${notify.content}');
});

// 重置未读数量（用户查看消息后调用）
sseService.resetUnreadCount();

// 断开连接
sseService.dispose();
```

### 2. 在StatefulWidget中使用

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SSEService _sseService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _sseService = SSEService();
    _setupSSEListener();
  }

  void _setupSSEListener() {
    _sseService.initialize();
    _sseService.addUnreadCountListener(_handleUnreadCountChange);
    _sseService.addNewNotificationListener(_handleNewNotification);
  }

  void _handleUnreadCountChange(int count) {
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  void _handleNewNotification(NotifyVO notify) {
    // 处理新通知
    print('收到新通知: ${notify.content}');
  }

  @override
  void dispose() {
    _sseService.removeUnreadCountListener(_handleUnreadCountChange);
    _sseService.removeNewNotificationListener(_handleNewNotification);
    _sseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 界面代码
    );
  }
}
```

## 功能特性

### 1. 自动重连
- 连接断开后自动重连
- 最大重连次数：5次
- 重连间隔：5秒

### 2. 消息类型支持
- **notification**: 通知消息
- **system**: 系统消息  
- **heartbeat**: 心跳消息

### 3. 事件总线集成
与项目现有的事件总线集成，支持：
- Token刷新成功时自动重连SSE
- Token过期时自动断开SSE

### 4. 连接状态管理
实时监控连接状态，提供连接状态变化回调。

## 事件类型

### SSEMessageEvent
SSE消息事件，包含：
- `type`: 消息类型
- `data`: 消息数据
- `id`: 消息ID
- `retry`: 重连间隔

### SSEConnectionEvent
连接状态事件，包含：
- `connected`: 连接状态
- `error`: 错误信息

### NotificationUpdateEvent
通知更新事件，包含：
- `notify`: 通知对象

## 测试工具

提供了测试页面 `lib/pages/sse_test_page.dart`，可用于：
- 测试SSE连接状态
- 模拟消息接收
- 验证未读数量管理

## 后端接口要求

SSE服务需要后端提供以下接口：

### SSE连接端点
```
GET /notify/sse
Headers:
  Accept: text/event-stream
  Cache-Control: no-cache
```

### 消息格式
```
event: notification
data: {"id": "1", "type": "like", "content": "用户A点赞了你的图片", ...}

event: system  
data: {"message": "系统维护通知"}

event: heartbeat
data: {}
```

## 最佳实践

1. **初始化时机**: 在用户登录成功后初始化SSE服务
2. **断开时机**: 在用户退出登录时断开SSE连接
3. **错误处理**: 监听连接错误并进行适当处理
4. **内存管理**: 在页面销毁时及时清理监听器
5. **用户体验**: 在连接断开时给用户适当的提示

## 故障排除

### 常见问题

1. **连接失败**
   - 检查网络连接
   - 验证后端SSE服务是否正常
   - 检查token是否有效

2. **消息无法接收**
   - 检查消息格式是否符合规范
   - 验证监听器是否正确注册
   - 查看控制台错误信息

3. **内存泄漏**
   - 确保在dispose()中清理所有监听器
   - 使用mounted检查避免在销毁的widget上调用setState

## 扩展功能

可以根据需要扩展以下功能：

1. **本地通知**: 集成flutter_local_notifications实现本地推送
2. **消息持久化**: 将消息保存到本地数据库
3. **消息分类**: 支持更多消息类型和分类处理
4. **离线消息**: 支持离线消息同步

## 技术支持

如有问题，请参考：
- SSE规范: https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
- Dio文档: https://pub.dev/packages/dio
- EventBus文档: https://pub.dev/packages/event_bus