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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100),
            () => setState(() => _isPressed = false));
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _isPressed ? 0.92 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: widget.color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 新的用户信息头部
              _buildUserProfileHeader(context, user),

              // 统计信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('上传图片',
                          statsData.uploadCount.toString(), Icons.upload),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('收藏',
                          statsData.myLikedCount.toString(), Icons.favorite),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                          '获得点赞数',
                          statsData.likeReceivedCount.toString(),
                          Icons.favorite),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 我的功能区域
              _buildSectionTitle('我的图库'),
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

              const SizedBox(height: 20),

              // 管理员功能区域 (仅管理员可见)
              if (isAdmin) ...[
                _buildSectionTitle('管理员功能'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据图标类型确定主色调
    Color mainColor;
    switch (icon) {
      case Icons.upload:
        mainColor = colorScheme.primary;
        break;
      case Icons.favorite:
        mainColor = Colors.pinkAccent;
        break;
      case Icons.visibility:
        mainColor = Colors.blueAccent;
        break;
      default:
        mainColor = colorScheme.primary;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mainColor.withOpacity(0.08),
              mainColor.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 0.6,
          ),
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标 + 柔光圆底
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    mainColor.withOpacity(0.25),
                    mainColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: mainColor, size: 24),
            ),

            const SizedBox(height: 12),

            // 数值
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [mainColor, mainColor.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                letterSpacing: 0.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    List<Map<String, dynamic>> actions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 20,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];
          final IconData icon = action['icon'];
          final String title = action['title'];
          final VoidCallback? onTap = action['onTap'];

          return _GridActionItem(
            icon: icon,
            title: title,
            onTap: onTap,
            color: colorScheme.primary,
          );
        },
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
    // 从认证状态中获取用户头像，如果不存在则使用默认图标
    final userAvatarUrl = user?.userAvatar;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Stack(
        children: [
          // 背景和装饰
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          // 内容
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/user_settings'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        child: _buildUserAvatar(userAvatarUrl),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.userName ?? '点击登录',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 2.0, color: Colors.black26)
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user?.userProfile ?? '编辑个性签名，展示最好的你',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
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
          // 设置按钮
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                tooltip: '设置',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? userAvatarUrl) {
    if (userAvatarUrl == null) {
      return Icon(Icons.person_outline, size: 36, color: Colors.grey[400]);
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: ClipOval(
            child: Image.network(
              userAvatarUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person_outline,
                    size: 36, color: Colors.grey[400]);
              },
            ),
          ),
        );
      },
    );
  }
}
