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
    this.isDeleting = false,
  });

  final AreaAlert alert;
  final VoidCallback? onUnsubscribe;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final hasTypes =
        alert.propertyTypes != null && alert.propertyTypes!.isNotEmpty;

    return Container(
      color: AppColors.surface,
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

                // ── Property Types Chips ─────────────────────────────────────
                if (hasTypes) ...[
                  const Gap(8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: alert.propertyTypes!
                        .map((type) => _TypeChip(label: type))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          // UI Polish: Show inline deletion spinner
          isDeleting
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: onUnsubscribe,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    // Grey out icon if disabled (onUnsubscribe == null)
                    color: onUnsubscribe == null
                        ? AppColors.grey200
                        : AppColors.grey400,
                  ),
                  tooltip: 'Remove alert',
                  highlightColor: AppColors.error.withOpacity(0.1),
                ),
        ],
      ),
    );
  }
}

// ── Small chip for property type ─────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        _formatTypeLabel(label),
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTypeLabel(String value) {
    // Optional: Convert enum-like values to readable labels
    switch (value) {
      case 'RESIDENTIAL_HOUSE':
        return 'House';
      case 'APARTMENT':
        return 'Apartment';
      case 'AIRBNB':
        return 'Airbnb';
      case 'OFFICE_SPACE':
        return 'Office';
      case 'BUSINESS_SPACE':
        return 'Business';
      case 'HOSTEL':
        return 'Hostel';
      case 'HOTEL_LODGE':
        return 'Hotel/Lodge';
      default:
        return value;
    }
  }
}
