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
          
          // 图片列表
          Expanded(
            child: _filteredImages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredImages.length,
                    itemBuilder: (context, index) {
                      final image = _filteredImages[index];
                      return _buildImageReviewItem(image);
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

  // 图片审核项
  Widget _buildImageReviewItem(Map<String, dynamic> image) {
    // 根据状态设置颜色
    Color statusColor;
    IconData statusIcon;
    
    switch (image['status']) {
      case '待审核':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case '已通过':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case '已拒绝':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // 图片信息部分
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 缩略图
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                // 图片信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '上传时间: ${image['uploadTime']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 状态标签
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
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
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
          
          // 拒绝原因（如果有）
          if (image['status'] == '已拒绝' && image['reason'].isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '拒绝原因:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image['reason'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[800],
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