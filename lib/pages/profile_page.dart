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
                        Navigator.pushNamed(context, '/settings');
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
            _buildSectionTitle('我的图库'),
            _buildSettingCard([
              _buildActionTile(
                icon: Icons.add_photo_alternate,
                title: '创建图片空间',
                subtitle: '创建专属的图片收藏空间',
                onTap: () => Navigator.pushNamed(context, '/create_space'),
                iconColor: Colors.blue[600],
                iconBgColor: Colors.blue[50],
              ),
              const Divider(height: 0.5),
              _buildActionTile(
                icon: Icons.photo_library_outlined,
                title: '我的空间',
                subtitle: '管理我的图片空间',
                onTap: () => Navigator.pushNamed(context, '/my_space'),
                iconColor: Colors.green[600],
                iconBgColor: Colors.green[50],
              ),
              const Divider(height: 0.5),
              _buildActionTile(
                icon: Icons.collections_outlined,
                title: '我的图片',
                subtitle: '查看已上传的图片',
                onTap: () {},
                iconColor: Colors.purple[600],
                iconBgColor: Colors.purple[50],
              ),
              const Divider(height: 0.5),
              _buildActionTile(
                icon: Icons.favorite_border,
                title: '我的收藏',
                subtitle: '查看收藏的精美图片',
                onTap: () {},
                iconColor: Colors.red[600],
                iconBgColor: Colors.red[50],
              ),
              const Divider(height: 0.5),
              _buildActionTile(
                icon: Icons.download_for_offline_outlined,
                title: '下载管理',
                subtitle: '管理下载的图片文件',
                onTap: () {},
                iconColor: Colors.orange[600],
                iconBgColor: Colors.orange[50],
              ),
            ]),
            
            const SizedBox(height: 20),
            
            // 管理员功能区域
            _buildSectionTitle('管理员功能'),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
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
            _buildSettingCard([
              _buildActionTile(
                icon: Icons.admin_panel_settings_outlined,
                title: '图片管理',
                subtitle: '审核和管理用户上传的图片',
                onTap: () => Navigator.pushNamed(context, '/picture_management'),
                iconColor: Colors.red[600],
                iconBgColor: Colors.red[50],
              ),
              const Divider(height: 0.5),
              _buildActionTile(
                icon: Icons.storage_outlined,
                title: '空间管理',
                subtitle: '管理用户图片空间和存储',
                onTap: () => Navigator.pushNamed(context, '/space_management'),
                iconColor: Colors.orange[600],
                iconBgColor: Colors.orange[50],
              ),
              const Divider(height: 0.5),
              _buildActionTile(
                icon: Icons.people_outline,
                title: '用户管理',
                subtitle: '管理系统用户和权限',
                onTap: () => Navigator.pushNamed(context, '/user_management'),
                iconColor: Colors.indigo[600],
                iconBgColor: Colors.indigo[50],
              ),
            ]),
            //
            // const SizedBox(height: 20),
            //
            // // 其他功能区域
            // _buildSectionTitle('其他'),
            // _buildSettingCard([
            //   _buildActionTile(
            //     icon: Icons.settings_outlined,
            //     title: '设置',
            //     subtitle: '应用设置和个人偏好',
            //     onTap: () => Navigator.pushNamed(context, '/settings'),
            //     iconColor: Colors.grey[600],
            //     iconBgColor: Colors.grey[50],
            //   ),
            //   const Divider(height: 0.5),
            //   _buildActionTile(
            //     icon: Icons.help_outline,
            //     title: '帮助与反馈',
            //     subtitle: '获取帮助或提供使用反馈',
            //     onTap: () {},
            //     iconColor: Colors.teal[600],
            //     iconBgColor: Colors.teal[50],
            //   ),
            //   const Divider(height: 1),
            //   _buildActionTile(
            //     icon: Icons.info_outline,
            //     title: '关于',
            //     subtitle: '应用信息和版本详情',
            //     onTap: () {},
            //     iconColor: Colors.blue[600],
            //     iconBgColor: Colors.blue[50],
            //   ),
            // ]),
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

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor ?? Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon, 
          color: iconColor ?? Colors.grey[600], 
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }


}
