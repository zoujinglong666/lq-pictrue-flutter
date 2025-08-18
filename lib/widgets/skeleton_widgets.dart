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