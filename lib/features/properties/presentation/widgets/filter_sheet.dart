import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/property_filters.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.current});

  final PropertyFilters current;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? _type;
  late RangeValues _priceRange;
  late int? _bedrooms;

  static const double _minPrice = 0;
  static const double _maxPrice = 5000000;

  @override
  void initState() {
    super.initState();
    _type = widget.current.type;
    _bedrooms = widget.current.bedrooms;
    _priceRange = RangeValues(
      widget.current.minPrice ?? _minPrice,
      widget.current.maxPrice ?? _maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text('Filter Properties', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAll,
                      child: Text(
                        'Clear all',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Property Type', style: AppTextStyles.h4),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PropertyTypeHelper.all.map((t) {
                        final selected = _type == t;
                        return ChoiceChip(
                          label: Text(PropertyTypeHelper.label(t)),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _type = selected ? null : t),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.grey100,
                          labelStyle: AppTextStyles.labelMd.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          side: BorderSide.none,
                          avatar: Icon(
                            PropertyTypeHelper.icon(t),
                            size: 14,
                            color: selected ? Colors.white : AppColors.grey600,
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price Range (UGX)', style: AppTextStyles.h4),
                        Text(
                          '${CurrencyFormatter.formatShort(_priceRange.start)} — ${CurrencyFormatter.formatShort(_priceRange.end)}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    RangeSlider(
                      values: _priceRange,
                      min: _minPrice,
                      max: _maxPrice,
                      divisions: 50,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.grey200,
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                    const Gap(28),
                    Text('Bedrooms', style: AppTextStyles.h4),
                    const Gap(12),
                    Row(
                      children: [null, 1, 2, 3, 4].map((n) {
                        final selected = _bedrooms == n;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(n == null ? 'Any' : '$n+'),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _bedrooms = selected ? null : n),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.grey100,
                            labelStyle: AppTextStyles.labelMd.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(40),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ElevatedButton(
                  onPressed: _apply,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearAll() {
    setState(() {
      _type = null;
      _bedrooms = null;
      _priceRange = const RangeValues(_minPrice, _maxPrice);
    });
  }

  void _apply() {
    final filters = PropertyFilters(
      type: _type,
      bedrooms: _bedrooms,
      minPrice: _priceRange.start > _minPrice ? _priceRange.start : null,
      maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
    );
    Navigator.of(context).pop(filters);
  }
}
