import 'package:flutter/material.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/common/toast.dart';
import '../utils/keyboard_utils.dart';

class CreateSpacePage extends StatefulWidget {
  const CreateSpacePage({super.key});

  @override
  State<CreateSpacePage> createState() => _CreateSpacePageState();
}

class _CreateSpacePageState extends State<CreateSpacePage>
    with KeyboardDismissMixin {
  final _formKey = GlobalKey<FormState>();
  final _spaceNameController = TextEditingController();
  int _selectedSpaceLevel = 0; // 默认选择普通版
  bool _isLoading = false;
  final List<Map<String, dynamic>> _spaceLevels = [
    {
      'level': 0,
      'name': '普通版',
      'description': '基础功能，适合个人使用',
      'features': ['100MB 存储空间', '基础图片管理', '标准上传速度'],
      'price': '免费',
      'color': Colors.blue,
      'icon': Icons.photo_library_outlined,
    },
    {
      'level': 1,
      'name': '专业版',
      'description': '增强功能，适合专业用户',
      'features': ['100GB 存储空间', '高级图片编辑', '快速上传', '批量处理'],
      'price': '¥29/月',
      'color': Colors.purple,
      'icon': Icons.photo_camera_outlined,
    },
    {
      'level': 2,
      'name': '旗舰版',
      'description': '全功能版本，适合团队协作',
      'features': ['1TB 存储空间', '团队协作', 'AI 智能标签', '优先技术支持'],
      'price': '¥99/月',
      'color': Colors.orange,
      'icon': Icons.workspace_premium_outlined,
    },
  ];

  @override
  void dispose() {
    _spaceNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateSpace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final res = await SpaceApi.addSpace({
      "spaceName": _spaceNameController.text,
      "spaceLevel": _selectedSpaceLevel,
    });
    print("$res");

    setState(() {
      _isLoading = false;
    });

    // 创建成功
    if (mounted) {


      MyToast.showSuccess('空间 "${_spaceNameController.text}" 创建成功！');



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('空间 "${_spaceNameController.text}" 创建成功！'),
          backgroundColor: Colors.green,
        ),
      );
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '创建图片空间',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 页面说明
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '创建专属图片空间',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '为您的图片创建一个专属空间，享受更好的管理和存储体验',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                // 空间名称输入
                Text(
                  '空间名称',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _spaceNameController,
                    decoration: InputDecoration(
                      hintText: '请输入空间名称',
                      prefixIcon: Icon(
                        Icons.folder_outlined,
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入空间名称';
                      }
                      if (value.length < 2) {
                        return '空间名称至少2个字符';
                      }
                      if (value.length > 20) {
                        return '空间名称不能超过20个字符';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 32),
                // 空间级别选择
                Text(
                  '选择空间级别',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                // 空间级别卡片
                ...List.generate(_spaceLevels.length, (index) {
                  final spaceLevel = _spaceLevels[index];
                  final isSelected = _selectedSpaceLevel == spaceLevel['level'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSpaceLevel = spaceLevel['level'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? spaceLevel['color']
                                    : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? spaceLevel['color'].withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                              blurRadius: isSelected ? 15 : 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: spaceLevel['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    spaceLevel['icon'],
                                    color: spaceLevel['color'],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            spaceLevel['name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            spaceLevel['price'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: spaceLevel['color'],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        spaceLevel['description'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? spaceLevel['color']
                                              : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color:
                                        isSelected
                                            ? spaceLevel['color']
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                          : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  (spaceLevel['features'] as List<String>)
                                      .map(
                                        (feature) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: spaceLevel['color']
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            feature,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: spaceLevel['color'],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // 创建按钮
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateSpace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              '创建空间',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),

                // 说明文字
                Text(
                  '创建后可以随时在设置中升级或降级空间级别',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
