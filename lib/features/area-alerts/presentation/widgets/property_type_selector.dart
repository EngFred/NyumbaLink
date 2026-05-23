import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class _TypeOption {
  const _TypeOption(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

const _propertyTypes = [
  _TypeOption('RESIDENTIAL_HOUSE', 'Rentals', Icons.home_outlined),
  _TypeOption('APARTMENT', 'Apartment', Icons.apartment_outlined),
  _TypeOption('AIRBNB', 'Airbnb', Icons.king_bed_outlined),
  _TypeOption('OFFICE_SPACE', 'Office Space', Icons.business_outlined),
  _TypeOption('BUSINESS_SPACE', 'Business Space', Icons.storefront_outlined),
  // _TypeOption('HOSTEL', 'Hostel', Icons.school_outlined),
  _TypeOption('HOTEL_LODGE', 'Hotel/Lodge', Icons.hotel_outlined),
];

class PropertyTypeSelector extends StatelessWidget {
  const PropertyTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onChanged,
  });

  final Set<String> selectedTypes;
  final ValueChanged<Set<String>> onChanged;

  void _toggleType(String value) {
    final newSet = Set<String>.from(selectedTypes);
    if (newSet.contains(value)) {
      newSet.remove(value);
    } else {
      newSet.add(value);
    }
    onChanged(newSet);
  }

  void _selectAll() {
    onChanged({});
  }

  @override
  Widget build(BuildContext context) {
    final isAnyProperty = selectedTypes.isEmpty;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // ── Explicit "Any Property" Chip ──
        _PremiumFilterChip(
          label: 'Any Property',
          icon: Icons.all_inclusive_rounded,
          isSelected: isAnyProperty,
          onTap: _selectAll,
        ),

        // ── Specific Type Chips ──
        ..._propertyTypes.map((t) {
          return _PremiumFilterChip(
            label: t.label,
            icon: t.icon,
            isSelected: selectedTypes.contains(t.value),
            onTap: () => _toggleType(t.value),
          );
        }),
      ],
    );
  }
}

class _PremiumFilterChip extends StatelessWidget {
  const _PremiumFilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.grey600,
            ),
            const Gap(8),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
