import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

// ── Shared shimmer colours ────────────────────────────────────────────────────

const _kBase = AppColors.grey200;
const _kHighlight = AppColors.grey50;

// ── Featured carousel shimmer ─────────────────────────────────────────────────

/// Mimics the eyebrow label + hero card + dot indicators of
/// [_FeaturedCarouselSection] while data is still loading.
class FeaturedCarouselShimmer extends StatelessWidget {
  const FeaturedCarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _kBase,
      highlightColor: _kHighlight,
      child: const _FeaturedShimmerBody(),
    );
  }
}

class _FeaturedShimmerBody extends StatelessWidget {
  const _FeaturedShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Eyebrow label row ─────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 10),
          child: Row(
            children: [
              // Gold bar placeholder
              _Box(w: 3, h: 16, radius: 2),
              SizedBox(width: 8),
              // "Featured Properties" text placeholder
              _Box(w: 150, h: 14, radius: 4),
            ],
          ),
        ),

        // ── Hero card placeholder ─────────────────────────────────────────────
        // Mirrors viewportFraction: 0.92 by leaving a small right gap
        SizedBox(
          height: 220,
          child: FractionallySizedBox(
            widthFactor: 0.92,
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image area
                  Container(color: _kBase),

                  // Featured badge — top left
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: _Box(w: 80, h: 22, radius: 20),
                  ),

                  // Type pill — top right
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: _Box(w: 80, h: 26, radius: 20),
                  ),

                  // Content block — bottom left
                  const Positioned(
                    bottom: 14,
                    left: 14,
                    right: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Box(w: double.infinity, h: 15, radius: 4),
                        SizedBox(height: 5),
                        _Box(w: 110, h: 13, radius: 4),
                        SizedBox(height: 5),
                        _Box(w: 80, h: 11, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Page indicator dots ───────────────────────────────────────────────
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active dot (wide)
            _Box(w: 16, h: 6, radius: 3),
            SizedBox(width: 6),
            _Box(w: 6, h: 6, radius: 3),
            SizedBox(width: 6),
            _Box(w: 6, h: 6, radius: 3),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Property card shimmer ─────────────────────────────────────────────────────

class PropertyCardShimmer extends StatelessWidget {
  const PropertyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _kBase,
      highlightColor: _kHighlight,
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
                      SizedBox(height: 4),
                      _Box(w: 70, h: 11, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(w: double.infinity, h: 15, radius: 6),
                SizedBox(height: 6),
                _Box(w: 200, h: 15, radius: 6),
                SizedBox(height: 8),
                _Box(w: 140, h: 12, radius: 4),
                SizedBox(height: 12),
                Row(
                  children: [
                    _Box(w: 72, h: 26, radius: 8),
                    SizedBox(width: 8),
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

// ── Shared box helper ─────────────────────────────────────────────────────────

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

// ── Full-page shimmer grid (initial load) ─────────────────────────────────────

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
