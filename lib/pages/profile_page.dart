import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '我的',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.settings_outlined, color: Colors.grey[700], size: 20),
                      onPressed: () {
                        // 打开设置
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // 用户信息卡片
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/user_settings');
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '用户名',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '点击编辑个人信息',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
            _buildSectionTitle('我的功能'),
            _buildMenuItem(
              context,
              Icons.photo_library,
              '创建图片空间',
              '创建图片空间',
                  () {
                Navigator.pushNamed(context, '/create_space');
              },
            ),
            _buildMenuItem(
              context,
              Icons.folder_outlined,
              '我的空间',
              '管理我的空间',
                  () {
                Navigator.pushNamed(context, '/my_space');
              },
            ),
            _buildMenuItem(
              context,
              Icons.photo_outlined,
              '我的图片',
              '查看已上传的图片',
                  () {},
            ),
            _buildMenuItem(
              context,
              Icons.favorite_outline,
              '我的收藏',
              '查看收藏的图片',
                  () {},
            ),
            _buildMenuItem(
              context,
              Icons.download_outlined,
              '下载管理',
              '管理下载的图片',
                  () {},
            ),
            
            const SizedBox(height: 20),
            
            // 管理员功能区域
            _buildSectionTitle('管理员功能'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '以下功能仅管理员可见',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context,
              Icons.image_search,
              '图片管理',
              '管理员审核功能',
                  () {
                Navigator.pushNamed(context, '/picture_management');
              },
            ),
            _buildMenuItem(
              context,
              Icons.storage,
              '空间管理',
              '管理员空间管理',
                  () {
                Navigator.pushNamed(context, '/space_management');
              },
            ),
            _buildMenuItem(
              context,
              Icons.people_outline,
              '用户管理',
              '管理系统用户',
                  () {
                Navigator.pushNamed(context, '/user_management');
              },
            ),
            
            const SizedBox(height: 20),
            
            // 其他功能区域
            _buildSectionTitle('其他'),
            _buildMenuItem(
              context,
              Icons.settings_outlined,
              '设置',
              '应用设置和偏好',
                  () {},
            ),
            _buildMenuItem(
              context,
              Icons.help_outline,
              '帮助与反馈',
              '获取帮助或提供反馈',
                  () {},
            ),
            _buildMenuItem(
              context,
              Icons.info_outline,
              '关于',
              '应用信息和版本',
                  () {},
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}