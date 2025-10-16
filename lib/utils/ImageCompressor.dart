import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui; // 关键：这里导入 ui
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 通用安全压缩器
class ImageCompressor {
  /// 对外暴露的压缩方法
  static Future<File?> safeCompress(File file) async {
    final fileSizeInMB = await file.length() / (1024 * 1024);

    try {
      // 先尝试插件压缩
      final compressed = await _compressWithPlugin(file, fileSizeInMB);
      if (compressed != null) {
        return compressed;
      } else {
        print("插件压缩失败，自动使用备用方案");
        return await _compressWithFallback(file, fileSizeInMB);
      }
    } catch (e) {
      print("插件压缩报错：$e，自动使用备用方案");
      return await _compressWithFallback(file, fileSizeInMB);
    }
  }
  static Future<ui.Image> decodeImageFromListHelper(Uint8List data) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(data, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }
  /// 使用 flutter_image_compress 压缩
  static Future<File?> _compressWithPlugin(File file, double fileSizeInMB) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(file.path);
    final targetPath = path.join(tempDir.path, '${fileName}_plugin.jpg');

    // 动态调整压缩质量
    int quality = 85;
    if (fileSizeInMB > 10) {
      quality = 50;
    } else if (fileSizeInMB > 5) {
      quality = 60;
    } else if (fileSizeInMB > 3) {
      quality = 70;
    }

    // 获取原始尺寸（注意这里用 ui.decodeImageFromList）
    final Uint8List imgBytes = await file.readAsBytes();

    final ui.Image decodedImage = await decodeImageFromListHelper(imgBytes);
    int minWidth = decodedImage.width > 1920 ? 1920 : decodedImage.width;
    int minHeight = decodedImage.height > 1080 ? 1080 : decodedImage.height;

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) return null;

    // 检查文件大小
    final compressedSize = await compressedFile.length();
    final compressedSizeInMB = compressedSize / (1024 * 1024);
    print('插件压缩后大小: ${compressedSizeInMB.toStringAsFixed(2)}MB');

    // 二次压缩（如果 > 2MB）
    if (compressedSizeInMB > 2.0) {
      final secondTargetPath = path.join(tempDir.path, '${fileName}_plugin2.jpg');
      final secondCompressed = await FlutterImageCompress.compressAndGetFile(
        compressedFile.path,
        secondTargetPath,
        quality: quality - 20,
        minWidth: 1280,
        minHeight: 720,
        format: CompressFormat.jpeg,
      );

      if (secondCompressed != null) {
        final finalSize = await File(secondCompressed.path).length();
        final finalSizeInMB = finalSize / (1024 * 1024);
        print('插件二次压缩后大小: ${finalSizeInMB.toStringAsFixed(2)}MB');
        return File(secondCompressed.path);
      }
    }

    return File(compressedFile.path);
  }

  /// Flutter 内置备用压缩
  static Future<File?> _compressWithFallback(File file, double fileSizeInMB) async {
    print('使用备用压缩方案...');

    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(file.path);
    final targetPath = path.join(tempDir.path, '${fileName}_fallback.jpg');

    // 读取图片数据
    final imageBytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: fileSizeInMB > 5 ? 1280 : 1920,
      targetHeight: fileSizeInMB > 5 ? 720 : 1080,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // 转换为字节数据
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('备用压缩失败：无法转换图片数据');
    }

    // 写入文件
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(byteData.buffer.asUint8List());

    // 检查压缩后大小
    final compressedSize = await compressedFile.length();
    final compressedSizeInMB = compressedSize / (1024 * 1024);
    print('备用方案压缩后大小: ${compressedSizeInMB.toStringAsFixed(2)}MB');

    // 如果仍然太大，抛出异常
    if (compressedSizeInMB > 2.0) {
      throw Exception('图片压缩后仍超过2MB（${compressedSizeInMB.toStringAsFixed(2)}MB），请选择更小的图片');
    }

    return compressedFile;
  }
}
