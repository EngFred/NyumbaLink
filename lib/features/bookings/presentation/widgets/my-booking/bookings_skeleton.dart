import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class BookingsSkeleton extends StatelessWidget {
  const BookingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics:
          const NeverScrollableScrollPhysics(), // Prevents scrolling the skeleton
      children: [
        // Header skeleton
        Container(
          height: 36,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Filter bar skeleton
        Container(
          height: 58,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        // Card skeletons
        ...List.generate(
          4,
          (i) => Container(
            height: 130,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
