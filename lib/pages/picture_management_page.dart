import 'package:flutter/material.dart' hide Page;
import 'package:lq_picture/common/toast.dart';
import '../apis/picture_api.dart';
import '../utils/keyboard_utils.dart';
import '../widgets/pagination_widget.dart';
import '../model/page.dart';

class PictureManagementPage extends StatefulWidget {
  const PictureManagementPage({super.key});

  @override
  State<PictureManagementPage> createState() => _PictureManagementPageState();
}

class _PictureManagementPageState extends State<PictureManagementPage> with KeyboardDismissMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '全部';
  String _selectedCategory = '全部';
  List<PictureItem> _pictures = [];
  List<PictureItem> _filteredPictures = [];
  bool _isLoading = false;
  
  // 分页相关
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 1;
  int _totalRecords = 0;
  Page<PictureItem>? _pageData;

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _loadPictures({int? page}) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requestData = {
        'current': page ?? _currentPage,
        'pageSize': _pageSize,
      } as Map<String, dynamic>;
      
      // 添加搜索条件
      if (_searchController.text.isNotEmpty) {
        requestData['searchText'] = _searchController.text;
      }
      
      // 添加状态筛选
      if (_selectedStatus != '全部') {
        int statusValue = 0;
        switch (_selectedStatus) {
          case '待审核':
            statusValue = 0;
            break;
          case '已通过':
            statusValue = 1;
            break;
          case '已拒绝':
            statusValue = 2;
            break;
        }
        requestData['reviewStatus'] = statusValue;
      }
      
      // 添加分类筛选
      if (_selectedCategory != '全部') {
        requestData['category'] = _selectedCategory;
      }
      
      final res = await PictureApi.getAllList(requestData);
      
      setState(() {
        _pageData = res;
        _pictures = res.records;
        _filteredPictures = List.from(_pictures);
        _currentPage = _toInt(res.current);
        _totalPages = _toInt(res.pages);
        _totalRecords = _toInt(res.total);
      });
    } catch (e) {
      print('加载图片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPictures() {
    // 重新加载第一页数据
    _currentPage = 1;
    _loadPictures(page: 1);
  }
  
  void _onPageChanged(int page) {
    _loadPictures(page: page);
  }

  Future<void> _reviewPicture(PictureItem picture, int status, [String? message]) async {
    final res = await PictureApi.reviewPicture({
      'id': picture.id,
      'reviewStatus':status,
    });
    if(res){
      MyToast.showSuccess(status == 1 ? '图片审核通过' : '图片审核拒绝');
    }
    _filterPictures();
  }

  void _showRejectDialog(PictureItem picture) {
    final TextEditingController messageController = TextEditingController();
    
    // 预设拒绝原因列表
    final List<String> presetReasons = [
      '图片质量过低，请上传更清晰的图片',
      '图片包含不适当内容',
      '图片包含商业广告内容',
      '图片侵犯版权或知识产权',
      '图片格式不符合要求'
    ];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // 拖拽指示器
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 12,
                      bottom: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                // 标题栏
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.block,
                        color: Colors.red[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        '拒绝审核',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 图片信息
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          picture.thumbnailUrl ?? picture.url,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              picture.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // 预设拒绝原因
                const Text(
                  '常用拒绝原因',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: presetReasons.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          messageController.text = presetReasons[index];
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            presetReasons[index].length > 10 
                                ? '${presetReasons[index].substring(0, 10)}...' 
                                : presetReasons[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // 拒绝原因输入框
                const Text(
                  '拒绝原因',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: '请详细说明拒绝的原因...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 4,
                    minLines: 3,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (messageController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text('请填写拒绝原因'),
                                  ],
                                ),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          _reviewPicture(picture, 2, messageController.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '确认拒绝',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }

  /// 将不同类型的数据转换为标签列表
  List<String> _convertToTagList(dynamic tags) {
    if (tags == null) {
      return [];
    }

    if (tags is List<String>) {
      // 已经是正确的类型
      return tags;
    }

    if (tags is List) {
      // 是列表但元素不是字符串，转换为字符串
      return tags.map((tag) => tag.toString()).toList();
    }

    if (tags is String) {
      // 是字符串，尝试按逗号分割
      if (tags.isEmpty) {
        return [];
      }
      return tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
    }

    // 其他情况，转换为字符串再处理
    final tagString = tags.toString();
    if (tagString.isEmpty) {
      return [];
    }
    return tagString.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  void _showPictureDetail(PictureItem picture) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '图片详情',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 图片预览
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              picture.url,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey[100],
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 基本信息
                      _buildDetailSection('基本信息', [
                        _buildDetailItem(Icons.image_outlined, '图片名称', picture.name),
                        _buildDetailItem(Icons.category_outlined, '分类', picture.category ?? '未分类'),
                        _buildDetailItem(Icons.tag_outlined, '标签', (_convertToTagList(picture.tags)?? []).join(', ')),
                      ]),
                      const SizedBox(height: 20),
                      // 文件信息
                      _buildDetailSection('文件信息', [
                        _buildDetailItem(Icons.photo_size_select_actual_outlined, '图片尺寸', '${picture.picWidth} × ${picture.picHeight}'),
                        _buildDetailItem(Icons.storage_outlined, '文件大小', _formatFileSize( int.parse(picture.picSize))),
                        _buildDetailItem(Icons.access_time, '上传时间', _formatDateTime(picture.createTime)),
                      ]),
                      const SizedBox(height: 20),
                      // 审核信息
                      _buildDetailSection('审核信息', [
                        _buildDetailItem(
                          _getStatusIcon(picture.reviewStatus),
                          '审核状态',
                          _getStatusText(picture.reviewStatus),
                          statusColor: _getStatusColor(picture.reviewStatus),
                        ),
                        if (picture.reviewMessage?.isNotEmpty ?? false)
                          _buildDetailItem(Icons.message_outlined, '审核信息', picture.reviewMessage),
                        if (picture.reviewTime != null)
                          _buildDetailItem(Icons.schedule, '审核时间', _formatDateTime(picture.reviewTime!)),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: statusColor ?? Colors.grey[600],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: statusColor ?? Colors.grey[800],
                fontWeight: statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.pending_outlined;
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }


  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return '待审核';
      case 1:
        return '已通过';
      case 2:
        return '已拒绝';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
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
          '图片管理',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '管理员',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和筛选区域
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
                const Text(
                  '搜索与筛选',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // 搜索框
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索图片名称、用户名或分类...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search_outlined, color: Colors.grey[600], size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterPictures();
                              },
                              icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      // 延迟执行搜索，避免频繁请求
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          _filterPictures();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // 筛选器
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            hint: const Text('审核状态'),
                            items: ['全部', '待审核', '已通过', '已拒绝']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                              _filterPictures();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            hint: const Text('分类'),
                            items: ['全部', '风景', '城市', '人物', '动物', '其他']
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                              _filterPictures();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 图片列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPictures.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无图片数据',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '请尝试调整搜索条件',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // 分页信息
                          if (_totalRecords > 0)
                            PaginationInfo(
                              currentPage: _currentPage,
                              pageSize: _pageSize,
                              totalRecords: _totalRecords,
                              totalPages: _totalPages,
                            ),
                          // 图片列表
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: _filteredPictures.length,
                              itemBuilder: (context, index) {
                                final picture = _filteredPictures[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 缩略图
                                        GestureDetector(
                                          onTap: () => _showPictureDetail(picture),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.grey[100],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                picture.thumbnailUrl ?? picture.url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // 图片信息
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                picture.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF00BCD4).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      picture.category ?? '未分类',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF00BCD4),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.photo_size_select_actual_outlined, size: 14, color: Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${picture.picWidth}×${picture.picHeight}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(Icons.storage_outlined, size: 14, color: Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatFileSize(int.parse(picture.picSize)),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(picture.reviewStatus).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      _getStatusText(picture.reviewStatus),
                                                      style: TextStyle(
                                                        color: _getStatusColor(picture.reviewStatus),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    _formatDateTime(picture.createTime),
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (picture.reviewMessage?.isNotEmpty ?? false) ...[
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.info_outline, size: 14, color: Colors.red[600]),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          picture.reviewMessage!,
                                                          style: TextStyle(
                                                            color: Colors.red[600],
                                                            fontSize: 12,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // 操作按钮
                                        if (picture.reviewStatus == 0) ...[
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 48,
                                                height: 24,
                                                child: ElevatedButton(
                                                  onPressed: () => _reviewPicture(picture, 1),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green[600],
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text('通过', style: TextStyle(fontSize: 12)),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                width: 48,
                                                height: 24,
                                                child: ElevatedButton(
                                                  onPressed: () => _showRejectDialog(picture),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red[600],
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text('拒绝', style: TextStyle(fontSize: 12)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          SizedBox(
                                            width: 48,
                                            height: 24,
                                            child: OutlinedButton(
                                              onPressed: () => _showPictureDetail(picture),
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                side: BorderSide(color: Colors.grey[300]!),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                '详情',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // 分页组件
                          if (_totalPages > 1)
                            Container(
                              margin: const EdgeInsets.all(16),
                              child: PaginationWidget(
                                currentPage: _currentPage,
                                totalPages: _totalPages,
                                onPageChanged: _onPageChanged,
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
