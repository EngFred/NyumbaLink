import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 40,
                      color: AppColors.success,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const Gap(32),

              Text(
                    'Report Submitted!',
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),

              const Gap(12),

              Text(
                'Thank you for bringing this to our attention. Our team will review your report within 24–48 hours.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 280.ms).fadeIn(duration: 300.ms),

              const Gap(48),

              ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate(delay: 380.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
