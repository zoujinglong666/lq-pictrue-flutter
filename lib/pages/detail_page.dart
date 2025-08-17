import 'package:flutter/material.dart';
import 'image_preview_page.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic>? imageData;
  
  const DetailPage({super.key, this.imageData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isFavorite = false;
  bool _isDownloading = false;
  
  // 模拟图片详情数据
  late Map<String, dynamic> _imageDetails;
  
  @override
  void initState() {
    super.initState();
    _imageDetails =  {
      'id': 1,
      'title': '高质量摄影作品',
      'url': 'https://picsum.photos/800/1200',
      'author': '摄影师小明',
      'views': '1.2k',
      'downloads': '356',
      'likes': '89',
      'tags': ['风景', '自然', '山水'],
      'description': '这是一张高质量的摄影作品，拍摄于2023年夏天。使用了专业设备，完美捕捉了自然光线和景色。',
      'camera': 'Canon EOS R5',
      'lens': 'RF 24-70mm f/2.8L IS USM',
      'iso': '100',
      'aperture': 'f/8',
      'shutterSpeed': '1/125s',
      'date': '2023-07-15',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 图片和顶部操作栏
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'image_${_imageDetails['id']}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewPage(
                              imageUrl: _imageDetails['url'],
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        _imageDetails['url'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF4FC3F7),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 渐变遮罩
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {
                  // 分享功能
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // 图片信息
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和作者
                  Text(
                    _imageDetails['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _imageDetails['author'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // 关注作者
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4FC3F7),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFF4FC3F7)),
                          ),
                        ),
                        child: const Text('关注'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 统计信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.visibility, _imageDetails['views'], '浏览'),
                      _buildStatItem(Icons.file_download, _imageDetails['downloads'], '下载'),
                      _buildStatItem(Icons.favorite, _imageDetails['likes'], '喜欢'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // 标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_imageDetails['tags'] as List<String>).map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 描述
                  const Text(
                    '描述',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _imageDetails['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // 拍摄信息
                  const Text(
                    '拍摄信息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('相机', _imageDetails['camera']),
                  _buildInfoRow('镜头', _imageDetails['lens']),
                  _buildInfoRow('ISO', _imageDetails['iso']),
                  _buildInfoRow('光圈', _imageDetails['aperture']),
                  _buildInfoRow('快门速度', _imageDetails['shutterSpeed']),
                  _buildInfoRow('拍摄日期', _imageDetails['date']),
                  
                  const SizedBox(height: 80), // 为底部按钮留出空间
                ],
              ),
            ),
          ),
        ],
      ),
      // 底部下载按钮
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isDownloading = true;
            });
            
            // 模拟下载
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _isDownloading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('下载完成')),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FC3F7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
          child: _isDownloading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  '下载图片',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}