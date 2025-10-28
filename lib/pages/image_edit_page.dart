import 'package:flutter/material.dart';
import 'package:lq_picture/apis/picture_api.dart';
import 'package:lq_picture/model/picture.dart';
import '../utils/index.dart';
import '../utils/keyboard_utils.dart';

class ImageEditPage extends StatefulWidget {
  final PictureVO? imageData;

  const ImageEditPage({
    super.key,
    this.imageData,
  });

  @override
  State<ImageEditPage> createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> with KeyboardDismissMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _introductionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _picColorController = TextEditingController();
  
  final _nameFocus = FocusNode();
  final _introductionFocus = FocusNode();
  final _categoryFocus = FocusNode();
  final _tagFocus = FocusNode();
  
  List<String> _tags = [];
  final _tagController = TextEditingController();
  
  // 模拟图片数据
  late PictureVO? _imageInfo;
  bool _isLoading = false;
  
  bool _isNameFocused = false;
  bool _isIntroductionFocused = false;
  bool _isCategoryFocused = false;
  bool _isTagFocused = false;
  
  @override
  void initState() {
    super.initState();
    _initImageData();
    
    // 监听焦点变化
    _nameFocus.addListener(() {
      setState(() {
        _isNameFocused = _nameFocus.hasFocus;
      });
    });
    _introductionFocus.addListener(() {
      setState(() {
        _isIntroductionFocused = _introductionFocus.hasFocus;
      });
    });
    _categoryFocus.addListener(() {
      setState(() {
        _isCategoryFocused = _categoryFocus.hasFocus;
      });
    });
    _tagFocus.addListener(() {
      setState(() {
        _isTagFocused = _tagFocus.hasFocus;
      });
    });
    
    // 监听输入内容变化，实时更新UI
    _nameController.addListener(() {
      setState(() {});
    });
    _introductionController.addListener(() {
      setState(() {});
    });
    _categoryController.addListener(() {
      setState(() {});
    });
    _tagController.addListener(() {
      setState(() {});
    });
  }
  
  void _initImageData() {
    // 模拟从服务器获取的完整图片信息
    _imageInfo = widget.imageData;
    
    // 初始化表单数据
    _nameController.text = _imageInfo?.name ?? '';
    _introductionController.text = _imageInfo?.introduction ?? '';
    _categoryController.text = _imageInfo?.category ?? '';
    _picColorController.text = _imageInfo?.picColor ?? '';
    _tags = List<String>.from(_imageInfo?.tags ?? []);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _introductionController.dispose();
    _categoryController.dispose();
    _picColorController.dispose();
    _tagController.dispose();
    _nameFocus.dispose();
    _introductionFocus.dispose();
    _categoryFocus.dispose();
    _tagFocus.dispose();
    super.dispose();
  }
  

  
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // 构建更新数据
    final updateData = {
      'id': _imageInfo?.id,
      'name': _nameController.text.trim(),
      'introduction': _introductionController.text.trim(),
      'category': _categoryController.text.trim(),
      'tags': _tags,
    };
    
    setState(() {
      _isLoading = false;
    });
    // 显示成功提示
    if (mounted) {
      final res = await PictureApi.editPicture(updateData);
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('图片信息更新成功'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // 返回上一页并传递更新后的数据
        Navigator.pop(context, updateData);
      } else {
        // 更新失败提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('图片信息更新失败，请重试'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return buildWithKeyboardDismiss(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[800],
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '编辑图片',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片预览卡片
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 图片
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          _imageInfo?.thumbnailUrl??_imageInfo!.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // 图片信息
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '图片信息',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // 只读信息
                          _buildInfoRow('文件大小', formatFileSize(  int.parse(_imageInfo!.picSize))),
                          _buildInfoRow('图片尺寸', '${_imageInfo?.picWidth} × ${_imageInfo?.picHeight}'),
                          _buildInfoRow('图片比例', '${_imageInfo?.picScale.toStringAsFixed(2)}'),
                          _buildInfoRow('图片格式', _imageInfo!.picFormat),
                          _buildInfoRow('创建时间', _formatDateTime(_imageInfo?.createTime.toString())),
                          _buildInfoRow('更新时间', _formatDateTime(_imageInfo?.updateTime.toString())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 编辑表单
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '编辑信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 图片名称
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        label: '图片名称',
                        hint: '请输入图片名称',
                        isFocused: _isNameFocused,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入图片名称';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 简介
                      _buildTextField(
                        controller: _introductionController,
                        focusNode: _introductionFocus,
                        label: '简介',
                        hint: '请输入图片简介',
                        isFocused: _isIntroductionFocused,
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 分类
                      _buildTextField(
                        controller: _categoryController,
                        focusNode: _categoryFocus,
                        label: '分类',
                        hint: '请输入图片分类',
                        isFocused: _isCategoryFocused,
                      ),
                      const SizedBox(height: 20),
                      // 标签
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '标签',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 添加标签输入框
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _tagController,
                                    focusNode: _tagFocus,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2C3E50),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: (_isTagFocused || _tagController.text.isNotEmpty) ? null : '输入标签后按回车添加',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 15,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    ),
                                    onSubmitted: (_) => _addTag(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4FC3F7).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _addTag,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    '添加',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // 标签列表
                          if (_tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => _removeTag(tag),
                                  backgroundColor: const Color(0xFF4FC3F7).withOpacity(0.1),
                                  deleteIconColor: const Color(0xFF4FC3F7),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF4FC3F7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  side: const BorderSide(color: Color(0xFF4FC3F7)),
                                );
                              }).toList(),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.label_outline, color: Colors.grey[400]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '暂无标签',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 保存按钮
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3F7).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '保存中...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          '保存更改',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool isFocused,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
            decoration: InputDecoration(
              hintText: (isFocused || controller.text.isNotEmpty) ? null : hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 16 : 18,
              ),
              errorStyle: const TextStyle(
                fontSize: 12,
                height: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '未知';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}