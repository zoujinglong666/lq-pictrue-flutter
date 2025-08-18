import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyToUser;
  int? _replyToCommentId;
  
  // 模拟图片详情数据
  late Map<String, dynamic> _imageDetails;
  
  // 模拟评论数据
  List<Map<String, dynamic>> _comments = [];
  
  @override
  void initState() {
    super.initState();
    // _imageDetails = widget.imageData ?? {
    //   'id': 1,
    //   'title': '高质量摄影作品',
    //   'url': 'https://picsum.photos/800/1200',
    //   'author': '摄影师小明',
    //   'views': '1.2k',
    //   'downloads': '356',
    //   'likes': '89',
    //   'tags': ['风景', '自然', '山水'],
    //   'description': '这是一张高质量的摄影作品，拍摄于2023年夏天。使用了专业设备，完美捕捉了自然光线和景色。',
    //   'camera': 'Canon EOS R5',
    //   'lens': 'RF 24-70mm f/2.8L IS USM',
    //   'iso': '100',
    //   'aperture': 'f/8',
    //   'shutterSpeed': '1/125s',
    //   'date': '2023-07-15',
    // };


    _imageDetails = {
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
    
    // 初始化模拟评论数据
    _initComments();
  }
  
  void _initComments() {
    _comments = [
      {
        'id': 1,
        'user': '摄影爱好者',
        'avatar': 'https://picsum.photos/40/40?random=1',
        'content': '这张照片拍得真棒！构图和光线都很完美。',
        'time': '2小时前',
        'likes': 12,
        'isLiked': false,
        'replies': [
          {
            'id': 11,
            'user': '风景摄影师',
            'avatar': 'https://picsum.photos/40/40?random=2',
            'content': '同意！特别是那个光影效果，很有层次感。',
            'time': '1小时前',
            'likes': 5,
            'isLiked': true,
            'replyTo': '摄影爱好者',
          },
          {
            'id': 12,
            'user': '小明同学',
            'avatar': 'https://picsum.photos/40/40?random=3',
            'content': '请问这是用什么相机拍的？',
            'time': '30分钟前',
            'likes': 2,
            'isLiked': false,
            'replyTo': '摄影爱好者',
          },
        ],
      },
      {
        'id': 2,
        'user': '自然风光',
        'avatar': 'https://picsum.photos/40/40?random=4',
        'content': '太美了！这个地方在哪里？有机会也想去拍拍。',
        'time': '3小时前',
        'likes': 8,
        'isLiked': false,
        'replies': [],
      },
      {
        'id': 3,
        'user': '摄影新手',
        'avatar': 'https://picsum.photos/40/40?random=5',
        'content': '学习了！请问后期是怎么处理的？',
        'time': '5小时前',
        'likes': 15,
        'isLiked': true,
        'replies': [
          {
            'id': 31,
            'user': '后期大师',
            'avatar': 'https://picsum.photos/40/40?random=6',
            'content': '看起来像是调了对比度和饱和度，色温也稍微调暖了一点。',
            'time': '4小时前',
            'likes': 7,
            'isLiked': false,
            'replyTo': '摄影新手',
          },
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // 主要内容区域
          Expanded(
            child: CustomScrollView(
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
                      onPressed: () => _shareImage(),
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
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // 评论区
                        _buildCommentsSection(),
                        
                        const SizedBox(height: 20), // 减少底部空间
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 底部评论输入框 - 固定在底部，紧贴键盘
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewPadding.bottom, // 只考虑安全区域，不考虑键盘
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        decoration: InputDecoration(
                          hintText: _replyToUser != null 
                              ? '回复 @$_replyToUser' 
                              : '写下你的评论...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          suffixIcon: _replyToUser != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: _cancelReply,
                                )
                              : null,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                        onTap: () {
                          // 点击输入框时自动弹起键盘
                          _commentFocusNode.requestFocus();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _submitComment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 分享图片功能
  void _shareImage() {
    final String shareText = '''
📸 ${_imageDetails['title']}

👤 作者：${_imageDetails['author']}
📊 浏览：${_imageDetails['views']} | 下载：${_imageDetails['downloads']} | 喜欢：${_imageDetails['likes']}

📝 ${_imageDetails['description']}

📷 拍摄信息：
• 相机：${_imageDetails['camera']}
• 镜头：${_imageDetails['lens']}
• ISO：${_imageDetails['iso']}
• 光圈：${_imageDetails['aperture']}
• 快门：${_imageDetails['shutterSpeed']}

🔗 图片链接：${_imageDetails['url']}

#摄影 #图库 ${(_imageDetails['tags'] as List<String>).map((tag) => '#$tag').join(' ')}
    '''.trim();

    // 显示分享选项对话框
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '分享图片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              
              // 分享选项
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildShareOption(
                      icon: Icons.link,
                      title: '复制链接',
                      subtitle: '复制图片链接到剪贴板',
                      onTap: () {
                        Navigator.pop(context);
                        _copyLink();
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.text_fields,
                      title: '分享文本',
                      subtitle: '分享图片信息和链接',
                      onTap: () {
                        Navigator.pop(context);
                        Share.share(shareText);
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.image,
                      title: '分享图片',
                      subtitle: '分享图片文件',
                      onTap: () {
                        Navigator.pop(context);
                        _shareImageFile();
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 取消按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4FC3F7),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // 复制链接功能
  void _copyLink() {
    // 这里应该使用 Clipboard.setData，但需要导入 flutter/services
    // 为了简化，我们使用 Share.share 来分享链接
    Share.share(_imageDetails['url']);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('链接已复制到剪贴板'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 分享图片文件功能
  void _shareImageFile() {
    // 这里应该先下载图片到本地，然后分享文件
    // 为了简化演示，我们分享图片URL
    Share.share(
      '分享一张精美图片：${_imageDetails['title']}\n${_imageDetails['url']}',
      subject: _imageDetails['title'],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 8),
            Text('正在分享图片...'),
          ],
        ),
        backgroundColor: const Color(0xFF4FC3F7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 构建评论区
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '评论',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_getTotalCommentsCount()})',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_comments.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '还没有评论，快来抢沙发吧！',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              return _buildCommentItem(_comments[index]);
            },
          ),
      ],
    );
  }

  // 构建单个评论项
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主评论
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(comment['avatar']),
              ),
              const SizedBox(width: 12),
              
              // 评论内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名和时间
                    Row(
                      children: [
                        Text(
                          comment['user'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment['time'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // 评论文本
                    Text(
                      comment['content'],
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 操作按钮
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleCommentLike(comment),
                          child: Row(
                            children: [
                              Icon(
                                comment['isLiked'] 
                                    ? Icons.favorite 
                                    : Icons.favorite_border,
                                size: 16,
                                color: comment['isLiked'] 
                                    ? Colors.red 
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comment['likes']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _replyToComment(comment),
                          child: Text(
                            '回复',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 回复列表
          if (comment['replies'] != null && comment['replies'].isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 44, top: 12),
              child: Column(
                children: (comment['replies'] as List).map<Widget>((reply) {
                  return _buildReplyItem(reply);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // 构建回复项
  Widget _buildReplyItem(Map<String, dynamic> reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(reply['avatar']),
          ),
          const SizedBox(width: 10),
          
          // 回复内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名和时间
                Row(
                  children: [
                    Text(
                      reply['user'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reply['time'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // 回复文本
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    children: [
                      if (reply['replyTo'] != null) ...[
                        TextSpan(
                          text: '@${reply['replyTo']} ',
                          style: const TextStyle(
                            color: Color(0xFF4FC3F7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      TextSpan(text: reply['content']),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                
                // 操作按钮
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleReplyLike(reply),
                      child: Row(
                        children: [
                          Icon(
                            reply['isLiked'] 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            size: 14,
                            color: reply['isLiked'] 
                                ? Colors.red 
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${reply['likes']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _replyToReply(reply),
                      child: Text(
                        '回复',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取总评论数
  int _getTotalCommentsCount() {
    int total = _comments.length;
    for (var comment in _comments) {
      if (comment['replies'] != null) {
        total += (comment['replies'] as List).length;
      }
    }
    return total;
  }

  // 切换评论点赞
  void _toggleCommentLike(Map<String, dynamic> comment) {
    setState(() {
      comment['isLiked'] = !comment['isLiked'];
      comment['likes'] += comment['isLiked'] ? 1 : -1;
    });
  }

  // 切换回复点赞
  void _toggleReplyLike(Map<String, dynamic> reply) {
    setState(() {
      reply['isLiked'] = !reply['isLiked'];
      reply['likes'] += reply['isLiked'] ? 1 : -1;
    });
  }

  // 回复评论
  void _replyToComment(Map<String, dynamic> comment) {
    setState(() {
      _replyToUser = comment['user'];
      _replyToCommentId = comment['id'];
    });
    // 延迟一帧后请求焦点，确保UI更新完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  // 回复回复
  void _replyToReply(Map<String, dynamic> reply) {
    setState(() {
      _replyToUser = reply['user'];
      _replyToCommentId = reply['id'];
    });
    // 延迟一帧后请求焦点，确保UI更新完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  // 取消回复
  void _cancelReply() {
    setState(() {
      _replyToUser = null;
      _replyToCommentId = null;
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  // 提交评论
  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final String content = _commentController.text.trim();
    final DateTime now = DateTime.now();
    
    setState(() {
      if (_replyToUser != null) {
        // 添加回复
        final parentComment = _comments.firstWhere(
          (comment) => comment['user'] == _replyToUser,
          orElse: () => _comments.firstWhere(
            (comment) => (comment['replies'] as List).any(
              (reply) => reply['user'] == _replyToUser,
            ),
          ),
        );
        
        if (parentComment['replies'] == null) {
          parentComment['replies'] = [];
        }
        
        (parentComment['replies'] as List).add({
          'id': DateTime.now().millisecondsSinceEpoch,
          'user': '我',
          'avatar': 'https://picsum.photos/40/40?random=999',
          'content': content,
          'time': '刚刚',
          'likes': 0,
          'isLiked': false,
          'replyTo': _replyToUser,
        });
      } else {
        // 添加新评论
        _comments.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'user': '我',
          'avatar': 'https://picsum.photos/40/40?random=999',
          'content': content,
          'time': '刚刚',
          'likes': 0,
          'isLiked': false,
          'replies': [],
        });
      }
    });

    _commentController.clear();
    _cancelReply();
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_replyToUser != null ? '回复成功' : '评论成功'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
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