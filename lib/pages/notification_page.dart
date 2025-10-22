import 'package:flutter/material.dart';
import '../apis/notific_api.dart';
import '../model/notify.dart';
import '../widgets/skeleton_widgets.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotifyVO> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _markAsRead(NotifyVO notification) async {
    // TODO: Implement markAsRead
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final res = await NotifyApi.getList({
        'page': 1,
        'pageSize': 10,
      });
      setState(() {
        _notifications = res.records ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 可以在这里添加错误处理
      print('获取通知列表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '消息通知',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.readStatus = 1;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已标记所有消息为已读')),
              );
            },
            child: Text(
              '全部已读',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const NotificationListSkeleton(itemCount: 6)
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无消息',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '当有新消息时会在这里显示',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotifyVO notification) {
    bool isRead = notification.readStatus == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(notification),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.content,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                  color: isRead ? Colors.grey[700] : Colors.grey[800],
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red[500],
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  notification.createTime.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: notification.pictureUrl != null && notification.pictureUrl!.isNotEmpty
                      ? Image.network(
                          notification.pictureUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 20),
                            );
                          },
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 20),
                        ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            notification.readStatus = 1;
          });
          // 根据消息类型执行不同的操作
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildNotificationIcon(NotifyVO notification) {
    String type = notification.type;
    String? avatarUrl = notification.actorAvatar;

    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (exception, stackTrace) {},
        child: avatarUrl.isEmpty
            ? Icon(Icons.person, color: Colors.grey[600])
            : null,
      );
    }

    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'COMMENT':
        iconData = Icons.comment_outlined;
        iconColor = Colors.blue[600]!;
        break;
      case 'LIKE':
        iconData = Icons.favorite_outline;
        iconColor = Colors.red[500]!;
        break;
      case 'SYSTEM':
        iconData = Icons.info_outline;
        iconColor = Colors.orange[600]!;
        break;
      default:
        iconData = Icons.notifications_outlined;
        iconColor = Colors.grey[600]!;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  void _handleNotificationTap(NotifyVO notification) {
    String type = notification.type;

    switch (type) {
      case 'COMMENT':
        // 跳转到图片详情页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('跳转到图片详情页')),
        );
        break;
      case 'LIKE':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('跳转到图片详情页')),
        );
        break;
      case 'SYSTEM':
        // 系统消息，可能不需要跳转
        break;
    }
  }
}
