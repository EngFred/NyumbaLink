import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(alert.areaName, style: AppTextStyles.labelLg),
        subtitle: Text(
          alert.districtName,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 22,
          ),
          onPressed: onUnsubscribe,
        ),
      ),
    );
  }
}
