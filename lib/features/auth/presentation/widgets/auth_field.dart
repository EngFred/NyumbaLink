import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.inputType,
    this.action = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.capitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? inputType;
  final TextInputAction action;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ), // Clean spacing between individual fields
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Clean, floating label ─────────────────────────────────────────
          Text(
            label, // Removed the aggressive uppercase for a softer, premium look
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),

          // ── Individual Modern Input Field ────────────────────────────────
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            textInputAction: action,
            obscureText: obscureText,
            enabled: enabled,
            textCapitalization: capitalization,
            onFieldSubmitted: onFieldSubmitted,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
              prefixIcon: Icon(icon, size: 20, color: AppColors.grey400),
              prefixIconConstraints: const BoxConstraints(minWidth: 44),
              suffixIcon: suffixIcon,

              // UX Polish: Individual boundaries instead of a grouped card
              filled: true,
              fillColor: AppColors.surface, // Clean white fill
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),

              // Default state border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              // Focus state highlight (when user is typing)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              // Error state
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
