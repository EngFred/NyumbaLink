import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';

/// A modern, decoupled grid layout for property categories with colorful icons.
///
/// Uses two explicit [Row]s with [Expanded] tiles for perfect width distribution.
class PropertyCategoryGrid extends StatelessWidget {
  const PropertyCategoryGrid({
    super.key,
    required this.selected,
    required this.onTypeSelected,
  });

  final String? selected;
  final ValueChanged<String?> onTypeSelected;

  static const double _spacing = 10;
  static const double _tileHeight = 76;

  @override
  Widget build(BuildContext context) {
    final types = PropertyTypeHelper.all;
    final allTypes = <String?>[null, ...types]; // null = "All"

    const firstRowCount = 4;
    final firstRow = allTypes.take(firstRowCount).toList();
    final secondRow = allTypes.skip(firstRowCount).toList();

    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _buildRow(firstRow),
                const Gap(_spacing),
                if (secondRow.isNotEmpty) _buildRow(secondRow),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.grey200),
        ],
      ),
    );
  }

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
              label: isAll ? 'All' : PropertyTypeHelper.label(type),
              icon: isAll ? Icons.apps_rounded : PropertyTypeHelper.icon(type),
              type: type, // Important for coloring
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
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String? type;
  final bool isSelected;
  final VoidCallback onTap;

  /// Returns vibrant color for each category
  Color _getIconColor() {
    if (isSelected) return AppColors.primary;

    if (type == null) return AppColors.primary;

    switch (type!.toLowerCase()) {
      case 'rental':
      case 'rentals':
        return const Color(0xFF4CAF50); // Green
      case 'apartment':
        return const Color(0xFF2196F3); // Blue
      case 'airbnb':
        return const Color(0xFFFF9800); // Orange
      case 'office':
      case 'office_space':
        return const Color(0xFF9C27B0); // Purple
      case 'business':
      case 'business_space':
        return const Color(0xFF00BCD4); // Cyan
      case 'hotel':
      case 'guest_house':
      case 'hotels':
        return const Color(0xFFEF5350); // Red
      default:
        return AppColors.grey700;
    }
  }

  Color _getBackgroundColor() {
    final baseColor = _getIconColor();
    return baseColor.withOpacity(0.08);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor();
    final bgColor = isSelected
        ? AppColors.primary.withOpacity(0.08)
        : _getBackgroundColor();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const Gap(6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 10.5,
                ),
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
