import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.isEnabled,
  });

  final String selected;
  final ValueChanged<String> onSelect;
  final bool isEnabled;

  static const Map<String, IconData> icons = {
    'PROPERTY_CONDITION': Icons.home_repair_service_outlined,
    'CONTACT_CONDUCT': Icons.person_off_outlined,
    'PRICING': Icons.price_change_outlined,
    'BOOKING': Icons.receipt_long_outlined,
    'APP_ISSUE': Icons.bug_report_outlined,
    'GENERAL': Icons.feedback_outlined,
    'OTHER': Icons.more_horiz_rounded,
  };

  static const Map<String, String> labels = {
    'PROPERTY_CONDITION': 'Property Condition',
    'CONTACT_CONDUCT': 'Agent Conduct',
    'PRICING': 'Pricing Issue',
    'BOOKING': 'Booking Issue',
    'APP_ISSUE': 'App Bug',
    'GENERAL': 'General',
    'OTHER': 'Other',
  };

  static const Map<String, String> descriptions = {
    'PROPERTY_CONDITION': 'Damage, maintenance or cleanliness',
    'CONTACT_CONDUCT': 'Agent or landlord behaviour',
    'PRICING': 'Incorrect or misleading price',
    'BOOKING': 'Problem with a booking request',
    'APP_ISSUE': 'Bug or technical problem in the app',
    'GENERAL': 'General feedback or suggestion',
    'OTHER': 'Something not listed above',
  };

  @override
  Widget build(BuildContext context) {
    final categories = icons.keys.toList();

    // Removed the heavy 14px padding since it's no longer constrained in a card
    return Column(
      children: [
        for (int i = 0; i < categories.length; i += 2) ...[
          if (i > 0) const Gap(12), // Slightly increased gap for breathability
          Row(
            children: [
              Expanded(
                child: _CategoryTile(
                  category: categories[i],
                  isSelected: selected == categories[i],
                  isEnabled: isEnabled,
                  onTap: () => onSelect(categories[i]),
                ),
              ),
              const Gap(12),
              if (i + 1 < categories.length)
                Expanded(
                  child: _CategoryTile(
                    category: categories[i + 1],
                    isSelected: selected == categories[i + 1],
                    isEnabled: isEnabled,
                    onTap: () => onSelect(categories[i + 1]),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final String category;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = CategoryGrid.icons[category]!;
    final label = CategoryGrid.labels[category]!;
    final description = CategoryGrid.descriptions[category]!;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface, // Flat
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (AppColors.grey200 ?? Colors.grey.withOpacity(0.2)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
              ],
            ),
            const Gap(6),
            Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
