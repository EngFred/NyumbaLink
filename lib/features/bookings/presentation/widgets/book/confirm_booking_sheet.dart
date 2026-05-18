import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ConfirmBookingSheet extends StatelessWidget {
  const ConfirmBookingSheet({
    super.key,
    required this.propertyTitle,
    required this.name,
    required this.phone,
    required this.moveInDate,
    this.roomNumber,
    this.email,
    this.notes,
  });

  final String propertyTitle;
  final String? roomNumber;
  final String name;
  final String phone;
  final String? email;
  final DateTime moveInDate;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    // ── NEW PRO UX: Solid background with rounded top corners ──
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface, // CRITICAL: Fixes the transparent overlap bug
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
          // Subtle drag handle
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
            'Confirm Booking',
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

          // Clean, unboxed receipt layout
          _DetailRow(
            icon: Icons.home_work_outlined,
            label: 'Property',
            value: roomNumber != null
                ? '$propertyTitle (Room $roomNumber)'
                : propertyTitle,
          ),
          const Divider(height: 24, color: AppColors.grey100),
          _DetailRow(icon: Icons.person_outline, label: 'Name', value: name),
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
            icon: Icons.calendar_month_outlined,
            label: 'Move-in',
            value: DateFormat('EEE, MMM d, yyyy').format(moveInDate),
            iconColor: AppColors.primary,
          ),
          if (notes != null && notes!.isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.grey100),
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: notes!,
            ),
          ],

          const Gap(32),

          // Subtle information box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'A secure cancellation token will be generated and saved to your account upon submission.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Confirm & Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              height: 1.2,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
