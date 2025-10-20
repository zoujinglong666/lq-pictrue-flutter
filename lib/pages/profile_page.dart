import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lq_picture/apis/space_api.dart';
import 'package:lq_picture/providers/auth_provider.dart';

import 'my_space_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  SpaceVO spaceData = SpaceVO.empty();

  @override
  void initState() {
    super.initState();
    // 首次加载数据
    _loadData();
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
         print(res);

         if (res.records.isNotEmpty) {
           setState(() {
             // 刷新数据
             spaceData = res.records[0];
             print('空间数据加载成功: ${spaceData.spaceName}, ID: ${spaceData.id}');
           });
         } else {
           print('没有找到空间数据');
         }} catch (e) {
       if (mounted) {
         print('加载数据失败: $e');
       }
     } finally {

     }
   }
  @override
  Widget build(BuildContext context) {
    // 获取用户认证状态
    final authState = ref.watch(authProvider);
    // 监听认证状态变化

    // 访问用户信息
    final user = authState.user;
    final isAdmin = ref.watch(authProvider.select((value) => value.user?.userRole == 'admin'));
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
                      child: _buildStatCard('上传图片', '128', Icons.upload),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('收藏', '45', Icons.favorite),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('浏览', '1.2k', Icons.visibility),
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
                  if (spaceData.id.isEmpty)
                    {
                      'icon': Icons.add_photo_alternate,
                      'title': '创建空间',
                      'onTap': () => Navigator.pushNamed(context, '/create_space'),
                    },
                  {
                    'icon': Icons.photo_library_outlined,
                    'title': '我的空间',
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MySpacePage()),
                      );
                    },
                  },
                  {
                    'icon': Icons.collections_outlined,
                    'title': '我的图片',
                    'onTap': () {},
                  },
                  {
                    'icon': Icons.fact_check_outlined,
                    'title': '审核状态',
                    'onTap': () => Navigator.pushNamed(context, '/image_review_status'),
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
                      'onTap': () => Navigator.pushNamed(context, '/picture_management'),
                    },
                    {
                      'icon': Icons.storage_outlined,
                      'title': '空间管理',
                      'onTap': () => Navigator.pushNamed(context, '/space_management'),
                    },
                    {
                      'icon': Icons.people_outline,
                      'title': '用户管理',
                      'onTap': () => Navigator.pushNamed(context, '/user_management'),
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
    final colorScheme = Theme.of(context).colorScheme;
    Color iconColor;
    Color valueColor;
    
    // 根据不同的图标设置不同的颜色主题
    switch (icon) {
      case Icons.upload:
        iconColor = colorScheme.primary;
        valueColor = colorScheme.primary;
        break;
      case Icons.favorite:
        iconColor = Colors.redAccent;
        valueColor = Colors.redAccent;
        break;
      case Icons.visibility:
        iconColor = Colors.blueAccent;
        valueColor = Colors.blueAccent;
        break;
      default:
        iconColor = colorScheme.primary;
        valueColor = colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            iconColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  Widget _buildActionGrid(BuildContext context, List<Map<String, dynamic>> actions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildGridItem(
            context,
            icon: action['icon'],
            title: action['title'],
            onTap: action['onTap'],
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
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
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
                        backgroundColor: Theme.of(context).colorScheme.background,
                        backgroundImage: userAvatarUrl != null ? NetworkImage(userAvatarUrl) : null,
                        child: userAvatarUrl == null
                            ? Icon(Icons.person_outline, size: 36, color: Colors.grey[400])
                            : null,
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
                              shadows: [Shadow(blurRadius: 2.0, color: Colors.black26)],
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
                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                tooltip: '设置',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
