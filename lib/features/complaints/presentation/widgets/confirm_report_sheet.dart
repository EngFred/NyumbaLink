import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:rentora/features/complaints/presentation/widgets/category_grid.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface, // Fixes transparent overlap
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),

          Text(
            'Confirm Report',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(6),
          Text(
            'Please review your details before submitting.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const Gap(32),

          // Clean, unboxed layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.category_outlined,
                size: 18,
                color: AppColors.textHint,
              ),
              const Gap(12),
              SizedBox(
                width: 70,
                child: Text(
                  'Category',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 12, color: Colors.white),
                          const Gap(6),
                          Text(
                            categoryLabel,
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (propertyTitle != null) ...[
            const Divider(height: 24, color: AppColors.grey100),
            _DetailRow(
              icon: Icons.home_work_outlined,
              label: 'Property',
              value: propertyTitle!,
              iconColor: AppColors.primary,
            ),
          ],

          const Divider(height: 24, color: AppColors.grey100),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Name',
            value: name,
          ),
          const Divider(height: 24, color: AppColors.grey100),
          _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: phone),

          if (email != null && email!.isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.grey100),
            _DetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email!,
            ),
          ],

          const Divider(height: 24, color: AppColors.grey100),
          _DetailRow(
            icon: Icons.notes_rounded,
            label: 'Issue',
            value: description,
          ),

          const Gap(32),

          // Information box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Once submitted, this report goes directly to our admin team and cannot be undone.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(32),

          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Submit Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Gap(8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Go Back & Edit',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.textHint),
        const Gap(12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
