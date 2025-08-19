import 'package:flutter/material.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imageUrl;
  
  const ImagePreviewPage({super.key, required this.imageUrl});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
  
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }
  
  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // 如果已经放大，则恢复原始大小
      _transformationController.value = Matrix4.identity();
    } else {
      // 否则放大到2倍
      final position = _doubleTapDetails!.localPosition;
      final double scale = 2.0;
      
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);
      
      final zoomed = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
      
      _transformationController.value = zoomed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Hero(
              tag: 'preview_${widget.imageUrl}',
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF4FC3F7),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Text(
          '提示：双击放大/缩小，捏合手势调整大小，拖动可平移图片',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}