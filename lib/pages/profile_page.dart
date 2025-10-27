import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/picture_api.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/model/picture.dart';
import 'package:lq_picture/providers/auth_provider.dart';

import 'my_space_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _GridActionItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color color;

  const _GridActionItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    required this.color,
  });

  @override
  State<_GridActionItem> createState() => _GridActionItemState();
}

class _GridActionItemState extends State<_GridActionItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100),
            () => setState(() => _isPressed = false));
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.scale(
            scale: _isPressed ? 0.88 : (0.9 + value * 0.1),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.15),
                    widget.color.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isPressed ? 0.25 : 0.15),
                    blurRadius: _isPressed ? 10 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(isDark ? 0.05 : 0.3),
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark 
                      ? Colors.white.withOpacity(0.75)
                      : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  SpaceVO spaceData = SpaceVO.empty();
  PictureStatsData statsData = PictureStatsData.empty();

  @override
  void initState() {
    super.initState();
    // 首次加载数据
    _loadData();
    _loadMyStatsData();
  }

  Future<void> _loadData() async {
    try {
      // 获取用户认证状态
      final authState = ref.read(authProvider);
      // 访问用户信息
      final user = authState.user;
      final res = await SpaceApi.getList({
        "current": 1,
        "pageSize": 10,
        "spaceType": 0,
        "userId": user!.id,
      });
      if (res.records.isNotEmpty) {
        setState(() {
          spaceData = res.records[0];
          print('空间数据加载成功: ${spaceData.spaceName}, ID: ${spaceData.id}');
        });
      } else {
        print('没有找到空间数据');
      }
    } catch (e) {
      if (mounted) {
        print('加载数据失败: $e');
      }
    } finally {}
  }

  Future<void> _loadMyStatsData() async {
    try {
      final res = await PictureApi.myStats();
      setState(() {
        statsData = res;
      });
    } catch (e) {
      if (mounted) {
        print('加载数据失败: $e');
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    // 获取用户认证状态
    final authState = ref.watch(authProvider);
    // 监听认证状态变化

    // 访问用户信息
    final user = authState.user;
    final isAdmin = ref
        .watch(authProvider.select((value) => value.user?.userRole == 'admin'));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF0A0E21) 
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // 新的用户信息头部
              _buildUserProfileHeader(context, user),

              const SizedBox(height: 20),

              // 统计信息 - 优化美感
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '上传',
                        statsData.uploadCount.toString(),
                        Icons.cloud_upload_outlined,
                        const Color(0xFF6FBADB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        '收藏',
                        statsData.myLikedCount.toString(),
                        Icons.favorite_border,
                        const Color(0xFFD89B9B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        '获赞',
                        statsData.likeReceivedCount.toString(),
                        Icons.thumb_up_outlined,
                        const Color(0xFFB8A8C9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              // 我的功能区域
              _buildSectionTitle('我的图库'),
              const SizedBox(height: 12),
              _buildActionGrid(
                context,
                [
                  // 如果没有空间，则显示创建空间选项
                  if (spaceData.id.isEmpty) ...[
                    {
                      'icon': Icons.add_photo_alternate,
                      'title': '创建空间',
                      'onTap': () =>
                          Navigator.pushNamed(context, '/create_space'),
                    }
                  ]
                  // 如果有空间，则显示相关操作
                  else ...[
                    {
                      'icon': Icons.photo_library_outlined,
                      'title': '我的空间',
                      'onTap': () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MySpacePage(
                              onRefresh: _loadData,
                            ),
                          ),
                        ).then((_) {
                          // 从空间页面返回时刷新数据
                          _loadData();
                        });
                      },
                    },
                  ],
                  // 其他通用选项
                  {
                    'icon': Icons.fact_check_outlined,
                    'title': '审核状态',
                    'onTap': () =>
                        Navigator.pushNamed(context, '/image_review_status'),
                  },
                  {
                    'icon': Icons.favorite_border,
                    'title': '我的收藏',
                    'onTap': () => Navigator.pushNamed(context, '/favorites'),
                  },
                  {
                    'icon': Icons.download_for_offline_outlined,
                    'title': '下载管理',
                    'onTap': () {},
                  },
                ],
              ),

              const SizedBox(height: 28),

              // 管理员功能区域 (仅管理员可见)
              if (isAdmin) ...[
                _buildSectionTitle('管理员功能'),
                const SizedBox(height: 12),
                _buildActionGrid(
                  context,
                  [
                    {
                      'icon': Icons.admin_panel_settings_outlined,
                      'title': '图片管理',
                      'onTap': () =>
                          Navigator.pushNamed(context, '/picture_management'),
                    },
                    {
                      'icon': Icons.storage_outlined,
                      'title': '空间管理',
                      'onTap': () =>
                          Navigator.pushNamed(context, '/space_management'),
                    },
                    {
                      'icon': Icons.people_outline,
                      'title': '用户管理',
                      'onTap': () =>
                          Navigator.pushNamed(context, '/user_management'),
                    },
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color themeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.85 + animValue * 0.15,
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0), // 确保值在合法范围内
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // 主阴影
            BoxShadow(
              color: themeColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            // 内发光
            BoxShadow(
              color: Colors.white.withOpacity(isDark ? 0.03 : 0.5),
              blurRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.08),
                        ]
                      : [
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.6),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // 装饰性光晕
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            themeColor.withOpacity(isDark ? 0.15 : 0.25),
                            themeColor.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 内容
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 图标容器
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                themeColor.withOpacity(0.2),
                                themeColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: themeColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: themeColor,
                            size: 22,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 数值 - 渐变文字
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              themeColor,
                              themeColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 标题
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? Colors.white.withOpacity(0.65)
                                : Colors.grey[600],
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
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

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 16, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4FC3F7),
                  Color(0xFF6FBADB),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.grey[800],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    List<Map<String, dynamic>> actions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 定义莫兰迪色系
    final colors = [
      const Color(0xFF6FBADB), // 莫兰迪蓝
      const Color(0xFFD89B9B), // 莫兰迪粉
      const Color(0xFFB8A8C9), // 莫兰迪紫
      const Color(0xFF9FB89D), // 莫兰迪绿
      const Color(0xFFDDB892), // 莫兰迪橙
      const Color(0xFFA8C5D1), // 莫兰迪青
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
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
                color: Colors.white.withOpacity(isDark ? 0.15 : 0.4),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: actions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final action = actions[index];
                final IconData icon = action['icon'];
                final String title = action['title'];
                final VoidCallback? onTap = action['onTap'];
                final color = colors[index % colors.length];

                return _GridActionItem(
                  icon: icon,
                  title: title,
                  onTap: onTap,
                  color: color,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(BuildContext context, dynamic user) {
    final userAvatarUrl = user?.userAvatar;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(isDark ? 0.02 : 0.1),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF4FC3F7).withOpacity(0.25),
                        const Color(0xFF6FBADB).withOpacity(0.18),
                        const Color(0xFF4FC3F7).withOpacity(0.12),
                      ]
                    : [
                        const Color(0xFF4FC3F7).withOpacity(0.35),
                        const Color(0xFF6FBADB).withOpacity(0.25),
                        const Color(0xFF9DCFDF).withOpacity(0.2),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.2 : 0.45),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              children: [
                // 装饰性光晕
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(isDark ? 0.08 : 0.2),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                // 内容
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/user_settings'),
                    child: Row(
                      children: [
                        // 头像容器
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: CircleAvatar(
                              radius: 39,
                              backgroundColor: isDark 
                                  ? const Color(0xFF1A1F3A)
                                  : Colors.white,
                              child: _buildUserAvatar(userAvatarUrl),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.userName ?? '点击登录',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isDark 
                                      ? Colors.white
                                      : Colors.white,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Colors.black.withOpacity(0.15),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  user?.userProfile ?? '编辑个性签名，展示最好的你',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.white.withOpacity(0.95),
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 设置按钮
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: isDark ? Colors.white : Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      tooltip: '设置',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String? userAvatarUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (userAvatarUrl == null) {
      return Icon(
        Icons.person_outline,
        size: 42,
        color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey[400],
      );
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + value * 0.1,
            child: ClipOval(
              child: Image.network(
                userAvatarUrl,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person_outline,
                    size: 42,
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey[400],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
