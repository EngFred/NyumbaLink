import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BookingTextField extends StatelessWidget {
  const BookingTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.inputType,
    this.maxLines = 1,
    this.maxLength,
    this.capitalization = TextCapitalization.none,
    this.isRequired = true,
    this.isPrefilled = false,
    this.phonePrefix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? inputType;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization capitalization;
  final bool isRequired;

  /// When true: renders a blue tinted background, a blue border, and an
  /// "Auto-filled" badge next to the label — signals the value came from
  /// the user's account. Clears automatically once the user edits.
  final bool isPrefilled;

  /// When set (e.g. '+256'), renders a locked prefix chip before the input.
  /// Digits-only enforcement is applied automatically.
  final String? phonePrefix;

  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
              ),
            const Spacer(),
            if (isPrefilled) const _AutoFilledBadge(),
          ],
        ),
        const Gap(7),

        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: inputType,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: capitalization,
          inputFormatters: [
            if (phonePrefix != null) FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            // Blue tint background for auto-filled fields
            fillColor: isPrefilled ? AppColors.primary50 : AppColors.grey50,
            // Lock prefix chip replaces the icon for phone fields
            prefixIcon: phonePrefix != null
                ? _PhonePrefixChip(prefix: phonePrefix!)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isPrefilled
                          ? AppColors.primary400
                          : AppColors.grey500,
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(),
            // Hide the default character counter — we render our own below
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isPrefilled
                    ? AppColors.primary.withOpacity(0.30)
                    : AppColors.grey300,
                width: isPrefilled ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          validator: validator,
        ),

        // Character counter for multi-line fields only
        if (maxLength != null && maxLines > 1) ...[
          const Gap(4),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                final count = value.text.length;
                final nearLimit = count > maxLength! * 0.85;
                return Text(
                  '$count / $maxLength',
                  style: AppTextStyles.caption.copyWith(
                    color: nearLimit ? AppColors.accent : AppColors.textHint,
                    fontWeight: nearLimit ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ── Auto-filled badge ─────────────────────────────────────────────────────────
class _AutoFilledBadge extends StatelessWidget {
  const _AutoFilledBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_fix_high_rounded,
            size: 9,
            color: AppColors.primary,
          ),
          const Gap(3),
          Text(
            'Auto-filled',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Locked phone prefix chip ──────────────────────────────────────────────────
class _PhonePrefixChip extends StatelessWidget {
  const _PhonePrefixChip({required this.prefix});

  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Text(
        prefix,
        style: AppTextStyles.bodyMd.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
