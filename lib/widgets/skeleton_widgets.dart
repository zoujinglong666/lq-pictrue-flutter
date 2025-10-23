import 'package:flutter/material.dart';
import 'shimmer_effect.dart';

// 统计信息骨架
class StatSkeleton extends StatelessWidget {
  const StatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(width: 24, height: 24),
        SizedBox(height: 4),
        SkeletonBox(width: 40, height: 16),
        SizedBox(height: 2),
        SkeletonBox(width: 30, height: 12),
      ],
    );
  }
}

// 评论骨架
class CommentSkeleton extends StatelessWidget {
  const CommentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 40, height: 40, isCircle: true),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 80, height: 14),
                    SizedBox(width: 8),
                    SkeletonBox(width: 60, height: 12),
                  ],
                ),
                SizedBox(height: 6),
                SkeletonBox(width: double.infinity, height: 15),
                SizedBox(height: 4),
                SkeletonBox(width: 200, height: 15),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBox(width: 40, height: 12),
                    SizedBox(width: 20),
                    SkeletonBox(width: 30, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 通知骨架屏
class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const SkeletonBox(width: 32, height: 32, isCircle: true),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 100, height: 14),
            const SizedBox(height: 4),
            const SkeletonBox(width: double.infinity, height: 12),
            const SizedBox(height: 2),
            const SkeletonBox(width: 150, height: 12),
            const SizedBox(height: 4),
            Row(
              children: [
                const SkeletonBox(width: 60, height: 10),
                const Spacer(),
                const SkeletonBox(width: 32, height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 通知列表骨架屏
class NotificationListSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const NotificationSkeleton();
      },
    );
  }
}