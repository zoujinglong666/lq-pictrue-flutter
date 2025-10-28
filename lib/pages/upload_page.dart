import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lq_picture/apis/picture_api.dart';
import 'package:lq_picture/providers/auth_provider.dart';
import 'package:lq_picture/utils/keyboard_utils.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../Consts/index.dart';
import '../common/toast.dart';

class UploadPage extends ConsumerStatefulWidget {
  final String? spaceId;
  const UploadPage({super.key,this.spaceId});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class CustomTabIndicator extends Decoration {
  final BoxDecoration decoration;

  const CustomTabIndicator({required this.decoration});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(this, onChanged);
  }
}

class _CustomPainter extends BoxPainter {
  final CustomTabIndicator indicator;

  _CustomPainter(this.indicator, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    indicator.decoration.createBoxPainter().paint(
      canvas,
      offset,
      configuration,
    );
  }
}

class _UploadPageState extends ConsumerState<UploadPage>
    with SingleTickerProviderStateMixin, KeyboardDismissMixin {
  late TabController _tabController;

  // 文件上传相关
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // URL上传相关
  final TextEditingController _urlController = TextEditingController();
  final List<String> _urlImages = [];

  // 通用字段
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = '模板';
  String _selectedTag = '热门';

  // 上传状态管理
  bool _isUploading = false;
  bool _isSubmitting = false;
  List<PictureUploadVO> _uploadedImages = [];
  Map<String, double> _uploadProgress = {};
  bool _showUploadedImages = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // 显示成功对话框
  void _showSuccessDialog(BuildContext context, String uploadType, int imageCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 自动关闭对话框
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标 - 带动画效果的绿色对勾
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF66BB6A),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // 成功文字
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF66BB6A),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    '${uploadType}成功！',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 详细信息
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '共${imageCount}张图片',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 光晕效果装饰
                Container(
                  height: 2,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.0),
                        Colors.green.withOpacity(0.6),
                        Colors.green.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 文件上传相关方法
  Future<void> _pickImages() async {
    try {
      if (_selectedImages.length >= 6) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('最多只能选择6张图片')));
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final remainingSlots = 6 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();

        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          MyToast.showError('已选择${imagesToAdd.length}张图片，最多只能选择6张');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (_selectedImages.length >= 6) {
        MyToast.showError('最多只能选择6张');
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 图片压缩方法
  Future<File?> _compressImage(File file) async {
    try {
      // 获取文件大小
      final fileSize = await file.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      // 如果文件小于2MB，直接返回原文件
      if (fileSizeInMB <= 2.0) {
        print('文件大小: ${fileSizeInMB.toStringAsFixed(2)}MB，无需压缩');
        return file;
      }

      print('文件大小: ${fileSizeInMB.toStringAsFixed(2)}MB，开始压缩...');

      // 首先尝试使用 flutter_image_compress
      try {
        return await _compressWithPlugin(file, fileSizeInMB);
      } catch (e) {
        print('插件压缩失败，尝试备用方案: $e');
        // 如果插件失败，使用备用压缩方案
        return await _compressWithFallback(file);
      }
    } catch (e) {
      print('图片压缩完全失败: $e');
      // 重新获取文件大小进行检查
      final fileSize = await file.length();
      final currentFileSizeInMB = fileSize / (1024 * 1024);
      // 如果文件太大，不允许上传
      if (currentFileSizeInMB > 2.0) {
        throw Exception('图片文件过大（${currentFileSizeInMB.toStringAsFixed(2)}MB），请选择小于2MB的图片');
      }
      return file;
    }
  }

  // 使用插件压缩
  Future<File?> _compressWithPlugin(File file, double fileSizeInMB) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(file.path);
    final targetPath = path.join(tempDir.path, '${fileName}_compressed.jpg');

    // 计算压缩质量
    int quality = 85;
    if (fileSizeInMB > 10) {
      quality = 50;
    } else if (fileSizeInMB > 5) {
      quality = 60;
    } else if (fileSizeInMB > 3) {
      quality = 70;
    }

    final decodedImage = await decodeImageFromList(await file.readAsBytes());
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

    if (compressedFile != null) {
      final compressedSize = await File(compressedFile.path).length();
      final compressedSizeInMB = compressedSize / (1024 * 1024);

      print('插件压缩后文件大小: ${compressedSizeInMB.toStringAsFixed(2)}MB');

      // 如果仍然超过2MB，进行二次压缩
      if (compressedSizeInMB > 2.0) {
        final secondTargetPath = path.join(tempDir.path, '${fileName}_compressed2.jpg');
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
          print('二次压缩后文件大小: ${finalSizeInMB.toStringAsFixed(2)}MB');
          return File(secondCompressed.path);
        }
      }

      return File(compressedFile.path);
    }

    throw Exception('插件压缩失败');
  }


// 压缩到 ~1MB
  Future<File?> _compressWithFallback(File file) async {
    print('使用备用压缩方案...');

    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(file.path);
    final targetPath =
    path.join(tempDir.path, '${fileName}_fallback_compressed.jpg');

    // 读取原图
    final imageBytes = await file.readAsBytes();
    final decodedImg = img.decodeImage(imageBytes);
    if (decodedImg == null) {
      throw Exception('备用压缩失败：无法解码图片');
    }

    // 初始参数
    int quality = 90; // JPEG 压缩质量（100 = 无损）
    List<int> jpegBytes = [];

    // 循环压缩直到小于 1MB
    do {
      jpegBytes = img.encodeJpg(decodedImg,
          quality: quality); // subsampling=2 更省空间
      quality -= 10; // 逐步降低质量
    } while (jpegBytes.length / (1024 * 1024) > 1.0 && quality > 10);

    // 保存文件
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(jpegBytes);

    final compressedSize = await compressedFile.length();
    print(
        '备用方案压缩后文件大小: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)}MB (质量=$quality)');

    return compressedFile;
  }


  // URL上传相关方法
  void _addUrlImage() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入图片URL')));
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的URL地址')));
      return;
    }

    setState(() {
      _urlImages.add(url);
      _urlController.clear();
    });
    // _uploadSingleUrlImage(url,0);
  }

  void _removeUrlImage(int index) {
    setState(() {
      _urlImages.removeAt(index);
    });
  }

  // 通用上传方法
  Future<void> _uploadImages() async {
    bool hasImages = false;
    String uploadType = '';

    if (_tabController.index == 0) {
      if (_selectedImages.isNotEmpty) {
        hasImages = true;
        uploadType = '文件';
      }
    } else {
      if (_urlImages.isNotEmpty) {
        hasImages = true;
        uploadType = 'URL';
      }
    }

    if (!hasImages) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择至少一张图片')));
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入标题')));
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadedImages.clear();
      _uploadProgress.clear();
    });

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user == null) {
        throw Exception('用户未登录');
      }

      if (_tabController.index == 0) {
        await _uploadFileImages(user.id.toString());
      } else {
        await _uploadUrlImages();
      }

      // 显示成功提示和动画
      _showSuccessDialog(context, uploadType, _uploadedImages.length);

      // 上传成功后显示已上传的图片，让用户填写信息
      setState(() {
        _showUploadedImages = true;
        _selectedImages.clear();
        _urlImages.clear();
        _urlController.clear();
        // 保留标题、描述和分类，让用户可以修改
        _titleController.text = _titleController.text.trim();
        _descriptionController.text = _descriptionController.text.trim();

      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
// 平滑推进工具（用于压缩、收尾）
  Future<void> _smoothProgress(String key, double from, double to, int durationMs) async {
    const step = 16; // 刷新频率约60FPS
    int times = (durationMs / step).floor();
    for (int i = 0; i < times; i++) {
      double t = from + ((to - from) * (i / times));
      _setProgress(key, t);
      await Future.delayed(const Duration(milliseconds: step));
    }
    _setProgress(key, to);
  }

// 更新UI封装
  void _setProgress(String key, double progress) {
    setState(() {
      _uploadProgress[key] = double.parse(progress.toStringAsFixed(2));
    });
  }

// ==================== 智能上传（含抖动进度）====================
  Future<void> _uploadFileImages(String userId) async {
    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      final imageKey = 'file_$i';

      // 初始化进度
      _setProgress(imageKey, 0.0);

      try {
        print('开始压缩第${i + 1}张图片...');
        final startTime = DateTime.now();
        final compressedFile = await _compressImage(File(image.path));
        final finalFile = compressedFile ?? File(image.path);
        final compressDuration = DateTime.now().difference(startTime).inMilliseconds;

        // 压缩阶段: 根据耗时推进 0% → 20%
        await _smoothProgress(imageKey, 0.0, 0.2, compressDuration ~/ 1.5);

        // 准备上传阶段: 稳定推进 20% → 30%
        await _smoothProgress(imageKey, 0.2, 0.3, 200);

        // ------------------ 模拟上传阶段 30% → ~90%（含抖动） ------------------
        double fakeUploadProgress = 0.3;
        while (fakeUploadProgress < 0.9) {
          fakeUploadProgress += (0.03 + (0.02 * (DateTime.now().millisecond % 3))); // 随机微抖动
          _setProgress(imageKey, fakeUploadProgress.clamp(0.3, 0.9));
          await Future.delayed(const Duration(milliseconds: 120));
        }

        // ------------------ 调用上传接口 ------------------
        final result = await PictureApi.uploadPicture(
          body: {"spaceId": widget.spaceId},
          files: [finalFile],
        );

        // ------------------ 上传完成封装 90% → 100% ------------------
        await _smoothProgress(imageKey, 0.9, 1.0, 300);

        // ------------------ 图片编辑 ------------------
        if (result.thumbnailUrl?.isNotEmpty ?? false) {
          try {
            final editRes = await PictureApi.editPicture({
              'name': _titleController.text.trim().isEmpty
                  ? '图片_${DateTime.now().millisecondsSinceEpoch}'
                  : _titleController.text.trim(),
              'introduction': _descriptionController.text.trim(),
              'category': _selectedCategory,
              'id': result.id,
              "tags": [_selectedTag]
            });
            print('文件编辑成功: $editRes');
          } catch (e) {
            print('文件编辑错误: $e');
          }
        }

        // 上传成功加入记录
        _uploadedImages.add(result);
        print('第${i + 1}张图片上传成功');
      } catch (e) {
        print('文件上传错误: $e');
        _setProgress(imageKey, -1.0);
      }
    }
  }



  /// 单张 URL 上传
  Future<void> _uploadSingleUrlImage(String imageUrl, int index) async {
    final imageKey = 'url_$index';

    if(imageUrl.isEmpty){
      throw Exception('URL图片 ${index + 1} 为空');
    }

    setState(() {
      _uploadProgress[imageKey] = 0.0;
    });

    try {
      // 模拟上传进度
      for (double progress = 0.2; progress < 1.0; progress += 0.2) {
        setState(() {
          _uploadProgress[imageKey] = progress;
        });
        await Future.delayed(const Duration(milliseconds: 150));
      }

      final result = await PictureApi.uploadPictureByUrl({
        "spaceId": widget.spaceId,
        "fileUrl": imageUrl,
      });

      setState(() {
        _uploadProgress[imageKey] = 1.0;
        _uploadedImages.add(result);
      });

      // 只在第一张图片上传成功后自动填写标题
      if (index == 0 && result.name != null && result.name!.isNotEmpty) {
        setState(() {
          _titleController.text = result.name!;
        });
      }
    } catch (e) {
      setState(() {
        _uploadProgress[imageKey] = -1.0;
      });
      throw Exception('URL图片 ${index + 1} 上传失败: $e');
    }
  }

  /// 批量 URL 上传
  Future<void> _uploadUrlImages() async {
    for (int i = 0; i < _urlImages.length; i++) {
      await _uploadSingleUrlImage(_urlImages[i], i);
    }
  }


  bool _hasImages() {
    if (_showUploadedImages) {
      return _uploadedImages.isNotEmpty;
    }
    if (_tabController.index == 0) {
      return _selectedImages.isNotEmpty;
    } else {
      return _urlImages.isNotEmpty;
    }
  }

  // 一键上传并提交方法
  Future<void> _uploadAndSubmit() async {
    bool hasImages = false;
    String uploadType = '';

    if (_tabController.index == 0) {
      if (_selectedImages.isNotEmpty) {
        hasImages = true;
        uploadType = '文件';
      }
    } else {
      if (_urlImages.isNotEmpty) {
        hasImages = true;
        uploadType = 'URL';
      }
    }

    if (!hasImages) {
      MyToast.showError("请选择至少一张图片");
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      MyToast.showError("请输入标题");
      return;
    }

    setState(() {
      _isUploading = true;
      _isSubmitting = true;
      _uploadedImages.clear();
      _uploadProgress.clear();
    });

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user == null) {
        throw Exception('用户未登录');
      }

      // 第一步：上传图片
      if (_tabController.index == 0) {
        await _uploadFileImages(user.id.toString());
      } else {
        await _uploadUrlImages();
      }

      // 第二步：更新图片信息
      if (_uploadedImages.isNotEmpty) {
        final editRes = await PictureApi.editPicture({
          'name': _titleController.text.trim(),
          'introduction': _descriptionController.text.trim(),
          'category': _selectedCategory,
          'id': _uploadedImages.first.id,
          "tags": [_selectedTag],
        });

        if (editRes) {
          // 显示成功提示
          _showSuccessDialog(context, '上传并提交', _uploadedImages.length);
          
          // 清空所有数据，重置状态
          setState(() {
            _selectedImages.clear();
            _urlImages.clear();
            _uploadedImages.clear();
            _titleController.clear();
            _descriptionController.clear();
            _urlController.clear();
            _selectedCategory = '模板';
            _selectedTag = '热门';
            _showUploadedImages = false;
            _uploadProgress.clear();
          });
          
          // 上传成功后返回true给调用页面
          // 如果是通过导航跳转过来的（有spaceId参数），返回true表示上传成功
          if (mounted && widget.spaceId != null) {
            Navigator.of(context).pop(true);
          }
        }
      }
    } catch (e) {
      MyToast.showError("操作失败: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _isSubmitting = false;
      });
    }
  }

  // 最终提交方法
  Future<void> _submitImages() async {
    if (_titleController.text.trim().isEmpty) {

      MyToast.showError("请输入标题");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final editRes = await PictureApi.editPicture({
        'name': _titleController.text
            .trim()
            .isEmpty
            ? '图片_${DateTime
            .now()
            .millisecondsSinceEpoch}'
            : _titleController.text.trim(),
        'introduction': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'id': _uploadedImages.first.id,
        "tags": [_selectedTag],  // 把单个字符串包成 List
      });

      if(editRes){
        // 显示成功提示
        _showSuccessDialog(context, '提交', _uploadedImages.length);
      }

      // 清空所有数据，重置状态
      setState(() {
        _selectedImages.clear();
        _urlImages.clear();
        _uploadedImages.clear();
        _titleController.clear();
        _descriptionController.clear();
        _urlController.clear();
        _selectedCategory = '模板';
        _selectedTag = '热门';
        _showUploadedImages = false;
        _uploadProgress.clear();
      });
      
      // 提交成功后返回true给调用页面
      // 如果是通过导航跳转过来的（有spaceId参数），返回true表示上传成功
      if (mounted && widget.spaceId != null) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {

      MyToast.showError("提交失败");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 返回按钮 - 仅当有 spaceId 时显示
                  if (widget.spaceId != null && widget.spaceId!.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      icon: const Icon(Icons.arrow_back),
                      tooltip: '返回',
                    ),
                  Flexible(
                    child: Text(
                      widget.spaceId != null ? "个人图库${widget.spaceId}" : "上传公共图库",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),

                  if (_hasImages())
                    Row(
                      children: [
                        // 一键上传并提交按钮
                        if (!_showUploadedImages)
                          TextButton(
                            onPressed: (_isUploading || _isSubmitting) ? null : _uploadAndSubmit,
                            style: TextButton.styleFrom(
                              backgroundColor: (_isUploading || _isSubmitting)
                                  ? Colors.grey.shade400
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: (_isUploading || _isSubmitting)
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_isUploading ? '上传中...' : '提交中...'),
                                    ],
                                  )
                                : const Text('一键提交'),
                          ),
                        
                        // 分步操作按钮（保留原有功能）
                        if (!_showUploadedImages) const SizedBox(width: 8),
                        if (!_showUploadedImages)
                          TextButton(
                            onPressed: (_isUploading || _isSubmitting) ? null : _uploadImages,
                            style: TextButton.styleFrom(
                              backgroundColor: (_isUploading || _isSubmitting)
                                  ? Colors.grey.shade400
                                  : const Color(0xFF00BCD4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('仅上传'),
                          ),
                        
                        // 已上传状态下的提交按钮
                        if (_showUploadedImages)
                          TextButton(
                            onPressed: (_isUploading || _isSubmitting) ? null : _submitImages,
                            style: TextButton.styleFrom(
                              backgroundColor: (_isUploading || _isSubmitting)
                                  ? Colors.grey.shade400
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isSubmitting
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('提交中...'),
                                    ],
                                  )
                                : const Text('提交图片'),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: CustomTabIndicator(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BCD4), Color(0xFF26C6DA)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [Tab(text: '文件上传'), Tab(text: 'URL上传')],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFileUploadTab(), _buildUrlUploadTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), // 增加底部内边距避免被导航栏遭挡
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // 图片选择区域
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: _selectedImages.isEmpty ? 200 : 280,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child:
                _selectedImages.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '点击选择图片或拖拽到此处',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '支持 JPG、PNG 格式，最多6张',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('选择图片'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BCD4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _pickImageFromCamera,
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('拍照'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF00BCD4),
                                side: const BorderSide(
                                  color: Color(0xFF00BCD4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        // 图片数量提示
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(
                                '已选择 ${_selectedImages.length}/6 张图片',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedImages.length < 6)
                                TextButton.icon(
                                  onPressed: _pickImages,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('添加更多'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF00BCD4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // 图片网格
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount:
                                _selectedImages.length +
                                (_selectedImages.length < 6 ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _selectedImages.length) {
                                return GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '添加',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final imageKey = 'file_$index';
                              final progress = _uploadProgress[imageKey] ?? 0.0;

                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(_selectedImages[index].path),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // 上传进度覆盖层
                                  if (_isUploading &&
                                      progress > 0.0 &&
                                      progress < 1.0)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: progress,
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.3),
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                    Color
                                                  >(Colors.white),
                                              strokeWidth: 3,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${(progress * 100).toInt()}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  // 上传成功标识 - 精致渐变对勾
                                  if (progress == 1.0)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.elasticOut,
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF4CAF50),
                                                    Color(0xFF66BB6A),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.green.withOpacity(0.5),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  // 上传失败标识
                                  if (progress == -1.0)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  // 删除按钮
                                  if (!_isUploading)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 24),
          
          // 显示已上传的图片预览
          if (_showUploadedImages && _uploadedImages.isNotEmpty) ...[
            const Text(
              '已上传的图片',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _uploadedImages.length,
                itemBuilder: (context, index) {
                  final uploadedImage = _uploadedImages[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          // 使用后端返回的URL显示图片
                          Image.network(
                            uploadedImage.thumbnailUrl ?? uploadedImage.url ?? '',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          // 成功上传标识
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          // 图片信息覆盖层
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Text(
                                uploadedImage.name ?? '图片 ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          _buildCommonFields(),
        ],
      ),
    );
  }

  Widget _buildUrlUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), // 增加底部内边距避免被导航栏遭挡
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL输入区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.link, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '通过URL添加图片',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '输入图片的网络地址',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: '请输入图片的网络地址',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF00BCD4),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(Icons.link, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addUrlImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('添加'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // URL图片列表
          if (_urlImages.isNotEmpty) ...[
            const Text(
              '已添加的图片',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _urlImages.length,
              itemBuilder: (context, index) {
                final imageKey = 'url_$index';
                final progress = _uploadProgress[imageKey] ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _urlImages[index],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                    ),
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // 上传进度覆盖层
                          if (_isUploading && progress > 0.0 && progress < 1.0)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withOpacity(0.6),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // 上传成功标识 - 精致渐变对勾
                          if (progress == 1.0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF66BB6A),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          // 上传失败标识
                          if (progress == -1.0)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'URL图片 ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_isUploading &&
                                    progress > 0.0 &&
                                    progress < 1.0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '上传中...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (progress == 1.0 && !_isUploading) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '已上传',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (progress == -1.0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '上传失败',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _urlImages[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!_isUploading)
                        IconButton(
                          onPressed: () => _removeUrlImage(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          _buildCommonFields(),
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题输入
        const Text(
          '标题',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '请输入图片标题',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00BCD4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 描述输入
        const Text(
          '描述',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '请输入图片描述（可选）',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00BCD4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 分类选择
        const Text(
          '分类',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items:
              Consts.pictureOptions.categoryList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          ),
        ),

        // 分类选择
        const Text(
          '标签',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTag,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTag = newValue;
                  });
                }
              },
              items:
              Consts.pictureOptions.tagList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
