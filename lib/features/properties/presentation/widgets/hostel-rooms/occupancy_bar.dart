import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class OccupancyBar extends StatelessWidget {
  const OccupancyBar({
    super.key,
    required this.availablePct,
    required this.occupiedPct,
    required this.maintenancePct,
  });
  final double availablePct;
  final double occupiedPct;
  final double maintenancePct;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                // Background
                Container(width: w, color: AppColors.grey200),
                // Maintenance (rightmost — rendered first, behind others)
                if (maintenancePct > 0)
                  Positioned(
                    right: 0,
                    width: w * maintenancePct,
                    top: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: maintenancePct),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => Container(
                        width: w * v,
                        color: AppColors.accent.withOpacity(0.6),
                      ),
                    ),
                  ),
                // Occupied
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: occupiedPct),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => Container(
                    width: w * v,
                    color: AppColors.error.withOpacity(0.75),
                  ),
                ),
                // Available
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: availablePct),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (_, v, __) =>
                      Container(width: w * v, color: AppColors.success),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
