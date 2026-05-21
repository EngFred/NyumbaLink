import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';

/// A modern, decoupled grid layout for property categories.
class PropertyCategoryGrid extends StatelessWidget {
  const PropertyCategoryGrid({
    super.key,
    required this.selected,
    required this.onTypeSelected,
  });

  final String? selected;
  final ValueChanged<String?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final types = PropertyTypeHelper.all;

    return ColoredBox(
      color: AppColors.background, // Match page background
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Scrolls with parent list
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8, // Tighter spacing for a compact look
                crossAxisSpacing: 10,
                childAspectRatio: 1.15, // Perfect square
              ),
              itemCount: 1 + types.length,
              itemBuilder: (context, index) {
                // The first item is always "All"
                if (index == 0) {
                  return _CategoryTile(
                    label: 'All',
                    icon: Icons.apps_rounded,
                    isSelected: selected == null,
                    onTap: () => onTypeSelected(null),
                  );
                }

                // Subsequent items map to the enums
                final type = types[index - 1];
                final isSelected = selected == type;

                return _CategoryTile(
                  label: PropertyTypeHelper.label(type),
                  icon: PropertyTypeHelper.icon(type),
                  isSelected: isSelected,
                  onTap: () => onTypeSelected(isSelected ? null : type),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.grey200),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12), // Smaller, tighter corners
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (AppColors.grey200 ?? Colors.grey.withOpacity(0.2)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02), // Very subtle depth
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24, // Scaled down to prevent overwhelming the card
              color: isSelected ? AppColors.primary : AppColors.grey700,
            ),
            const Gap(6), // Tighter gap
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10, // Scaled down text for a compact fit
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
