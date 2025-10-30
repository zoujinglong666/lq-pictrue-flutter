import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
class AvatarEditorPage extends StatefulWidget {
  final File imageFile;
  
  const AvatarEditorPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<AvatarEditorPage> createState() => _AvatarEditorPageState();
}
class _AvatarEditorPageState extends State<AvatarEditorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isProcessing = false;
  bool _hasReturned = false; // 防止重复返回

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cropImage() async {
    // 防止重复处理
    if (_isProcessing || _hasReturned) return;
    
    setState(() {
      _isProcessing = true;
    });

    CroppedFile? croppedFile;
    
    try {
      // 使用 try-catch 包裹 cropImage 调用
      croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '编辑头像',
            toolbarColor: const Color(0xFF8A9BAE),
            toolbarWidgetColor: Colors.white,
            backgroundColor: const Color(0xFFF5F5F5),
            activeControlsWidgetColor: const Color(0xFF8A9BAE),
            statusBarColor: const Color(0xFF8A9BAE),
            cropFrameColor: const Color(0xFFB8C5D6),
            cropGridColor: Colors.white.withOpacity(0.3),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropFrameStrokeWidth: 3,
            cropGridRowCount: 3,
            cropGridColumnCount: 3,
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: '编辑头像',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            minimumAspectRatio: 1.0,
            rectX: 1,
            rectY: 1,
          ),
        ],
      );
    } catch (e) {
      // 捕获裁剪过程中的任何异常
      print('裁剪异常: $e');
      if (!mounted || _hasReturned) return;
      
      setState(() {
        _isProcessing = false;
      });
      
      _hasReturned = true;
      Navigator.of(context).pop();
      return;
    }

    // 检查页面是否已销毁或已返回
    if (!mounted || _hasReturned) return;
    
    setState(() {
      _isProcessing = false;
    });

    // 标记已返回,防止重复
    _hasReturned = true;
    
    // 延迟一帧再返回,确保状态稳定
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    if (croppedFile != null) {
      // 返回裁剪后的文件
      Navigator.of(context).pop(File(croppedFile.path));
    } else {
      // 用户取消裁剪,返回null
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF5F5F5),
              const Color(0xFFE8EDF2),
              const Color(0xFFF0E6E8),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // 顶部工具栏
                      _buildAppBar(),
                      
                      // 图片预览区域
                      Expanded(
                        child: _buildImagePreview(),
                      ),
                      
                      // 底部操作按钮
                      _buildBottomActions(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA8B5).withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消按钮
          TextButton(
            onPressed: (_isProcessing || _hasReturned) ? null : () {
              if (!_hasReturned) {
                _hasReturned = true;
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9CA8B5),
            ),
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 标题
          const Text(
            '编辑头像',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
              letterSpacing: 0.5,
            ),
          ),
          
          // 占位，保持对称
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA8B5).withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 图片
            Image.file(
              widget.imageFile,
              fit: BoxFit.contain,
            ),
            
            // 提示文字
            if (!_isProcessing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: const Text(
                    '点击下方按钮开始编辑',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA8B5).withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF9CA8B5).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // 编辑按钮
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8A9BAE),
                  Color(0xFFB8C5D6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A9BAE).withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _cropImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '处理中...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.crop_rotate,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '开始编辑',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 功能提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB8C5D6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB8C5D6).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A9BAE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8A9BAE),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '支持裁剪、旋转等编辑功能',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A5568),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
