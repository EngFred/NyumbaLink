import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';

/// Horizontal scrollable filter bar for property types.
/// Stateless — the parent drives [selected] from the provider.
class PropertyTypeFilterBar extends StatelessWidget {
  const PropertyTypeFilterBar({
    super.key,
    required this.selected,
    required this.onTypeSelected,
  });

  final String? selected;
  final ValueChanged<String?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                _TypePill(
                  label: 'All',
                  icon: Icons.apps_rounded,
                  isSelected: selected == null,
                  onTap: () => onTypeSelected(null),
                ),
                ...PropertyTypeHelper.all.map((type) {
                  final isSelected = selected == type;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _TypePill(
                      label: PropertyTypeHelper.label(type),
                      icon: PropertyTypeHelper.icon(type),
                      isSelected: isSelected,
                      onTap: () => onTypeSelected(isSelected ? null : type),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.grey200),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppColors.grey600,
            ),
            const Gap(5),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
