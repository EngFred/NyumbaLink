import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/area_alert.dart';

class AlertTile extends StatelessWidget {
  const AlertTile({
    super.key,
    required this.alert,
    required this.onUnsubscribe,
  });

  final AreaAlert alert;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface, // Flat background, no elevation
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.areaName,
                  style: AppTextStyles.h4.copyWith(fontSize: 16),
                ),
                const Gap(4),
                Text(
                  alert.districtName,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onUnsubscribe,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.grey400,
            ),
            tooltip: 'Remove alert',
            highlightColor: AppColors.error.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
