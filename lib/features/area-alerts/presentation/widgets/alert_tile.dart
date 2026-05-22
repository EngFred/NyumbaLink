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

    return Material(
      color: AppColors.surface, // Pure white flat background
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: Premium Icon ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const Gap(16),

              // ── Middle: Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.areaName,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      alert.districtName,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const Gap(12),

                    // Property Types Sub-list
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

              // ── Right: Clean Actions ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle Edit Hint
                  if (onTap != null && !isDeleting)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.grey400,
                      ),
                    ),

                  // Delete Action / Loader
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
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: AppColors
                              .grey400, // Keeps it from being too loud until hovered/tapped
                          tooltip: 'Delete alert',
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small chip for property type ─────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, this.isAny = false});

  final String label;
  final bool isAny;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAny ? AppColors.grey100 : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAny
              ? AppColors.grey300!
              : AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Text(
        isAny ? label : _formatTypeLabel(label),
        style: AppTextStyles.labelSm.copyWith(
          color: isAny ? AppColors.textPrimary : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11, // Slightly smaller to look like metadata
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
