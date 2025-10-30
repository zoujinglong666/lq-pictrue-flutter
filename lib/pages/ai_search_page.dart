import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lq_picture/apis/picture_api.dart';
import '../widgets/cached_image.dart';

class AiSearchPage extends ConsumerStatefulWidget {
  const AiSearchPage({super.key});

  @override
  ConsumerState<AiSearchPage> createState() => _AiSearchPageState();
}

class _AiSearchPageState extends ConsumerState<AiSearchPage>
    with TickerProviderStateMixin {
  File? _selectedImage;
  bool _isSearching = false;
  List<PicturePreviewVO> _searchResults = [];

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 文字搜索相关
  final TextEditingController _textSearchController = TextEditingController();
  final FocusNode _textSearchFocus = FocusNode();
  
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  // 搜索结果区域的 GlobalKey
  final GlobalKey _searchResultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _textSearchController.dispose();
    _textSearchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _performAiSearch();
    }
  }

  Future<void> _performAiSearch() async {
    if (_selectedImage == null) return;

    setState(() {
      _isSearching = true;
    });

    // TODO: 调用后端 AI 图片搜索接口

    // TODO: 替换为真实的搜索结果
    setState(() {
      _isSearching = false;
      _searchResults = []; // 从接口获取结果
    });
    
    // 搜索成功后的处理
    if (_searchResults.isNotEmpty) {
      _showSuccessAndScroll(_searchResults.length);
    } else {
      _showNoResultsMessage();
    }
  }

  Future<void> _performTextSearch() async {
    final searchText = _textSearchController.text.trim();
    if (searchText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入搜索关键词')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // 隐藏键盘
    _textSearchFocus.unfocus();

    try {
      final res =
          await PictureApi.fetchSearchPictures({"searchText": searchText});
      setState(() {
        _isSearching = false;
        _searchResults = res;
      });
      
      // 搜索成功后的处理
      if (res.isNotEmpty) {
        _showSuccessAndScroll(res.length);
      } else {
        _showNoResultsMessage();
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorMessage();
    }
  }
  
  // 显示成功提示并滚动到结果区域
  void _showSuccessAndScroll(int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FC3F7), Color(0xFF6FBADB)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '搜索成功！找到 $count 张相似图片',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1A1F3A).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF4FC3F7).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
    
    // 延迟滚动到搜索结果标题位置
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        final RenderBox? renderBox = _searchResultsKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final currentScrollOffset = _scrollController.offset;
          final targetScrollOffset = currentScrollOffset + position - 150; // 150 是留出的顶部间距
          
          _scrollController.animateTo(
            targetScrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }
  
  // 显示无结果提示
  void _showNoResultsMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD89B9B).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFD89B9B),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '未找到相关图片，请尝试其他关键词',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1A1F3A).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // 显示错误提示
  void _showErrorMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '搜索失败，请稍后重试',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark 
            ? const Color(0xFF1A1F3A).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showImageSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1F3A).withOpacity(0.98),
                    const Color(0xFF0A0E21).withOpacity(0.98),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8F9FA),
                  ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      isDark ? Colors.white.withOpacity(0.3) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildSourceOption(
                icon: Icons.photo_library_rounded,
                title: '从相册选择',
                color: const Color(0xFF6FBADB),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _buildSourceOption(
                icon: Icons.camera_alt_rounded,
                title: '拍照搜索',
                color: const Color(0xFFD89B9B),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.06),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[800],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // 自定义 AppBar
            _buildCustomAppBar(isDark),

            // Tab 切换栏
            _buildTabBar(isDark),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 图片搜索页
                  _buildImageSearchTab(isDark),
                  // 文字搜索页
                  _buildTextSearchTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A1F3A).withOpacity(0.8),
                  const Color(0xFF0A0E21).withOpacity(0.8),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFF8F9FA).withOpacity(0.9),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color:
                isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : Colors.grey[800],
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FC3F7), Color(0xFF6FBADB)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI 智能搜图',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '上传图片,智能识别相似内容',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  Colors.grey[100]!,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF6FBADB)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.image_search_rounded, size: 20),
            text: '图片搜索',
          ),
          Tab(
            icon: Icon(Icons.text_fields_rounded, size: 20),
            text: '文字搜索',
          ),
        ],
      ),
    );
  }

  Widget _buildImageSearchTab(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 主要上传区域
          _buildUploadArea(isDark),

          const SizedBox(height: 32),

          // 功能说明
          _buildFeatureIntro(isDark),

          const SizedBox(height: 32),

          // 搜索结果
          if (_searchResults.isNotEmpty) _buildSearchResults(isDark),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextSearchTab(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 文字搜索输入区域
          _buildTextSearchArea(isDark),

          const SizedBox(height: 32),

          // 搜索提示
          _buildSearchTips(isDark),

          const SizedBox(height: 32),

          // 搜索结果
          if (_searchResults.isNotEmpty) _buildSearchResults(isDark),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextSearchArea(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
                spreadRadius: -8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.06),
                          ]
                        : [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.5),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    // 搜索图标
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4FC3F7),
                            Color(0xFF6FBADB),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FC3F7).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 输入框
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ]
                              : [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.2 : 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textSearchController,
                        focusNode: _textSearchFocus,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[800],
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: '描述你想找的图片...\n例如:"蓝天白云的风景照"',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.grey[500],
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onSubmitted: (_) => _performTextSearch(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 搜索按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _performTextSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: const Color(0xFF4FC3F7).withOpacity(0.4),
                        ),
                        child: _isSearching
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'AI 智能搜索',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTips(bool isDark) {
    final tips = [
      {
        'icon': Icons.tips_and_updates_rounded,
        'title': '详细描述',
        'desc': '描述越详细越准确',
        'color': const Color(0xFF6FBADB),
      },
      {
        'icon': Icons.category_rounded,
        'title': '场景分类',
        'desc': '可加入风格、色调',
        'color': const Color(0xFFD89B9B),
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'title': '氛围词汇',
        'desc': '如温暖、梦幻等',
        'color': const Color(0xFFB8A8C9),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF6FBADB)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '搜索小贴士',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: tips.map((tip) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.04),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.white.withOpacity(0.4),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (tip['color'] as Color).withOpacity(0.2),
                              (tip['color'] as Color).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tip['icon'] as IconData,
                          color: tip['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['desc'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: _selectedImage == null
              ? _buildEmptyUploadArea(isDark)
              : _buildImagePreview(isDark),
        ),
      ),
    );
  }

  Widget _buildEmptyUploadArea(bool isDark) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.06),
                        ]
                      : [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.5),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  // 装饰性光晕
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4FC3F7).withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 内容
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4FC3F7),
                                Color(0xFF6FBADB),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4FC3F7).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '上传图片开始搜索',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withOpacity(0.9)
                                : Colors.grey[800],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '支持 JPG、PNG 格式',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
                if (_isSearching)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4FC3F7),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'AI 正在识别中...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _searchResults = [];
                  });
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('重新选择'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isDark ? Colors.white.withOpacity(0.8) : Colors.grey[700],
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _performAiSearch,
                icon: const Icon(Icons.search_rounded),
                label: const Text('开始搜索'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureIntro(bool isDark) {
    final features = [
      {
        'icon': Icons.speed_rounded,
        'title': '快速识别',
        'desc': '毫秒级图像分析',
        'color': const Color(0xFF6FBADB),
      },
      {
        'icon': Icons.psychology_rounded,
        'title': '智能匹配',
        'desc': 'AI深度学习算法',
        'color': const Color(0xFFD89B9B),
      },
      {
        'icon': Icons.high_quality_rounded,
        'title': '精准搜索',
        'desc': '高准确率结果',
        'color': const Color(0xFFB8A8C9),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: features.map((feature) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.04),
                        ]
                      : [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.4),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (feature['color'] as Color).withOpacity(0.2),
                          (feature['color'] as Color).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: feature['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['desc'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    return Column(
      key: _searchResultsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF6FBADB)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '搜索结果',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                '${_searchResults.length} 张相似图片',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? Colors.white.withOpacity(0.6) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final picture = _searchResults[index];
              return _buildResultItem(picture, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(PicturePreviewVO picture, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: picture,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: picture.width / picture.height,
                child: CachedImage(
                  imageUrl: picture.thumbnailUrl ?? picture.url ?? "",
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      picture.title ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
