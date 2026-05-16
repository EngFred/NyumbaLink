import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/complaints/presentation/widgets/category_grid.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation sheet — shown before the API call fires.
// Uses red/warning tones to set the right expectation for a formal report.
// ─────────────────────────────────────────────────────────────────────────────
class ConfirmReportSheet extends StatelessWidget {
  const ConfirmReportSheet({
    super.key,
    required this.category,
    required this.name,
    required this.phone,
    required this.description,
    this.email,
    this.propertyTitle,
  });

  final String category;
  final String name;
  final String phone;
  final String? email;
  final String description;
  final String? propertyTitle;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = CategoryGrid.labels[category] ?? category;
    final categoryIcon =
        CategoryGrid.icons[category] ?? Icons.feedback_outlined;
    final descPreview = description.length > 120
        ? '${description.substring(0, 120)}…'
        : description;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Confirm Your Report', style: AppTextStyles.h4),
                    Text(
                      'Please review before submitting',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Gap(20),

          // Details summary card
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category shown as a chip preview
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 15,
                        color: AppColors.grey500,
                      ),
                      const Gap(10),
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Category',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 11, color: Colors.white),
                            const Gap(5),
                            Text(
                              categoryLabel,
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (propertyTitle != null) ...[
                  _SheetDivider(),
                  _SheetRow(
                    icon: Icons.home_work_outlined,
                    label: 'Property',
                    value: propertyTitle!,
                    iconColor: AppColors.primary,
                  ),
                ],
                _SheetDivider(),
                _SheetRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  value: name,
                ),
                _SheetDivider(),
                _SheetRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: phone,
                ),
                if (email != null && email!.isNotEmpty) ...[
                  _SheetDivider(),
                  _SheetRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email!,
                  ),
                ],
                _SheetDivider(),
                _SheetRow(
                  icon: Icons.notes_rounded,
                  label: 'Issue',
                  value: descPreview,
                ),
              ],
            ),
          ),

          const Gap(14),

          // Irreversibility warning — appropriate for a formal complaint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Once submitted, this report goes to our admin team '
                    'and cannot be undone.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(20),

          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Confirm & Submit Report'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppColors.error,
            ),
          ),

          const Gap(8),

          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Go Back & Edit',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor ?? AppColors.grey500),
          const Gap(10),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    color: AppColors.grey200,
    indent: 14,
    endIndent: 14,
  );
}
