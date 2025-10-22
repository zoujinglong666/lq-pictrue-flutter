import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../net/sse_manager.dart';
import '../model/notify.dart';
import '../common/event_bus.dart';
import '../providers/auth_provider.dart';

/// SSE服务类 - 封装SSE功能供页面使用
class SSEService {
  static final SSEService _instance = SSEService._internal();

  factory SSEService() => _instance;

  SSEService._internal();

  final SSEManager _sseManager = SSEManager();
  bool _initialized = false;

  /// 未读消息数量
  int unreadCount = 0;

  /// 消息监听器列表
  final List<Function(int)> _unreadCountListeners = [];
  final List<Function(NotifyVO)> _newNotificationListeners = [];

  /// 初始化SSE服务
  void initialize({bool enableMockMode = false, WidgetRef? ref}) {
    if (_initialized) return;

    if (enableMockMode) {
    } else {
      String? token;
      
      // 如果提供了ref，尝试从authProvider获取token
      if (ref != null) {
        final authState = ref.read(authProvider);
        if (authState.isLoggedIn) {
          token = authState.token;
          print('从authProvider获取到认证token，长度: ${token ?? 0}');
        } else {
          print('用户未登录，暂不连接SSE');
          return;
        }
      }
      
      _sseManager.initialize(initialToken: token);
      
      // 监听SSE消息事件
      _sseManager.addMessageListener(_handleSSEMessage);
      
      // 监听连接状态变化
      _sseManager.addConnectionListener(_handleConnectionChange);
      
      // 监听通知更新事件
      eventBus.on<NotificationUpdateEvent>().listen(_handleNotificationUpdate);
      
      // 监听通知数量更新事件
      eventBus.on<NotificationCountUpdateEvent>().listen(_handleNotificationCountUpdate);
      
      _initialized = true;
      
      // 尝试连接SSE
      _connectSSE();
    }
  }



  /// 处理SSE消息
  void _handleSSEMessage(SSEMessageEvent event) {
    print('收到SSE消息: ${event.type} - ${event.data}');
  }

  /// 处理连接状态变化
  void _handleConnectionChange(bool connected) {
    if (connected) {
      print('SSE连接成功');
    } else {
      print('SSE连接断开，将尝试重连');
    }
  }

  /// 处理通知更新
  void _handleNotificationUpdate(NotificationUpdateEvent event) {
    final notify = event.notify;
    
    // 如果是未读消息，增加未读计数
    if (notify.readStatus == 0) {
      unreadCount++;
      _notifyUnreadCountChange();
    }
    
    // 通知新消息到达
    _notifyNewNotification(notify);
    
    print('收到新通知: ${notify.content}，当前未读: $unreadCount');
  }

  /// 处理通知数量更新
  void _handleNotificationCountUpdate(NotificationCountUpdateEvent event) {
    // 这个事件只是用于记录日志，不增加未读计数
    // 因为未读计数已经在_handleNotificationUpdate中处理过了
    print('📈 通知数量更新 - 类型: ${event.type}, 当前未读: $unreadCount');
  }

  /// 连接SSE
  Future<void> _connectSSE() async {
    try {
      await _sseManager.connect();
    } catch (e) {
      print('SSE连接失败: $e');
      // 可以在这里添加重连逻辑
    }
  }

  /// 断开SSE连接
  Future<void> disconnect() async {
    await _sseManager.disconnect();
  }

  /// 添加未读数量监听器
  void addUnreadCountListener(Function(int) listener) {
    _unreadCountListeners.add(listener);
  }

  /// 移除未读数量监听器
  void removeUnreadCountListener(Function(int) listener) {
    _unreadCountListeners.remove(listener);
  }

  /// 添加新通知监听器
  void addNewNotificationListener(Function(NotifyVO) listener) {
    _newNotificationListeners.add(listener);
  }

  /// 移除新通知监听器
  void removeNewNotificationListener(Function(NotifyVO) listener) {
    _newNotificationListeners.remove(listener);
  }

  /// 通知未读数量变化
  void _notifyUnreadCountChange() {
    for (final listener in _unreadCountListeners) {
      try {
        listener(unreadCount);
      } catch (e) {
        print('未读数量监听器错误: $e');
      }
    }
  }

  /// 通知新消息到达
  void _notifyNewNotification(NotifyVO notify) {
    for (final listener in _newNotificationListeners) {
      try {
        listener(notify);
      } catch (e) {
        print('新通知监听器错误: $e');
      }
    }
  }

  /// 重置未读数量（当用户查看消息时调用）
  void resetUnreadCount() {
    unreadCount = 0;
    _notifyUnreadCountChange();
  }

  /// 增加未读数量（用于测试或其他情况）
  void incrementUnreadCount() {
    unreadCount++;
    _notifyUnreadCountChange();
  }

  /// 获取当前连接状态
  bool get isConnected => _sseManager.isConnected;

  /// 销毁服务
  void dispose() {
    _sseManager.dispose();
    _unreadCountListeners.clear();
    _newNotificationListeners.clear();
    _initialized = false;
  }
}

/// SSE服务提供者 - 用于在Widget树中提供SSE服务
class SSEServiceProvider extends InheritedWidget {
  final SSEService sseService;

  const SSEServiceProvider({
    super.key,
    required this.sseService,
    required super.child,
  });

  static SSEServiceProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SSEServiceProvider>();
  }

  static SSEService getService(BuildContext context) {
    final provider = of(context);
    assert(provider != null, 'No SSEServiceProvider found in context');
    return provider!.sseService;
  }

  @override
  bool updateShouldNotify(SSEServiceProvider oldWidget) {
    return sseService != oldWidget.sseService;
  }
}