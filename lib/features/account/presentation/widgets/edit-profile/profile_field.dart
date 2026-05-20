import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.inputType,
    this.capitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? inputType;
  final TextCapitalization capitalization;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: inputType,
            textCapitalization: capitalization,
            style: AppTextStyles.bodyMd.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
              prefixIcon: Icon(icon, size: 20, color: AppColors.grey400),
              prefixIconConstraints: const BoxConstraints(minWidth: 44),
              filled: true,
              // UX Polish: Slightly darker fill if the field is disabled (like the email)
              fillColor: enabled ? AppColors.surface : AppColors.grey50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.grey200.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
