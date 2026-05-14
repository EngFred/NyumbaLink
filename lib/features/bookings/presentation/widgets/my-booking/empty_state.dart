import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 44,
                    color: AppColors.primary200,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const Gap(24),
            Text(
              'No bookings yet',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              isAuthenticated
                  ? 'Your property booking requests will appear here once you submit them.'
                  : 'Any booking requests you make will be saved here locally.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            ElevatedButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Explore Properties'),
            ),
          ],
        ),
      ),
    );
  }
}
