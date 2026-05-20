import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BookingSuccess extends StatelessWidget {
  const BookingSuccess({
    super.key,
    required this.propertyTitle,
    required this.onDone,
    this.roomNumber,
  });

  final String propertyTitle;
  final String? roomNumber;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // Clean flat background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              // ── Animated success icon ────────────────────────────────────
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
                    'Request Submitted!',
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
                'Your booking request for '
                '${roomNumber != null ? 'Room $roomNumber at ' : ''}'
                '$propertyTitle has been sent.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 260.ms).fadeIn(duration: 300.ms),

              const Gap(64),

              // ── What's next ──────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's next?",
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(24),
                  ..._nextSteps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step.$2,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                step.$1,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 360.ms).fadeIn(duration: 400.ms),

              const Gap(48),

              ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate(delay: 460.ms).fadeIn(duration: 300.ms),

              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  static const _nextSteps = [
    ('The property contact will review your request.', Icons.pending_outlined),
    (
      'You\'ll be contacted via the phone number you provided.',
      Icons.phone_callback_outlined,
    ),
    (
      'Check "My Bookings" to track your requests and cancel if needed.',
      Icons.receipt_long_outlined,
    ),
  ];
}
