import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SkeletonBox(height: 360, radius: 0),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 28, width: 260, radius: 8),
                SizedBox(height: 10),
                SkeletonBox(height: 16, width: 180, radius: 6),
                SizedBox(height: 24),
                Row(
                  children: [
                    SkeletonBox(height: 32, width: 90, radius: 10),
                    SizedBox(width: 8),
                    SkeletonBox(height: 32, width: 80, radius: 10),
                    SizedBox(width: 8),
                    SkeletonBox(height: 32, width: 70, radius: 10),
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

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    required this.radius,
  });
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
