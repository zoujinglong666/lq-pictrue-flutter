import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'comment',
      'title': '新评论',
      'message': '用户 @张三 评论了你的图片《美丽的山景风光》',
      'time': '2分钟前',
      'isRead': false,
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
      'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=100',
    },
    {
      'id': '2',
      'type': 'audit',
      'title': '审核通过',
      'message': '你的图片《现代办公空间设计》已通过审核，现在可以被其他用户看到了',
      'time': '1小时前',
      'isRead': false,
      'imageUrl': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=100',
    },
    {
      'id': '3',
      'type': 'like',
      'title': '新点赞',
      'message': '用户 @李四 点赞了你的图片《自然风光摄影》',
      'time': '3小时前',
      'isRead': true,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      'imageUrl': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=100',
    },
    {
      'id': '4',
      'type': 'audit',
      'title': '审核未通过',
      'message': '你的图片《城市夜景》未通过审核，原因：图片质量不符合要求，请重新上传',
      'time': '昨天',
      'isRead': true,
      'imageUrl': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=100',
    },
    {
      'id': '5',
      'type': 'system',
      'title': '系统通知',
      'message': '欢迎使用摄图网！完善你的个人资料可以获得更多曝光机会',
      'time': '2天前',
      'isRead': true,
    },
    {
      'id': '6',
      'type': 'follow',
      'title': '新关注',
      'message': '用户 @王五 关注了你',
      'time': '3天前',
      'isRead': true,
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
    },
  ];

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
                  notification['isRead'] = true;
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
      body: _notifications.isEmpty
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

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
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
                notification['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: notification['isRead'] ? FontWeight.w500 : FontWeight.w600,
                  color: notification['isRead'] ? Colors.grey[700] : Colors.grey[800],
                ),
              ),
            ),
            if (!notification['isRead'])
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
              notification['message'],
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
                  notification['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                if (notification['imageUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      notification['imageUrl'],
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
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            notification['isRead'] = true;
          });
          // 根据消息类型执行不同的操作
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildNotificationIcon(Map<String, dynamic> notification) {
    String type = notification['type'];
    String? avatarUrl = notification['avatar'];

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
      case 'comment':
        iconData = Icons.comment_outlined;
        iconColor = Colors.blue[600]!;
        break;
      case 'like':
        iconData = Icons.favorite_outline;
        iconColor = Colors.red[500]!;
        break;
      case 'audit':
        iconData = Icons.verified_outlined;
        iconColor = Colors.green[600]!;
        break;
      case 'follow':
        iconData = Icons.person_add_outlined;
        iconColor = Colors.purple[600]!;
        break;
      case 'system':
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

  void _handleNotificationTap(Map<String, dynamic> notification) {
    String type = notification['type'];
    
    switch (type) {
      case 'comment':
      case 'like':
        // 跳转到图片详情页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('跳转到图片详情页')),
        );
        break;
      case 'audit':
        // 跳转到我的图片页面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('跳转到我的图片页面')),
        );
        break;
      case 'follow':
        // 跳转到用户资料页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('跳转到用户资料页')),
        );
        break;
      case 'system':
        // 系统消息，可能不需要跳转
        break;
    }
  }
}