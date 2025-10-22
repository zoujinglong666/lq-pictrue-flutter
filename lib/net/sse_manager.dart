import 'dart:async';
import 'dart:convert';
import 'package:event_bus/event_bus.dart';
import 'package:dio/dio.dart';
import 'package:lq_picture/Consts/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/event_bus.dart';
import '../model/notify.dart';

/// SSE消息事件
class SSEMessageEvent {
  final String type;
  final dynamic data;
  final String? id;
  final String? retry;

  SSEMessageEvent({
    required this.type,
    required this.data,
    this.id,
    this.retry,
  });
}

/// SSE连接状态事件
class SSEConnectionEvent {
  final bool connected;
  final String? error;

  SSEConnectionEvent({required this.connected, this.error});
}

/// SSE管理器 - 使用Dio实现SSE连接
class SSEManager {
  static final SSEManager _instance = SSEManager._internal();

  factory SSEManager() => _instance;

  SSEManager._internal();

  // SSE连接相关
  Dio? _dio;
  Response? _response;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectInterval = const Duration(seconds: 5);

  // 事件总线
  final EventBus _eventBus = eventBus;

  // 连接状态监听器
  final List<Function(bool)> _connectionListeners = [];
  final List<Function(SSEMessageEvent)> _messageListeners = [];
  
  // 当前认证token
  String? _currentToken;

  /// 初始化SSE管理器
  void initialize({String? initialToken}) {
    _currentToken = initialToken;
    _setupEventListeners();
  }

  /// 设置事件监听器
  void _setupEventListeners() {
    // 监听token刷新成功事件，重新连接SSE
    _eventBus.on<TokenRefreshSuccessEvent>().listen((event) {
      if (_isConnected) {
        disconnect();
        Future.delayed(const Duration(milliseconds: 500), () {
          connect();
        });
      }
    });

    // 监听token过期事件，断开SSE连接
    _eventBus.on<TokenExpiredEvent>().listen((event) {
      disconnect();
    });
  }

  /// 连接到SSE服务器
  Future<void> connect() async {
    if (_isConnected) {
      return;
    }

    try {
      // 清除之前的连接
      await disconnect();

      // 构建正确的SSE端点URL
      final sseUrl = '${Consts.request.baseUrl}/notify/subscribe';
      final String? token = await _getAuthToken();
      
      if (token == null) {
        throw Exception('用户未登录，无法连接SSE');
      }
      
      // 创建Dio实例
      _dio = Dio();
      
      // 设置请求头
      final options = Options(
        method: 'GET',
        headers: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.stream,
      );
      
      // 发起SSE请求
      _response = await _dio!.get(
        sseUrl,
        options: options,
      );
      
      // 监听SSE消息流
      if (_response?.data != null) {
        final responseBody = _response!.data as ResponseBody;
        responseBody.stream.listen(
          _handleSSEData,
          onError: _handleSSEError,
          onDone: _handleSSEDone,
        );
      }

      _isConnected = true;
      _reconnectAttempts = 0;
      _notifyConnectionChange(true);
      _eventBus.fire(SSEConnectionEvent(connected: true));

      print('🎉 SSE连接成功 - 使用Dio实现');
      print('📡 SSE端点: ${Consts.request.baseUrl}/notify/subscribe');
      print('🔐 认证状态: 已认证 (Bearer Token)');
      print('🔄 重连机制: 已启用 (最大${_maxReconnectAttempts}次重连)');
      print('📊 连接状态: 活跃 - 开始接收实时消息');
    } catch (e) {
      _handleSSEError(e);
    }
  }

  /// 获取认证token
  Future<String?> _getAuthToken() async {
    try {
      // 优先使用通过initialize方法传递的token
      if (_currentToken != null && _currentToken!.isNotEmpty) {
        print('使用初始化时传递的认证token，长度: ${_currentToken!.length}');
        return _currentToken;
      }
      
      // 如果初始化时没有传递token，尝试从SharedPreferences获取
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        print('未找到认证token，请确保用户已登录');
        return null;
      }

      print('从本地存储获取到认证token，长度: ${token.length}');
      return token;
    } catch (e) {
      print('获取认证token失败: $e');
      return null;
    }
  }

  /// 处理SSE数据
  void _handleSSEData(List<int> data) {
    try {
      final message = utf8.decode(data);
      print('📨 收到SSE原始数据: $message');
      _parseSSEMessage(message);
    } catch (e) {
      print('❌ SSE数据解码失败: $e');
    }
  }

  /// 解析SSE消息
  void _parseSSEMessage(String message) {
    final lines = message.split('\n');
    String? eventType;
    String? data;
    String? id;
    String? retry;

    print('🔍 开始解析SSE消息，共${lines.length}行');
    
    for (final line in lines) {
      if (line.isEmpty) continue;

      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
        print('📝 事件类型: $eventType');
      } else if (line.startsWith('data:')) {
        data = line.substring(5).trim();
        print('📊 消息数据: $data');
      } else if (line.startsWith('id:')) {
        id = line.substring(3).trim();
        print('🆔 消息ID: $id');
      } else if (line.startsWith('retry:')) {
        retry = line.substring(6).trim();
        print('🔄 重连间隔: $retry');
      }
    }

    // 检查数据是否为空或无效
    if (data != null && data.isNotEmpty) {
      print('✅ SSE消息解析成功 - 类型: ${eventType ?? 'message'}, 数据长度: ${data.length}');
      final sseEvent = SSEMessageEvent(
        type: eventType ?? 'message',
        data: data,
        id: id,
        retry: retry,
      );

      _notifyMessage(sseEvent);
      _eventBus.fire(sseEvent);

      // 处理特定类型的消息
      _handleSpecificMessage(sseEvent);
    } else {
      // 如果标准SSE格式解析失败，尝试直接解析JSON格式
      _tryParseDirectJSON(message);
    }
  }

  /// 处理特定类型的消息
  void _handleSpecificMessage(SSEMessageEvent event) {
    try {
      print('🎯 开始处理特定类型消息 - 事件类型: ${event.type}');
      final jsonData = json.decode(event.data);
      print('📋 JSON数据解析成功: $jsonData');
      
      // 直接从JSON中提取type字段
      final messageType = jsonData['type']?.toString().toLowerCase() ?? 'notification';
      print('📝 实际消息类型: $messageType');
      
      // 处理通知类消息
      if (messageType == 'notification' || messageType == 'like' || messageType == 'comment') {
        print('🔔 处理通知消息 - 类型: $messageType');
        final notify = NotifyVO.fromJson(jsonData);
        _handleNotificationMessage(notify);
      } else if (messageType == 'system') {
        print('⚙️ 处理系统消息');
        _handleSystemMessage(jsonData);
      } else if (messageType == 'heartbeat') {
        print('💓 处理心跳消息');
        _handleHeartbeatMessage();
      } else {
        print('❓ 未知消息类型: $messageType');
      }
    } catch (e) {
      print('❌ 解析SSE消息失败: $e');
    }
  }

  /// 尝试直接解析JSON格式的消息
  void _tryParseDirectJSON(String message) {
    try {
      // 检查消息是否看起来像JSON
      final trimmedMessage = message.trim();
      if (trimmedMessage.isEmpty) {
        print('⚠️ 消息为空，跳过处理');
        return;
      }

      // 检查是否是JSON格式（以{开头，以}结尾）
      if (trimmedMessage.startsWith('{') && trimmedMessage.endsWith('}')) {
        print('🔍 尝试直接解析JSON格式消息');
        
        // 直接解析JSON数据
        final jsonData = json.decode(trimmedMessage);
        print('✅ JSON解析成功: $jsonData');
        
        // 从JSON中提取type字段作为事件类型
        final eventType = jsonData['type']?.toString().toLowerCase() ?? 'message';
        print('📝 提取的事件类型: $eventType');
        
        // 创建SSE事件
        final sseEvent = SSEMessageEvent(
          type: eventType,
          data: trimmedMessage, // 使用原始JSON字符串作为数据
          id: jsonData['id']?.toString(),
          retry: null,
        );

        _notifyMessage(sseEvent);
        _eventBus.fire(sseEvent);

        // 处理特定类型的消息
        _handleSpecificMessage(sseEvent);
      } else {
        print('⚠️ 消息不是有效的JSON格式，跳过处理');
        print('📋 完整消息内容: $message');
      }
    } catch (e) {
      print('❌ JSON解析失败: $e');
      print('📋 完整消息内容: $message');
    }
  }

  /// 处理通知消息
  void _handleNotificationMessage(NotifyVO notify) {
    // 发送通知更新事件
    _eventBus.fire(NotificationUpdateEvent(notify: notify));
    
    // 打印通知详情，包括type字段
    // print('🔔 收到新通知 - 类型: ${notify.type}, 内容: ${notify.content}');
    // print('📊 通知详情: ID: ${notify.id}, 图片ID: ${notify.pictureId}, 引用ID: ${notify.refId}');
    
    // 发送通知数量更新事件
    _eventBus.fire(NotificationCountUpdateEvent(type: notify.type));
  }

  /// 处理系统消息
  void _handleSystemMessage(dynamic data) {
    print('收到系统消息: $data');
  }

  /// 处理心跳消息
  void _handleHeartbeatMessage() {
    // 心跳消息，保持连接活跃
    print('SSE心跳');
  }

  /// 处理SSE错误
  void _handleSSEError(dynamic error) {
    print('SSE连接错误: $error');
    _isConnected = false;
    _notifyConnectionChange(false, error: error.toString());
    _eventBus.fire(SSEConnectionEvent(connected: false, error: error.toString()));
    
    // 尝试重连
    _scheduleReconnect();
  }

  /// 处理SSE连接完成
  void _handleSSEDone() {
    print('SSE连接关闭');
    _isConnected = false;
    _notifyConnectionChange(false);
    _eventBus.fire(SSEConnectionEvent(connected: false));
    
    // 尝试重连
    _scheduleReconnect();
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      
      // 根据重连次数调整重连间隔（指数退避）
      final delay = _reconnectInterval * (1 << (_reconnectAttempts - 1));
      final actualDelay = delay > const Duration(minutes: 5) 
          ? const Duration(minutes: 5) 
          : delay;
          
      print('将在${actualDelay.inSeconds}秒后尝试第$_reconnectAttempts次重连');
      
      _reconnectTimer = Timer(actualDelay, () {
        connect();
      });
    } else {
      print('达到最大重连次数($_maxReconnectAttempts)，停止重连');
      // 可以在这里添加通知用户的功能
      _eventBus.fire(SSEConnectionEvent(
        connected: false, 
        error: 'SSE连接失败，请检查网络或稍后重试'
      ));
    }
  }

  /// 断开SSE连接
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    // 关闭Dio实例，会自动关闭所有连接
    _dio?.close();
    _dio = null;
    _response = null;
    
    _isConnected = false;
    _notifyConnectionChange(false);
    _eventBus.fire(SSEConnectionEvent(connected: false));
  }

  /// 添加连接状态监听器
  void addConnectionListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  /// 移除连接状态监听器
  void removeConnectionListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  /// 添加消息监听器
  void addMessageListener(Function(SSEMessageEvent) listener) {
    _messageListeners.add(listener);
  }

  /// 移除消息监听器
  void removeMessageListener(Function(SSEMessageEvent) listener) {
    _messageListeners.remove(listener);
  }

  /// 通知连接状态变化
  void _notifyConnectionChange(bool connected, {String? error}) {
    for (final listener in _connectionListeners) {
      try {
        listener(connected);
      } catch (e) {
        print('连接状态监听器错误: $e');
      }
    }
  }

  /// 通知消息到达
  void _notifyMessage(SSEMessageEvent event) {
    for (final listener in _messageListeners) {
      try {
        listener(event);
      } catch (e) {
        print('消息监听器错误: $e');
      }
    }
  }

  /// 获取当前连接状态
  bool get isConnected => _isConnected;

  /// 销毁SSE管理器
  void dispose() {
    disconnect();
    _connectionListeners.clear();
    _messageListeners.clear();
  }
}

/// 通知更新事件
class NotificationUpdateEvent {
  final NotifyVO notify;

  NotificationUpdateEvent({required this.notify});
}

/// 通知数量更新事件
class NotificationCountUpdateEvent {
  final String type;

  NotificationCountUpdateEvent({required this.type});
}