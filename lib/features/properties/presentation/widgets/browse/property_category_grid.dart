import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';

/// A modern, decoupled grid layout for property categories.
///
/// Uses two explicit [Row]s with [Expanded] tiles instead of a [Wrap]/[GridView]
/// so that each row always fills the full available width. This means the 3 tiles
/// in the second row are naturally wider than the 4 in the first row — labels
/// like "Business Space" and "Hotel / Lodge" never truncate.
class PropertyCategoryGrid extends StatelessWidget {
  const PropertyCategoryGrid({
    super.key,
    required this.selected,
    required this.onTypeSelected,
  });

  final String? selected;
  final ValueChanged<String?> onTypeSelected;

  static const double _spacing = 10;
  // Tile height is fixed — width expands to fill the row.
  static const double _tileHeight = 76;

  @override
  Widget build(BuildContext context) {
    // `final` not `const` — PropertyTypeHelper.all is a runtime getter
    // that respects FeatureFlags, not a compile-time constant.
    final types = PropertyTypeHelper.all;

    // Build the full flat list: "All" first, then each visible type.
    final allTypes = <String?>[null, ...types]; // null = "All" sentinel

    // Split into rows of 4. First row gets 4, second row gets the rest.
    // If Hostel is re-enabled later (8 items total) we get two perfect rows of 4.
    const firstRowCount = 4;
    final firstRow = allTypes.take(firstRowCount).toList();
    final secondRow = allTypes.skip(firstRowCount).toList();

    // ── Ensures the background matches the Search Bar perfectly ──
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                // ── Row 1: 4 tiles, equally wide ──────────────────────────
                _buildRow(firstRow),

                const Gap(_spacing),

                // ── Row 2: remaining tiles — each Expanded to fill width ──
                // This is the key fix: 3 tiles share the full row width so
                // "Business Space" and "Hotel / Lodge" never truncate.
                if (secondRow.isNotEmpty) _buildRow(secondRow),
              ],
            ),
          ),

          // Clean separation between the grid area and the list view below it
          const Divider(height: 1, thickness: 1, color: AppColors.grey200),
        ],
      ),
    );
  }

  /// Builds a full-width row where every tile shares equal width via [Expanded].
  Widget _buildRow(List<String?> rowTypes) {
    final tiles = <Widget>[];

    for (var i = 0; i < rowTypes.length; i++) {
      if (i > 0) tiles.add(const Gap(_spacing));

      final type = rowTypes[i];
      final isAll = type == null;
      final isSelected = isAll ? selected == null : selected == type;

      tiles.add(
        Expanded(
          child: SizedBox(
            height: _tileHeight,
            child: _CategoryTile(
              label: isAll ? 'All' : PropertyTypeHelper.label(type!),
              icon: isAll ? Icons.apps_rounded : PropertyTypeHelper.icon(type!),
              isSelected: isSelected,
              onTap: () => isAll
                  ? onTypeSelected(null)
                  : onTypeSelected(isSelected ? null : type),
            ),
          ),
        ),
      );
    }

    return Row(children: tiles);
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
                // 2 lines so longer labels wrap cleanly on narrower tiles
                maxLines: 2,
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
