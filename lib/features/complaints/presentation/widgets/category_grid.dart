import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.isEnabled,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final bool isEnabled;

  static const _icons = {
    'PROPERTY_CONDITION': Icons.home_repair_service_outlined,
    'CONTACT_CONDUCT': Icons.person_off_outlined,
    'PRICING': Icons.price_change_outlined,
    'BOOKING': Icons.receipt_long_outlined,
    'APP_ISSUE': Icons.bug_report_outlined,
    'GENERAL': Icons.feedback_outlined,
    'OTHER': Icons.more_horiz_rounded,
  };

  static const _labels = {
    'PROPERTY_CONDITION': 'Property Condition',
    'CONTACT_CONDUCT': 'Agent Conduct',
    'PRICING': 'Pricing Issue',
    'BOOKING': 'Booking Issue',
    'APP_ISSUE': 'App Bug',
    'GENERAL': 'General',
    'OTHER': 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _icons.keys.map((key) {
          final isSel = selected == key;
          return GestureDetector(
            onTap: isEnabled ? () => onSelect(key) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: isSel ? null : Border.all(color: AppColors.grey200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[key]!,
                    size: 14,
                    color: isSel ? Colors.white : AppColors.grey600,
                  ),
                  const Gap(6),
                  Text(
                    _labels[key]!,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSel ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
