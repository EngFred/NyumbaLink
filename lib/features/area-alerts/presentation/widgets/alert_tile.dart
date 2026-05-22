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
    this.onTap,
    this.isDeleting = false,
  });

  final AreaAlert alert;
  final VoidCallback? onUnsubscribe;
  final VoidCallback? onTap;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final hasTypes =
        alert.propertyTypes != null && alert.propertyTypes!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grey200 ?? Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isDeleting ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Icon Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.areaName,
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
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
                        ],
                      ),
                    ),

                    // Edit Cue
                    if (onTap != null && !isDeleting)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.textPrimary,
                            ),
                            const Gap(4),
                            Text(
                              'Edit',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const Gap(16),
                const Divider(height: 1, color: AppColors.grey200),
                const Gap(12),

                // Bottom Row: Property Types & Delete Action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WATCHING',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.grey500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Gap(8),
                          if (hasTypes)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: alert.propertyTypes!
                                  .map((type) => _TypeChip(label: type))
                                  .toList(),
                            )
                          else
                            const _TypeChip(label: 'Any Property', isAny: true),
                        ],
                      ),
                    ),

                    isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
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
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                            tooltip: 'Delete alert',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.error.withOpacity(0.1),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, this.isAny = false});
  final String label;
  final bool isAny;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAny ? AppColors.grey100 : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAny
              ? AppColors.grey300!
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Text(
        isAny ? label : _formatTypeLabel(label),
        style: AppTextStyles.labelSm.copyWith(
          color: isAny ? AppColors.textPrimary : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTypeLabel(String value) {
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
