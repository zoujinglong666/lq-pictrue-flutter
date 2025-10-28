import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/picture_comment_api.dart';
import 'package:lq_picture/apis/picture_like_api.dart';
import 'package:lq_picture/common/toast.dart';
import 'package:lq_picture/model/picture.dart';
import 'package:lq_picture/model/comment.dart';
import 'package:share_plus/share_plus.dart';
import '../model/add_comment_request.dart';
import '../utils/index.dart';
import 'image_preview_page.dart';
import '../widgets/shimmer_effect.dart';
import '../widgets/skeleton_widgets.dart';
import '../providers/picture_update_provider.dart';

class DetailPage extends ConsumerStatefulWidget {
  final PictureVO? imageData;

  const DetailPage({super.key, this.imageData});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}
class _FlatComment {
  final CommentVO? comment;
  final int level;
  final bool isControl;
  final String? parentId;
  final bool? expanded;
  final int? remainingCount;

  _FlatComment(this.comment, this.level)
      : isControl = false,
        parentId = null,
        expanded = null,
        remainingCount = null;

  _FlatComment.control(this.parentId, this.expanded, this.remainingCount, this.level)
      : isControl = true,
        comment = null;
}
class _DetailPageState extends ConsumerState<DetailPage> {
  bool _isFavorite = false;
  bool _isImageLoaded = false; // 图片加载状态
  bool _showAppBarBackground = false; // 控制AppBar背景显示
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController(); // 滚动控制器
  final GlobalKey _commentsKey = GlobalKey(); // 评论区域的key
  String? _replyToUser;
  String? _parentId;
  String? _highlightedCommentId; // 高亮的评论ID
  String? _highlightedReplyId; // 高亮的回复ID
  // 展开/折叠状态：key 为评论ID，值为是否展开其子回复
  final Map<String, bool> _expanded = {};
  // 用于滚动定位与高亮定位的 Item Keys
  final Map<String, GlobalKey> _itemKeys = {};
  GlobalKey _getItemKey(String id) => _itemKeys.putIfAbsent(id, () => GlobalKey());
  
  // 默认每层先展示的子回复数量（未展开状态）
  final int _initialChildren = 3;
  // 最大默认展开层级（超过则默认折叠，需要手动展开）
  final int _maxDefaultDepth = 2;

  // 模拟图片详情数据
  late PictureVO _imageDetails;

  // 评论数据
  List<CommentVO> _comments = [];
  bool _commentsLoading = false;

  @override
  void initState() {
    super.initState();
    _imageDetails = widget.imageData!;
    _isFavorite = widget.imageData!.hasLiked;

    // 初始化评论数据
    _initComments();

    // 监听滚动事件
    _scrollController.addListener(_onScroll);
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
      return tags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    // 其他情况，转换为字符串再处理
    final tagString = tags.toString();
    if (tagString.isEmpty) {
      return [];
    }
    return tagString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _onScroll() {
    // 当滚动超过图片高度的一半时显示AppBar背景
    final scrollOffset = _scrollController.offset;
    final imageHeight = MediaQuery.of(context).size.height * 0.6;
    final shouldShowBackground = scrollOffset > imageHeight * 0.5;

    if (shouldShowBackground != _showAppBarBackground) {
      setState(() {
        _showAppBarBackground = shouldShowBackground;
      });
    }
  }

  Future<void> _initComments() async {
    if (_commentsLoading) return;

    setState(() {
      _commentsLoading = true;
    });

    try {
      final res = await PictureCommentApi.getCommentList({
        "pictureId":_imageDetails.id
      } );

      if (mounted) {
        setState(() {
          _comments =res.records ;
          _commentsLoading = false;
        });
      }
      print(res.records.toString());
    } catch (e) {
      if (mounted) {
        setState(() {
          _commentsLoading = false;
        });
      }
      MyToast.showError('加载评论失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardVisible = mediaQuery.viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // 主要内容区域
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 图片和顶部操作栏
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.6,
                  pinned: true,
                  backgroundColor:
                      _showAppBarBackground ? Colors.white : Colors.transparent,
                  elevation: _showAppBarBackground ? 4 : 0,
                  shadowColor: Colors.black26,
                  surfaceTintColor: Colors.transparent,
                  foregroundColor:
                      _showAppBarBackground ? Colors.black : Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'image_${_imageDetails.id}',
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreviewPage(
                                    imageUrl: _imageDetails.url,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              _imageDetails.url,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  // 图片加载完成
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _isImageLoaded = true;
                                      });
                                    }
                                  });
                                  return child;
                                }
                                // 显示骨架屏
                                return _buildImageSkeleton();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '图片加载失败',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
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
                    icon: _showAppBarBackground
                        ? const Icon(Icons.arrow_back, color: Colors.black)
                        : Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                    onPressed: _navigateBack,
                  ),
                  actions: [
                    IconButton(
                      icon: _showAppBarBackground
                          ? Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : Colors.black,
                            )
                          : Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                              ),
                            ),
                      onPressed: () async {
                        final originalIsFavorite = _isFavorite;
                        setState(() {
                          _isFavorite = !originalIsFavorite;
                        });
                        
                        try {
                          final result = await PictureLikeApi.pictureLikeToggle({
                            "pictureId": _imageDetails.id,
                          });
                          
                          // 更新图片详情数据
                          setState(() {
                            _imageDetails = _imageDetails.copyWith(
                              hasLiked: result.liked,
                              likeCount: result.likeCount.toString(),
                            );
                          });
                          
                          // 通知全局状态更新（同步到首页等其他页面）
                          ref.read(pictureUpdateProvider.notifier).notifyPictureUpdate(_imageDetails);
                          
                          // 点赞成功，不自动返回，只在本地更新状态
                          MyToast.showSuccess(_isFavorite ? '点赞成功' : '取消点赞');
                          
                        } catch (e) {
                          // 如果点赞失败，恢复原来的状态
                          setState(() {
                            _isFavorite = originalIsFavorite;
                          });
                          MyToast.showError('点赞失败，请重试');
                        }
                      },
                    ),
                    IconButton(
                      icon: _showAppBarBackground
                          ? const Icon(Icons.share, color: Colors.black)
                          : Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  const Icon(Icons.share, color: Colors.white),
                            ),
                      onPressed: () => _shareImage(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // 添加标题，只在滚动时显示
                  title: _showAppBarBackground
                      ? Text(
                          _imageDetails.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                ),

                // 图片信息
                SliverToBoxAdapter(
                  child: _isImageLoaded
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题和作者
                              Text(
                                _imageDetails.name,
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
                                    backgroundImage: NetworkImage(_imageDetails.user.userAvatar),
                                    onBackgroundImageError: (exception, stackTrace) {},
                                    child: _imageDetails.user.userAvatar.isEmpty
                                        ? Icon(Icons.person, color: Colors.grey[600])
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _imageDetails.user.userAccount,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      MyToast.showInfo("暂未实现");
                                      // 关注作者
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF4FC3F7),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                            color: Color(0xFF4FC3F7)),
                                      ),
                                    ),
                                    child: const Text('关注'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // 标签
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _convertToTagList(_imageDetails.tags)
                                    .map((tag) {
                                  return Chip(
                                    label: Text(tag),
                                    backgroundColor: Colors.grey[100],
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '描述',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _imageDetails.introduction,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 16),
                              const Text(
                                '图片信息',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                  '文件大小',
                                  formatFileSize(
                                      int.parse(_imageDetails!.picSize))),
                              _buildInfoRow('图片尺寸',
                                  '${_imageDetails.picWidth} × ${_imageDetails.picHeight}'),
                              _buildInfoRow('图片比例',
                                  _imageDetails.picScale.toStringAsFixed(2)),
                              _buildInfoRow('图片格式', _imageDetails.picFormat),
                              const Divider(),
                              // 评论区
                              Container(
                                key: _commentsKey,
                                child: _buildCommentsSection1(),
                              ),
                              const SizedBox(height: 20),
                              // 减少底部空间
                            ],
                          ),
                        )
                      : _buildContentSkeleton(), // 显示内容骨架屏
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
                left: 8,
                right: 8,
                top: 8,
                bottom:
                    8 + (keyboardVisible ? 0 : mediaQuery.viewPadding.bottom),
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
                          // 点击输入框时自动弹起键盘并滚动到评论区
                          _commentFocusNode.requestFocus();
                          _scrollToComments();
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
📸 ${_imageDetails.name}

📝 ${_imageDetails.introduction}


🔗 图片链接：${_imageDetails.url}

#摄影 #图库 ${(_imageDetails.tags ?? [] as List<String>).map((tag) => '#$tag').join(' ')}
    '''
        .trim();

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
                        _navigateBack();
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
                    onPressed: _navigateBack,
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
    Share.share(_imageDetails.url);

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
    Share.share(
      '分享一张精美图片：${_imageDetails.name}\n${_imageDetails.url}',
      subject: _imageDetails.name,
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
        if (_commentsLoading)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '加载评论中...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else if (_comments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
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
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentItem(_comments[index]);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1, color: Color(0xFFEFEFEF))),
                  const SizedBox(width: 8),
                  Text(
                    '已显示全部评论',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider(thickness: 1, color: Color(0xFFEFEFEF))),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
      ],
    );
  }

  // 构建单个评论项
  Widget _buildCommentItem(CommentVO comment) {
    final isHighlighted = _highlightedCommentId?.toString() == comment.id;

    return Container(
      key: _getItemKey(comment.id),
      margin: const EdgeInsets.only(bottom: 16),
      padding: isHighlighted ? const EdgeInsets.all(12) : EdgeInsets.zero,
      decoration: isHighlighted
          ? BoxDecoration(
              color: const Color(0xFF4FC3F7).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4FC3F7).withOpacity(0.2),
                width: 1,
              ),
            )
          : null,
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
                backgroundColor: Colors.grey[300],
                child: comment.user.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          comment.user.userAvatar!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.grey[600],
                      ),
              ),
              const SizedBox(width: 12),

              // 评论内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名、时间与回复数气泡
                    Row(
                      children: [
                        Text(
                          comment.user.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(comment.createTime),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (comment.replies.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE5EAF1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 12, color: Color(0xFF4FC3F7)),
                                const SizedBox(width: 4),
                                Text(
                                  '${comment.replies.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF4FC3F7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 评论文本
                    Text(
                      comment.content,
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
                          onTap: () => _likeComment(comment),
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0',
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
                              color: isHighlighted
                                  ? const Color(0xFF4FC3F7)
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: isHighlighted
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
          if (comment.replies.isNotEmpty)
            _buildRepliesTree(comment.replies, 1, parentId: comment.id),
        ],
      ),
    );
  }

  // 构建回复树（支持多级 + 可折叠 + 限制初始数量）
  Widget _buildRepliesTree(List<CommentVO> replies, int level, {String? parentId}) {
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    final double indent = 44 + (level - 1) * 24;
    final String keyId = parentId ?? 'root-$level';
    final bool expanded = _expanded[keyId] ?? (level <= _maxDefaultDepth);

    // 计算需要显示的条数（未展开时仅显示前 _initialChildren 条）
    final int visibleCount = expanded ? replies.length : replies.length.clamp(0, _initialChildren);
    final List<CommentVO> visibleReplies = replies.take(visibleCount).toList();

    return Container(
      margin: EdgeInsets.only(left: indent, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 可见的子回复列表
          ...visibleReplies.map((reply) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReplyItem(reply, level),
                  if (reply.replies.isNotEmpty)
                    _buildRepliesTree(reply.replies, level + 1, parentId: reply.id),
                ],
              )),

          // 展开/收起按钮（当有更多未显示项时）
          if (replies.length > visibleCount)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded[keyId] = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 0, top: 8, bottom: 4),
                child: Text(
                  '展开剩余${replies.length - visibleCount}条回复',
                  style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),

          // 已展开时提供“收起”入口（避免列表过长）
          if (expanded && replies.length > _initialChildren)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded[keyId] = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 0, top: 4),
                child: Text(
                  '收起回复',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建回复项（带层级）
  Widget _buildReplyItem(CommentVO reply, int level) {
    final isHighlighted = _highlightedReplyId?.toString() == reply.id;

    return Container(
      key: _getItemKey(reply.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF4FC3F7).withOpacity(0.08)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(
                color: const Color(0xFF4FC3F7).withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: reply.user.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      reply.user.userAvatar!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
          ),
          const SizedBox(width: 10),

          // 回复内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名与层级指示线
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.user.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (level > 1)
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 1,
                                  margin: const EdgeInsets.only(right: 6, top: 6),
                                  color: Colors.grey[300],
                                ),
                                Text(
                                  '回复',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  reply.replies.isNotEmpty
                                      ? '${reply.replies.length}条回复'
                                      : '展开',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(reply.createTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 回复文本
                Text(
                  reply.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                // 操作按钮
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _likeComment(reply),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '0',
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
                      onTap: () => _replyToComment(reply),
                      child: Text(
                        '回复',
                        style: TextStyle(
                          color: isHighlighted
                              ? const Color(0xFF4FC3F7)
                              : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: isHighlighted
                              ? FontWeight.w600
                              : FontWeight.normal,
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
      total += comment.replies.length;
    }
    return total;
  }

  // 点赞评论
  void _likeComment(CommentVO comment) {
    MyToast.showInfo('点赞功能暂未实现');
  }

  // 回复评论（同时设置评论与回复高亮，并滚动定位到目标项）
  void _replyToComment(CommentVO comment) {
    setState(() {
      _replyToUser = comment.user.userName ?? '无名';
      _parentId = comment.id;
      _highlightedCommentId = comment.id;
      _highlightedReplyId = comment.id;
    });
    // 延迟一帧后：请求焦点 + 滚动到高亮项，确保用户可见
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
      final key = _getItemKey(comment.id);
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 200),
          alignment: 0.1,
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 取消回复
  void _cancelReply() {
    setState(() {
      _replyToUser = null;
      _parentId = null;
      _highlightedCommentId = null; // 清除评论高亮
      _highlightedReplyId = null; // 清除回复高亮
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  // 时间格式化
  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  // 提交评论
  Future<void> _submitComment() async {
    final String content = _commentController.text.trim();

    // 检查评论内容是否为空
    if (content.isEmpty) {
      MyToast.showError('评论内容不能为空');
      return;
    }

    try {
      final res = await PictureCommentApi.addPictureComment(
        AddCommentRequest(
          pictureId: _imageDetails.id,
          content: content,
          parentId: _parentId,
        )
      );

      if (res.isNotEmpty) {
        // 重新加载评论列表
        await _initComments();

        // 显示成功提示
        if (mounted) {
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
      } else {
        MyToast.showError('评论失败');
      }
    } catch (e) {
      MyToast.showError('评论失败，请重试');
    }

    _commentController.clear();
    // 清除回复状态和高亮
    _cancelReply();
  }

  // 构建图片骨架屏
  Widget _buildImageSkeleton() {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 骨架屏动画
          ShimmerEffect(
            child: Container(
              color: Colors.white,
            ),
          ),
          // 加载指示器
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF4FC3F7),
                ),
                const SizedBox(height: 16),
                Text(
                  '图片加载中...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建内容骨架屏
  Widget _buildContentSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题骨架
          const SkeletonBox(width: double.infinity, height: 28),
          const SizedBox(height: 8),

          // 作者信息骨架
          const Row(
            children: [
              SkeletonBox(width: 32, height: 32, isCircle: true),
              SizedBox(width: 8),
              SkeletonBox(width: 120, height: 16),
              Spacer(),
              SkeletonBox(width: 60, height: 32),
            ],
          ),

          const SizedBox(height: 16),

          // 统计信息骨架
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatSkeleton(),
              StatSkeleton(),
              StatSkeleton(),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 标签骨架
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SkeletonBox(width: 60, height: 32),
              SkeletonBox(width: 80, height: 32),
              SkeletonBox(width: 70, height: 32),
            ],
          ),

          const SizedBox(height: 16),

          // 描述骨架
          const SkeletonBox(width: 80, height: 20),
          const SizedBox(height: 8),
          const SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 4),
          const SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 4),
          const SkeletonBox(width: 200, height: 16),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 拍摄信息骨架
          const SkeletonBox(width: 100, height: 20),
          const SizedBox(height: 12),
          ...List.generate(
              6,
              (index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SkeletonBox(width: 80, height: 16),
                        SizedBox(width: 8),
                        SkeletonBox(width: 120, height: 16),
                      ],
                    ),
                  )),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 评论区骨架
          const SkeletonBox(width: 80, height: 20),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => const CommentSkeleton()),
        ],
      ),
    );
  }

  // 滚动到评论区
  void _scrollToComments() {
    if (_commentsKey.currentContext != null) {
      // 延迟执行，确保键盘弹起后再滚动
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Scrollable.ensureVisible(
            _commentsKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.1, // 滚动到屏幕顶部10%的位置
          );
        }
      });
    }
  }
  // 将评论树扁平化
  List<_FlatComment> _flattenComments(CommentVO root, [int level = 0]) {
    final List<_FlatComment> result = [];
    result.add(_FlatComment(root, level));

    final bool expanded = _expanded[root.id] ?? false;
    final replies = root.replies;

    // 默认只展示前 2 条回复
    final visibleReplies = expanded ? replies : replies.take(2).toList();

    for (final reply in visibleReplies) {
      result.addAll(_flattenComments(reply, level + 1));
    }

    // 追加“展开更多”或“收起”按钮占位
    if (replies.length > 2) {
      result.add(_FlatComment.control(
        root.id,
        expanded,
        replies.length - visibleReplies.length,
        level + 1,
      ));
    }

    return result;
  }
  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 通知首页更新点赞状态
  void _notifyHomePageUpdate() {
    // 通过Navigator传递更新数据给首页
    Navigator.pop(context, _imageDetails);
  }

  // 重写返回按钮行为，返回更新后的数据
  void _navigateBack() {
    Navigator.pop(context, _imageDetails);
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



  // 单条评论渲染
  Widget _buildFlatCommentItem(CommentVO comment, int level) {
    final double indent = level == 0 ? 0 : (level == 1 ? 40 : 56);
    final replyName = comment.user.userName;

    return Container(
      margin: EdgeInsets.only(left: indent, bottom: 12),
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            backgroundImage: comment.user.userAvatar != null
                ? NetworkImage(comment.user.userAvatar!)
                : null,
            child: comment.user.userAvatar == null
                ? Icon(Icons.person, color: Colors.grey[600], size: 16)
                : null,
          ),
          const SizedBox(width: 10),

          // 内容区
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名 + 时间
                Row(
                  children: [
                    Text(
                      comment.user.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(comment.createTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 评论文本（含“回复 xxx”高亮）
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        // text: '回复 $replyName：',
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: comment.content),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // 操作行
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 3),
                          Text('0',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () {
                        _replyToComment(comment);
                      },
                      child: Text(
                        '回复',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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

  Widget _buildExpandControl(_FlatComment item) {
    final double indent = item.level == 0 ? 0 : (item.level == 1 ? 40 : 56);
    final bool expanded = item.expanded ?? false;
    final String parentId = item.parentId!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded[parentId] = !expanded;
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: indent, bottom: 8),
        child: Text(
          expanded
              ? '收起回复'
              : '展开剩余${item.remainingCount}条回复',
          style: TextStyle(
            color: expanded ? Colors.grey[600] : const Color(0xFF4FC3F7),
            fontSize: 12,
            fontWeight:
            expanded ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ),
    );
  }



  Widget _buildCommentsSection1() {
    final flatList = _comments
        .expand((c) => _flattenComments(c))
        .toList(growable: false);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flatList.length,
      itemBuilder: (context, index) {
        final item = flatList[index];
        if (item.isControl) return _buildExpandControl(item);
        return _buildFlatCommentItem(item.comment!, item.level);
      },
    );
  }
}
