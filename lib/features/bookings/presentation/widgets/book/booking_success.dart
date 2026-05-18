import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BookingSuccess extends StatelessWidget {
  const BookingSuccess({
    super.key,
    required this.propertyTitle,
    required this.cancellationToken,
    required this.onDone,
    this.roomNumber,
  });

  final String propertyTitle;
  final String? roomNumber;
  final String cancellationToken;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Gap(32),
              // ── Animated success icon ────────────────────────────────────
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 52,
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
              const Gap(24),
              Text(
                    'Request Submitted!',
                    style: AppTextStyles.h1,
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),
              const Gap(10),
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
              const Gap(32),
              // ── Token card ───────────────────────────────────────────────
              Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.accent.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.key_rounded,
                              size: 17,
                              color: AppColors.primary,
                            ),
                            const Gap(8),
                            Text(
                              'Your Cancellation Token',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            cancellationToken,
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 10,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Gap(14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 15,
                                color: AppColors.accent,
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  'Save this token — you\'ll need it to cancel this booking. '
                                  'It has also been saved to your "My Bookings" tab.',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accent,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 360.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.06, end: 0),
              const Gap(20),
              // ── What's next ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("What's next?", style: AppTextStyles.labelLg),
                    const Gap(12),
                    ..._nextSteps.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                step.$2,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  step.$1,
                                  style: AppTextStyles.bodySm.copyWith(
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
                ),
              ).animate(delay: 460.ms).fadeIn(duration: 400.ms),
              const Gap(28),
              ElevatedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text('Back to Explore'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ).animate(delay: 540.ms).fadeIn(duration: 300.ms),
              const Gap(8),
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
