import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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

  // Exposed as static so the confirmation sheet can reference them
  // without duplicating data
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

  // Brief one-liners that remove the "General vs Other" ambiguity
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i += 2) ...[
            if (i > 0) const Gap(8),
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
                const Gap(8),
                // Last item (odd count) — fill with empty to preserve alignment
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
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
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
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const Gap(6),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
              ],
            ),
            const Gap(3),
            Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.78)
                    : AppColors.textSecondary,
                fontSize: 10,
                height: 1.3,
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
