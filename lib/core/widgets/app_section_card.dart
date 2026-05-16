import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Replaces: FormSection (edit-profile), FormSection (bookings),
///           PwSection, ComplaintSection — all structurally identical.
///
/// [padChildren] = true  → wraps children in 16/12/16/16 padding (booking forms).
/// [padChildren] = false → children manage their own padding (profile/password/complaint).
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.children,
    this.padChildren = false,
  });

  final String number;
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool padChildren;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Gap(10),
                Icon(icon, size: 17, color: AppColors.primary),
                const Gap(6),
                Text(title, style: AppTextStyles.h4),
              ],
            ),
          ),
          const Gap(4),
          const Divider(color: AppColors.grey100, height: 1),
          if (padChildren)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            )
          else ...[
            ...children,
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
