import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ── Hero header shared by login + register + reset password ───────────────────
class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: Colors.transparent, // Blends seamlessly with the Scaffold
      padding: EdgeInsets.fromLTRB(24, top + 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Clean Back Button ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.grey100, // Subtle soft background
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const Gap(32),

          // ── Brand mark ────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/no_bg.png',
                width: 48, // Slightly tighter size for a refined look
                height: 48,
                fit: BoxFit.contain,
              ),
              const Gap(8),
              Text(
                'Rentora',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const Gap(24),

          // ── Titles ────────────────────────────────────────────────────────
          Text(
            title,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
