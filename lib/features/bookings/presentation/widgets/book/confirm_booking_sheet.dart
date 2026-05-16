import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation bottom sheet — shown before the API call fires
// ─────────────────────────────────────────────────────────────────────────────
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
          // Sheet header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Confirm Your Booking', style: AppTextStyles.h4),
                    Text(
                      'Review before submitting',
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
                _SheetDetailRow(
                  icon: Icons.home_work_outlined,
                  label: 'Property',
                  value: roomNumber != null
                      ? '$propertyTitle · Room $roomNumber'
                      : propertyTitle,
                  iconColor: AppColors.primary,
                ),
                _SheetDivider(),
                _SheetDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  value: name,
                ),
                _SheetDivider(),
                _SheetDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: phone,
                ),
                if (email != null && email!.isNotEmpty) ...[
                  _SheetDivider(),
                  _SheetDetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email!,
                  ),
                ],
                _SheetDivider(),
                _SheetDetailRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Move-in',
                  value: DateFormat('EEE, MMM d, yyyy').format(moveInDate),
                  iconColor: AppColors.accent,
                ),
                if (notes != null && notes!.isNotEmpty) ...[
                  _SheetDivider(),
                  _SheetDetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    value: notes!,
                  ),
                ],
              ],
            ),
          ),

          const Gap(14),

          // Token reminder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.key_rounded, size: 14, color: AppColors.info),
                const Gap(8),
                Expanded(
                  child: Text(
                    'A cancellation token will be generated and saved to '
                    '"My Bookings" after submission.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
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
            label: const Text('Confirm & Submit'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
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

class _SheetDetailRow extends StatelessWidget {
  const _SheetDetailRow({
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
