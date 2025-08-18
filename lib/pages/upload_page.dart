import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
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
    // 这里直接用 decoration 来画，TabBar 自带的动画值会传进来
    indicator.decoration.createBoxPainter().paint(canvas, offset, configuration);
  }
}

class _UploadPageState extends State<UploadPage> with SingleTickerProviderStateMixin {
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
  String _selectedCategory = '风景';
  final List<String> _categories = ['风景', '人物', '建筑', '科技', '商务', '自然', '艺术', '其他'];

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

  // 文件上传相关方法
  Future<void> _pickImages() async {
    try {
      // 检查当前已选择的图片数量
      if (_selectedImages.length >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('最多只能选择6张图片')),
        );
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        // 计算还能选择多少张图片
        final remainingSlots = 6 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();
        
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });

        // 如果选择的图片超过了限制，给出提示
        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已选择${imagesToAdd.length}张图片，最多只能选择6张')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // 检查当前已选择的图片数量
      if (_selectedImages.length >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('最多只能选择6张图片')),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拍照失败: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // URL上传相关方法
  void _addUrlImage() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入图片URL')),
      );
      return;
    }

    // 简单的URL格式验证
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的URL地址')),
      );
      return;
    }

    setState(() {
      _urlImages.add(url);
      _urlController.clear();
    });
  }

  void _removeUrlImage(int index) {
    setState(() {
      _urlImages.removeAt(index);
    });
  }

  // 通用上传方法
  void _uploadImages() {
    bool hasImages = false;
    String uploadType = '';

    if (_tabController.index == 0) {
      // 文件上传
      if (_selectedImages.isNotEmpty) {
        hasImages = true;
        uploadType = '文件';
      }
    } else {
      // URL上传
      if (_urlImages.isNotEmpty) {
        hasImages = true;
        uploadType = 'URL';
      }
    }

    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择至少一张图片')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    // 模拟上传过程
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('正在上传$uploadType...'),
          ],
        ),
      ),
    );

    // 模拟上传延迟
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 关闭加载对话框
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${uploadType}上传成功！')),
      );
      
      // 清空表单
      setState(() {
        _selectedImages.clear();
        _urlImages.clear();
        _titleController.clear();
        _descriptionController.clear();
        _urlController.clear();
        _selectedCategory = '风景';
      });
    });
  }

  bool _hasImages() {
    if (_tabController.index == 0) {
      return _selectedImages.isNotEmpty;
    } else {
      return _urlImages.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '上传图片',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_hasImages())
                    TextButton(
                      onPressed: _uploadImages,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('上传'),
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
            indicatorColor: Colors.transparent, // ✅ 去掉默认下划线
            dividerColor: Colors.transparent,   // ✅ 去掉底部分割线
            indicatorSize: TabBarIndicatorSize.tab, // ✅ 关键点：撑满整个 tab
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
            tabs: const [
              Tab(text: '文件上传'),
              Tab(text: 'URL上传'),
            ],
          ),
        ),

        const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 文件上传页面
                  _buildFileUploadTab(),
                  // URL上传页面
                  _buildUrlUploadTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片选择区域
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: _selectedImages.isEmpty ? 200 : 320, // 动态调整高度
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImages.isEmpty
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
                              side: const BorderSide(color: Color(0xFF00BCD4)),
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
                        padding: const EdgeInsets.all(12),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 图片网格
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _selectedImages.length + (_selectedImages.length < 6 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _selectedImages.length) {
                                return GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
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

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(File(_selectedImages[index].path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
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
          _buildCommonFields(),
        ],
      ),
    );
  }

  Widget _buildUrlUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                Icon(
                  Icons.link,
                  size: 48,
                  color: Colors.grey[400],
                ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'https://example.com/image.jpg',
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _urlImages.length,
              itemBuilder: (context, index) {
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
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'URL图片 ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                      IconButton(
                        onPressed: () => _removeUrlImage(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        const SizedBox(height: 20),

        // 描述输入
        const Text(
          '描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        const SizedBox(height: 20),

        // 分类选择
        const Text(
          '分类',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
