import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  
  const ImagePreviewPage({
    super.key, 
    required this.imageUrl,
    this.heroTag,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _isZoomed = false;
  
  @override
  void initState() {
    super.initState();
    
    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // 启动进入动画
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    _transformationController.dispose();
    
    // 恢复状态栏
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }
  
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }
  
  void _handleDoubleTap() {
    if (_isZoomed) {
      // 缩小到原始大小
      _transformationController.value = Matrix4.identity();
      _scaleController.reverse();
      _isZoomed = false;
    } else {
      // 放大到指定位置
      final position = _doubleTapDetails!.localPosition;
      final double scale = 2.0;
      
      // 以点击位置为中心进行缩放
      // 计算缩放变换矩阵
      final zoomed = Matrix4.identity()
        ..translate(position.dx, position.dy)
        ..scale(scale)
        ..translate(-position.dx, -position.dy);
      
      _transformationController.value = zoomed;
      _scaleController.forward();
      _isZoomed = true;
    }
  }
  
  void _handlePanEnd(ScaleEndDetails details) {
    // 检查是否需要回弹
    final Matrix4 matrix = _transformationController.value;
    final double scale = matrix.getMaxScaleOnAxis();
    
    if (scale < 1.0) {
      // 如果缩放小于1，回弹到1
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    }
  }
  
  Future<void> _handleBackPress() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBackPress();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.black.withOpacity(_fadeAnimation.value * 0.9),
              child: Stack(
                children: [
                  // 主要图片区域
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        // 单击退出
                        _handleBackPress();
                      },
                      onDoubleTapDown: _handleDoubleTapDown,
                      onDoubleTap: _handleDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.8,
                        maxScale: 4.0,
                        onInteractionEnd: _handlePanEnd,
                        clipBehavior: Clip.none,
                        child: Center(
                          child: Hero(
                            tag: widget.heroTag ?? 'preview_${widget.imageUrl}',
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width,
                                maxHeight: MediaQuery.of(context).size.height,
                              ),
                              child: Image.network(
                                widget.imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '加载中...',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 48,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '图片加载失败',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 顶部状态栏区域
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).padding.top + 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _handleBackPress,
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 底部提示区域
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        '轻触退出 · 双击缩放 · 捏合调整',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7 * _fadeAnimation.value),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}