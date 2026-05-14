import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ── Hero header shared by login + register ────────────────────────────────────

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 16, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // ── Shifted lighter: sky blue → brand primary ──────────────
          // The lighter top gives the dark logo elements strong contrast
          // while still graduating into the familiar brand blue
          colors: [Color(0xFF5BA8F5), AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Gap(24),

          // Brand mark
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/no_bg.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              const Gap(5),
              Text(
                'Rentora',
                style: AppTextStyles.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const Gap(20),

          Text(
            title,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            subtitle,
            style: AppTextStyles.bodyMd.copyWith(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
