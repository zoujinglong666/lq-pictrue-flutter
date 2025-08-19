/// @author: jiangjunhui
/// @date: 2025/1/7
library;
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheImageManager {
  static final MyCustomCacheManager _cacheManager = MyCustomCacheManager();

  /// 获取图片本地路径
  static Future<String?> getFilePath(String imageUrl) async {
    final FileInfo? fileInfo = await _cacheManager.getFileFromCache(imageUrl);
    return fileInfo?.file.path;
  }

  /// 移除指定路径下图片
  static Future<void> clearImageCache(String imageUrl) async {
    // 移除单个文件的缓存
    try {
      await _cacheManager.removeFile(imageUrl);
      print(' 移除指定路径下图片已成功移除');
    } catch (e) {
      print(' 移除指定路径下图片缓存时出错: $e');
    }
  }

  /// 移除所有图片
  static Future<void> clearAllCache() async {
    try {
      await _cacheManager.emptyCache();
      print('移除所有图片缓存已成功移除');
    } catch (e) {
      print('移除所有图片缓存时出错: $e');
    }
  }

  /// 获取缓存大小
  static Future<String> getCacheSize() async {
    int size = await _cacheManager.store.getCacheSize();
    double cacheSize = size / 1024 / 1024;
    return cacheSize.toStringAsFixed(2);
  }


}

class MyCustomCacheManager extends CacheManager {
  static const key = 'Custom_Cached_Image_Key';

  static final MyCustomCacheManager _instance = MyCustomCacheManager._();

  factory MyCustomCacheManager() {
    return _instance;
  }

  MyCustomCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30), // 缓存有效期
          maxNrOfCacheObjects: 100, // 最大缓存数量
          repo: JsonCacheInfoRepository(databaseName: key),
        ));
}
