import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.enabled,
    required this.onTap,
  });

  final DateTime? selectedDate;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Move-in Date',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' *',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
            ),
          ],
        ),
        const Gap(7),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasDate ? AppColors.primary50 : AppColors.grey50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasDate
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.grey300,
                width: hasDate ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: hasDate ? AppColors.primary : AppColors.grey500,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    hasDate
                        ? DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!)
                        : 'Select a move-in date',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: hasDate
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontWeight: hasDate ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (hasDate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Change',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.grey400,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
