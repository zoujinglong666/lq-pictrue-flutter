import 'package:flutter/material.dart';
import 'package:lq_picture/apis/picture_api.dart';
import '../apis/notific_api.dart';
import '../model/notify.dart';
import '../widgets/skeleton_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/unread_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  late List<NotifyVO> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    // 不在dispose中调用ref,因为widget已被销毁
    super.dispose();
  }

  Future<void> _markAsRead(NotifyVO notification) async {
    if (notification.readStatus == 1) {
      return;
    }
    try {
      await NotifyApi.markRead(notification.id);
      setState(() {
        notification.readStatus = 1;
      });
      // 等待刷新未读数完成
      await ref.read(unreadRefreshNotifierProvider.notifier).refresh();
    } catch (e) {
      print('标记已读失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标记已读失败，请重试')),
      );
    }
  }

  Future<void> _markAllRead() async {
    try {
      // 等待刷新未读数完成
      await ref.read(unreadRefreshNotifierProvider.notifier).clearAll();
      await NotifyApi.markAllRead();
      setState(() {
        for (var notification in _notifications) {
          notification.readStatus = 1;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已标记所有消息为已读')),
        );
      }
    } catch (e) {
      print('标记全部已读失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标记全部已读失败，请重试')),
        );
      }
    }
  }

  Future<void> _deleteNotification(NotifyVO notification) async {
    try {
      await NotifyApi.deleteNotify({
        'id': notification.id,
      });
      setState(() {
        _notifications.remove(notification);
      });
      // 等待刷新未读数完成
      await ref.read(unreadRefreshNotifierProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('消息已删除'),
            action: SnackBarAction(
              label: '撤销',
              onPressed: () async {
                setState(() {
                  _notifications.insert(0, notification);
                });
                await ref.read(unreadRefreshNotifierProvider.notifier).refresh();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败，请重试')),
        );
      }
    }
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
      if (mounted) {
        setState(() {
          _notifications = res.records ?? [];
          _isLoading = false;
        });
        // 使用RefreshNotifier主动刷新未读数
        ref.read(unreadRefreshNotifierProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('获取通知列表失败: $e');
    }
  }
  
  // 删除旧的_syncUnreadBadge和_setUnreadBadge方法，已由RefreshNotifier替代

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
          onPressed: () {
            Navigator.pop(context);
          },
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
            onPressed: _markAllRead,
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
                  padding: const EdgeInsets.all(8),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: _buildDismissibleNotificationItem(
                          notification, index),
                    );
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

  Widget _buildDismissibleNotificationItem(NotifyVO notification, int index) {
    return Dismissible(
      key: Key('notification_${notification.id}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('确认删除'),
              content: const Text('确定要删除这条消息吗？'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('删除'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: _buildNotificationItem(notification),
    );
  }

  Widget _buildNotificationItem(NotifyVO notification) {
    bool isRead = notification.readStatus == 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: _buildNotificationIcon(notification),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                      color: isRead ? Colors.grey[700] : Colors.grey[800],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[500],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatTime(notification.createTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: notification.pictureUrl != null &&
                          notification.pictureUrl!.isNotEmpty
                      ? Image.network(
                          notification.pictureUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey[400], size: 16),
                            );
                          },
                        )
                      : Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.image_outlined,
                              color: Colors.grey[400], size: 16),
                        ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          _markAsRead(notification);
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

  String _formatTime(int timestamp) {
    if (timestamp == 0) return '';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _handleNotificationTap(NotifyVO notification) async {
    String type = notification.type;
    switch (type) {
      case 'COMMENT':
      case 'LIKE':
      case 'PICTURE_REVIEW':
        // 跳转到图片详情页
        final pic = await PictureApi.getPictureDetail({
          'id': notification.pictureId,
        });
        if (notification.pictureId > 0) {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: pic,
          ).then((updatedPicture) {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法跳转，图片ID无效')),
          );
        }
        break;
      case 'SYSTEM':
        // 系统消息，可能不需要跳转
        break;
    }
  }
}
