import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Replaces: ErrorState in browse/, bookings/, notifications/, property details
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.onRetry,
    this.title = 'Oops, something went wrong',
    this.message =
        'We couldn\'t load the data. Please check your connection and try again.',
    this.buttonLabel = 'Try Again',
    this.icon = Icons.cloud_off_rounded,
    this.isCompact = false,
  });

  final VoidCallback onRetry;
  final String title;
  final String message;
  final String buttonLabel;
  final IconData icon;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // Padding bottom pushes the content slightly up to achieve true "optical" centering
        padding: EdgeInsets.only(
          left: isCompact ? 24 : 32,
          right: isCompact ? 24 : 32,
          bottom: isCompact ? 24 : 64,
        ),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Wraps content tightly so Center handles positioning
          children: [
            // ── Minimalist, Premium Icon ──
            Container(
                  padding: EdgeInsets.all(isCompact ? 20 : 28),
                  decoration: BoxDecoration(
                    color:
                        AppColors.grey50, // Extremely subtle background canvas
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isCompact ? 36 : 48,
                    color: AppColors.grey400,
                  ),
                )
                .animate()
                .fade(duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),

            Gap(isCompact ? 20 : 28),

            // ── Soft, reassuring typography ──
            Text(
                  title,
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            Gap(isCompact ? 8 : 12),

            Text(
                  message,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate(delay: 150.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            Gap(isCompact ? 28 : 40),

            // ── Google Material 3 "Tonal" Button ──
            FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(
                      0.08,
                    ), // Translucent tint
                    foregroundColor:
                        AppColors.primary, // Sharp primary color for text/icon
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    elevation: 0,
                    // Sleek, slightly rounded rectangle instead of a heavy pill
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
