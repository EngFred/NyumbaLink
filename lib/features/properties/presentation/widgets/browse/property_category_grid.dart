import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';

/// A modern, decoupled grid layout for property categories.
///
/// Uses a [Wrap] instead of [GridView] so that when the total item count
/// doesn't divide evenly into rows (e.g. 7 items at 4-per-row leaves 3),
/// the trailing row is centered rather than left-aligned and visually broken.
class PropertyCategoryGrid extends StatelessWidget {
  const PropertyCategoryGrid({
    super.key,
    required this.selected,
    required this.onTypeSelected,
  });

  final String? selected;
  final ValueChanged<String?> onTypeSelected;

  // How many tiles to target per row. The actual tile width is calculated
  // dynamically from available space so this works on any screen size.
  static const int _perRow = 4;
  static const double _spacing = 10;

  @override
  Widget build(BuildContext context) {
    // `final` instead of `const` because PropertyTypeHelper.all is a getter
    // that filters based on FeatureFlags at runtime — not a compile-time constant.
    final types = PropertyTypeHelper.all;

    // Build the full ordered list: "All" tile first, then each type.
    final allItems = <Widget>[];

    // ── NEW FIX: Ensures the background matches the Search Bar perfectly ──
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Compute a tile width that fits exactly _perRow columns with
                // _spacing gaps between them, regardless of screen width.
                final totalSpacing = _spacing * (_perRow - 1);
                final tileWidth =
                    (constraints.maxWidth - totalSpacing) / _perRow;

                // Tile height follows the same aspect ratio as before (1.15).
                // childAspectRatio = w/h  →  h = w / ratio
                final tileHeight = tileWidth / 1.15;

                allItems.clear();

                // "All" tile
                allItems.add(
                  SizedBox(
                    width: tileWidth,
                    height: tileHeight,
                    child: _CategoryTile(
                      label: 'All',
                      icon: Icons.apps_rounded,
                      isSelected: selected == null,
                      onTap: () => onTypeSelected(null),
                    ),
                  ),
                );

                // One tile per visible property type
                for (final type in types) {
                  final isSelected = selected == type;
                  allItems.add(
                    SizedBox(
                      width: tileWidth,
                      height: tileHeight,
                      child: _CategoryTile(
                        label: PropertyTypeHelper.label(type),
                        icon: PropertyTypeHelper.icon(type),
                        isSelected: isSelected,
                        onTap: () => onTypeSelected(isSelected ? null : type),
                      ),
                    ),
                  );
                }

                // Wrap centers any trailing row that doesn't fill all columns,
                // e.g. 7 items → row 1: 4 tiles, row 2: 3 tiles centered.
                return Wrap(
                  spacing: _spacing,
                  runSpacing: _spacing,
                  alignment: WrapAlignment.center,
                  children: allItems,
                );
              },
            ),
          ),

          // Clean separation between the grid area and the list view below it
          const Divider(height: 1, thickness: 1, color: AppColors.grey200),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
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
              size: 24, // Optimized icon size
              color: isSelected ? AppColors.primary : AppColors.grey700,
            ),
            const Gap(6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10,
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
