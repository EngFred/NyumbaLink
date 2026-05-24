import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class UnauthenticatedBody extends StatelessWidget {
  const UnauthenticatedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                // ── PRO UX FIX: Nudge upwards for perfect optical centering ──
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              color: AppColors.primary50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              size: 46,
                              color: AppColors.primary,
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 300.ms),
                      const Gap(28),
                      Text(
                        'Stay in the loop',
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
                      const Gap(12),
                      Text(
                        'Sign in to receive instant alerts when your bookings are approved or when agents respond.',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ).animate(delay: 220.ms).fadeIn(duration: 300.ms),
                      const Gap(40),
                      ElevatedButton.icon(
                        onPressed: () => context.push(AppRoutes.login),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Sign In'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
                      const Gap(12),
                      OutlinedButton(
                        onPressed: () => context.push(AppRoutes.register),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: const Text('Create an Account'),
                      ).animate(delay: 360.ms).fadeIn(duration: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
