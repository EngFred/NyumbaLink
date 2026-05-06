import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Browse / Explore screen — shell only.
/// Full implementation (API, filters, cards) comes next session.
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: AppTextStyles.h3,
            children: [
              TextSpan(
                text: 'Nyumba',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              TextSpan(
                text: 'Link',
                style: AppTextStyles.h3.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(child: Text('Browse screen — coming next session')),
    );
  }
}
