import 'package:flutter/material.dart';

class ImageReviewStatusPage extends StatefulWidget {
  const ImageReviewStatusPage({super.key});

  @override
  State<ImageReviewStatusPage> createState() => _ImageReviewStatusPageState();
}

class _ImageReviewStatusPageState extends State<ImageReviewStatusPage> {
  // 当前选中的审核状态过滤器
  String _currentFilter = '全部';
  
  // 模拟图片审核数据
  final List<Map<String, dynamic>> _reviewImages = [
    {
      'id': 1,
      'name': '风景照片_001.jpg',
      'uploadTime': '2024-08-15 14:30',
      'status': '待审核', // 待审核、已通过、已拒绝
      'thumbnail': 'https://example.com/thumb1.jpg',
      'reason': '',
    },
    {
      'id': 2,
      'name': '家庭合影_002.jpg',
      'uploadTime': '2024-08-14 09:15',
      'status': '已通过',
      'thumbnail': 'https://example.com/thumb2.jpg',
      'reason': '',
    },
    {
      'id': 3,
      'name': '产品展示_003.jpg',
      'uploadTime': '2024-08-13 16:45',
      'status': '已拒绝',
      'thumbnail': 'https://example.com/thumb3.jpg',
      'reason': '图片包含商业广告内容，违反社区规定',
    },
    {
      'id': 4,
      'name': '旅行照片_004.jpg',
      'uploadTime': '2024-08-12 11:20',
      'status': '已通过',
      'thumbnail': 'https://example.com/thumb4.jpg',
      'reason': '',
    },
    {
      'id': 5,
      'name': '宠物照片_005.jpg',
      'uploadTime': '2024-08-11 15:50',
      'status': '待审核',
      'thumbnail': 'https://example.com/thumb5.jpg',
      'reason': '',
    },
    {
      'id': 6,
      'name': '聚会照片_006.jpg',
      'uploadTime': '2024-08-10 20:30',
      'status': '已拒绝',
      'thumbnail': 'https://example.com/thumb6.jpg',
      'reason': '图片质量过低，请上传清晰图片',
    },
  ];

  // 过滤器选项
  final List<String> _filterOptions = ['全部', '待审核', '已通过', '已拒绝'];

  // 根据当前过滤器筛选图片
  List<Map<String, dynamic>> get _filteredImages {
    if (_currentFilter == '全部') {
      return _reviewImages;
    } else {
      return _reviewImages.where((image) => image['status'] == _currentFilter).toList();
    }
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
      body: Column(
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
          
          // 图片网格
          Expanded(
            child: _filteredImages.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
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
        ],
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
                : '没有${_currentFilter}状态的图片',
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
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case '待审核':
        return {'color': Colors.orange, 'icon': Icons.hourglass_empty};
      case '已通过':
        return {'color': Colors.green, 'icon': Icons.check_circle_outline};
      case '已拒绝':
        return {'color': Colors.red, 'icon': Icons.cancel_outlined};
      default:
        return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }

  // 网格布局的图片审核项
  Widget _buildImageReviewGridItem(Map<String, dynamic> image) {
    final statusInfo = _getStatusInfo(image['status']);
    final statusColor = statusInfo['color'] as Color;
    final statusIcon = statusInfo['icon'] as IconData;
    
    return GestureDetector(
      onTap: () {
        // 点击查看详情
        if (image['status'] == '已拒绝' && image['reason'].isNotEmpty) {
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
                      child: const Icon(
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
                            image['status'],
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
                  if (image['status'] == '已拒绝')
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
                    image['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '上传: ${image['uploadTime'].split(' ')[0]}',
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
  void _showRejectReasonDialog(Map<String, dynamic> image) {
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
              '图片名称: ${image['name']}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '上传时间: ${image['uploadTime']}',
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
                image['reason'],
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