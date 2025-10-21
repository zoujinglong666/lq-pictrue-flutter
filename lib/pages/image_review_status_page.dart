import 'package:flutter/material.dart';
import 'package:lq_picture/apis/picture_api.dart';
import 'package:lq_picture/model/picture.dart';
import 'package:lq_picture/model/page.dart' as CustomPage;
import 'package:lq_picture/utils/ToastUtils.dart';

class ImageReviewStatusPage extends StatefulWidget {
  const ImageReviewStatusPage({super.key});

  @override
  State<ImageReviewStatusPage> createState() => _ImageReviewStatusPageState();
}

class _ImageReviewStatusPageState extends State<ImageReviewStatusPage> {
  // 当前选中的审核状态过滤器
  String _currentFilter = '全部';
  // 真实图片审核数据
  List<PictureItem> _reviewImages = [];
  bool _isLoading = false;
  bool _hasError = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;

  // 过滤器选项
  final List<String> _filterOptions = ['全部', '待审核', '已通过', '已拒绝'];

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  // 加载审核数据
  Future<void> _loadReviewData({int page = 1}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 构建查询参数
      Map<String, dynamic> queryParams = {
        'current': page,
        'pageSize': 20,
      };

      // 根据过滤器添加状态参数
      if (_currentFilter != '全部') {
        int status = 0;
        switch (_currentFilter) {
          case '待审核':
            status = 0;
            break;
          case '已通过':
            status = 1;
            break;
          case '已拒绝':
            status = 2;
            break;
        }
        queryParams['reviewStatus'] = status;
      }

      final CustomPage.Page<PictureItem> result = await PictureApi.getReviewStatusList(queryParams);
      
      setState(() {
        _reviewImages = result.records ?? [];
        _currentPage = int.tryParse(result.current.toString() ?? '1') ?? 1;
        _totalPages = int.tryParse(result.pages.toString() ?? '1') ?? 1;
        _totalRecords = int.tryParse(result.total.toString() ?? '0') ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ToastUtils.showError('加载审核数据失败: $e');
    }
  }

  // 刷新数据
  Future<void> _refreshData() async {
    await _loadReviewData(page: 1);
  }

  // 根据当前过滤器筛选图片
  List<PictureItem> get _filteredImages {
    return _reviewImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '审核状态',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // 过滤器选项
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final option = _filterOptions[index];
                  final isSelected = option == _currentFilter;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentFilter = option;
                      });
                      _loadReviewData(page: 1);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // 分割线
            Divider(height: 1, color: Colors.grey[200]),
            
            // 加载状态
            if (_isLoading && _reviewImages.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('加载中...'),
                    ],
                  ),
                ),
              ),
            
            // 错误状态
            if (_hasError && _reviewImages.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('加载失败'),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            
            // 图片网格
            if (!_isLoading && !_hasError || _reviewImages.isNotEmpty)
              Expanded(
                child: _filteredImages.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredImages.length,
                              itemBuilder: (context, index) {
                                final image = _filteredImages[index];
                                return _buildImageReviewGridItem(image);
                              },
                            ),
                          ),
                          // 分页信息
                          if (_totalPages > 1)
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 1
                                        ? () => _loadReviewData(page: _currentPage - 1)
                                        : null,
                                  ),
                                  Text('第 $_currentPage 页 / 共 $_totalPages 页'),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed: _currentPage < _totalPages
                                        ? () => _loadReviewData(page: _currentPage + 1)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  // 空状态提示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有${_currentFilter == '全部' ? '' : _currentFilter}图片',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentFilter == '全部' 
                ? '您还没有上传过图片' 
                : '没有$_currentFilter状态的图片',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // 获取状态颜色和图标
  Map<String, dynamic> _getStatusInfo(int? reviewStatus) {
    // 根据API返回的实际字段处理状态，如果没有reviewStatus字段，则显示默认状态
    if (reviewStatus == null) {
      return {
        'color': Colors.grey, 
        'icon': Icons.help_outline,
        'text': '未知'
      };
    }
    
    switch (reviewStatus) {
      case 0: // 待审核
        return {
          'color': Colors.orange, 
          'icon': Icons.hourglass_empty,
          'text': '待审核'
        };
      case 1: // 已通过
        return {
          'color': Colors.green, 
          'icon': Icons.check_circle_outline,
          'text': '已通过'
        };
      case 2: // 已拒绝
        return {
          'color': Colors.red, 
          'icon': Icons.cancel_outlined,
          'text': '已拒绝'
        };
      default:
        return {
          'color': Colors.grey, 
          'icon': Icons.help_outline,
          'text': '未知'
        };
    }
  }

  // 格式化时间戳
  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  // 网格布局的图片审核项
  Widget _buildImageReviewGridItem(PictureItem image) {
    final statusInfo = _getStatusInfo(image.reviewStatus);
    final statusColor = statusInfo['color'] as Color;
    final statusIcon = statusInfo['icon'] as IconData;
    final statusText = statusInfo['text'] as String;
    
    return GestureDetector(
      onTap: () {
        // 点击查看详情
        if (image.reviewStatus == 2 && image.reviewMessage != null && image.reviewMessage.toString().isNotEmpty) {
          _showRejectReasonDialog(image);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片缩略图
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 图片容器
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      color: Colors.grey[200],
                      child: image.thumbnailUrl != null && image.thumbnailUrl!.isNotEmpty
                          ? Image.network(
                              image.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                );
                              },
                            )
                          : Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 40,
                            ),
                    ),
                  ),
                  // 状态标签
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 拒绝提示
                  if (image.reviewStatus == 2)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.red.withOpacity(0.7),
                        child: const Center(
                          child: Text(
                            '点击查看原因',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 图片信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.name ?? '未命名图片',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '上传: ${_formatTime(image.createTime.millisecondsSinceEpoch)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示拒绝原因对话框
  void _showRejectReasonDialog(PictureItem image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '审核未通过',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '图片名称: ${image.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '上传时间: ${_formatTime(image.createTime.millisecondsSinceEpoch)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '拒绝原因:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                image.reviewMessage?.toString() ?? '无具体原因',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[800],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}