import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/picture.dart';

/// 图片更新事件
class PictureUpdateEvent {
  final String pictureId;
  final PictureVO updatedPicture;
  final DateTime timestamp;

  PictureUpdateEvent({
    required this.pictureId,
    required this.updatedPicture,
  }) : timestamp = DateTime.now();
}

/// 图片更新通知器
class PictureUpdateNotifier extends StateNotifier<PictureUpdateEvent?> {
  PictureUpdateNotifier() : super(null);

  /// 通知图片已更新（点赞、收藏等状态变化）
  void notifyPictureUpdate(PictureVO picture) {
    state = PictureUpdateEvent(
      pictureId: picture.id,
      updatedPicture: picture,
    );
  }

  /// 清除更新事件
  void clear() {
    state = null;
  }
}

/// 图片更新事件 Provider
final pictureUpdateProvider = StateNotifierProvider<PictureUpdateNotifier, PictureUpdateEvent?>(
  (ref) => PictureUpdateNotifier(),
);
