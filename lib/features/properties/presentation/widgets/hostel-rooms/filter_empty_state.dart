import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class FilterEmptyState extends StatelessWidget {
  const FilterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(
          'No rooms match this filter.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
