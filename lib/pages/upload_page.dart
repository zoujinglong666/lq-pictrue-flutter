import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  final List<UploadImageItem> _selectedImages = [];
  final int _maxImages = 6;
  
  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传6张图片')),
      );
      return;
    }
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(UploadImageItem(
          file: File(image.path),
          progress: 0,
          status: UploadStatus.pending,
        ));
      });
      
      // 模拟上传进度
      _simulateUpload(_selectedImages.length - 1);
    }
  }
  
  Future<void> _takePicture() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能上传6张图片')),
      );
      return;
    }
    
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImages.add(UploadImageItem(
          file: File(image.path),
          progress: 0,
          status: UploadStatus.pending,
        ));
      });
      
      // 模拟上传进度
      _simulateUpload(_selectedImages.length - 1);
    }
  }
  
  void _simulateUpload(int index) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && index < _selectedImages.length) {
        setState(() {
          _selectedImages[index].status = UploadStatus.uploading;
        });
        
        double progress = 0;
        const interval = Duration(milliseconds: 100);
        
        void updateProgress() {
          if (!mounted || index >= _selectedImages.length) return;
          
          setState(() {
            progress += 0.02;
            _selectedImages[index].progress = progress;
            
            if (progress >= 1) {
              _selectedImages[index].status = UploadStatus.completed;
              return;
            }
          });
          
          if (progress < 1) {
            Future.delayed(interval, updateProgress);
          }
        }
        
        updateProgress();
      }
    });
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传图片', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 顶部相机图标
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          // 图片卡片横向滚动区域
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length < _maxImages 
                  ? _selectedImages.length + 1 
                  : _selectedImages.length,
              itemBuilder: (context, index) {
                // 添加按钮卡片
                if (index == _selectedImages.length && index < _maxImages) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF4FC3F7)),
                                  title: const Text('从相册选择'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF4FC3F7)),
                                  title: const Text('拍照'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _takePicture();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 32, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              '添加图片',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                // 图片卡片
                final item = _selectedImages[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: index == 0 ? const Color(0xFF4FC3F7) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            item.file,
                            width: 120,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // 上传状态指示器
                      if (item.status == UploadStatus.uploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: item.progress,
                                  color: const Color(0xFF4FC3F7),
                                  backgroundColor: Colors.white.withOpacity(0.5),
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // 完成标记
                      if (item.status == UploadStatus.completed)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4FC3F7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      
                      // 删除按钮
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
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
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 上传提示
          if (_selectedImages.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '点击上方"添加图片"按钮\n开始上传您的作品',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 权限提示
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF4FC3F7), size: 20),
                        SizedBox(width: 8),
                        Text(
                          '上传须知',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 请确保您拥有上传图片的版权或使用权\n'
                      '• 每张图片大小不超过10MB\n'
                      '• 支持JPG、PNG、HEIF等常见格式\n'
                      '• 上传完成后可编辑图片信息和标签',
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 底部按钮
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 检查是否所有图片都已上传完成
                    bool allCompleted = _selectedImages.every(
                      (item) => item.status == UploadStatus.completed
                    );
                    
                    if (!allCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请等待所有图片上传完成')),
                      );
                      return;
                    }
                    
                    // 导航到编辑信息页面
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('所有图片上传成功！')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '继续',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 上传状态枚举
enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
}

// 上传图片项
class UploadImageItem {
  final File file;
  double progress;
  UploadStatus status;
  
  UploadImageItem({
    required this.file,
    this.progress = 0,
    this.status = UploadStatus.pending,
  });
}