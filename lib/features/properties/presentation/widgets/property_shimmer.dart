import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

class PropertyCardShimmer extends StatelessWidget {
  const PropertyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey50,
      child: const _ShimmerCardBody(),
    );
  }
}

class _ShimmerCardBody extends StatelessWidget {
  const _ShimmerCardBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: AppColors.grey200),
                // Badge placeholders
                Positioned(
                  top: 12,
                  left: 12,
                  child: _Box(w: 88, h: 24, radius: 20),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Box(w: 34, h: 34, radius: 17),
                ),
                // Price placeholder
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Box(w: 110, h: 18, radius: 4),
                      const SizedBox(height: 4),
                      _Box(w: 70, h: 11, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(w: double.infinity, h: 15, radius: 6),
                const SizedBox(height: 6),
                _Box(w: 200, h: 15, radius: 6),
                const SizedBox(height: 8),
                _Box(w: 140, h: 12, radius: 4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Box(w: 72, h: 26, radius: 8),
                    const SizedBox(width: 8),
                    _Box(w: 64, h: 26, radius: 8),
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

class _Box extends StatelessWidget {
  const _Box({required this.w, required this.h, required this.radius});
  final double w;
  final double h;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class PropertyShimmerGrid extends StatelessWidget {
  const PropertyShimmerGrid({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const PropertyCardShimmer(),
    );
  }
}
