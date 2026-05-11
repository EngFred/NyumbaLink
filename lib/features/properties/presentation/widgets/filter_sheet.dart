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
  late int? _numberOfRooms;

  static const double _minPrice = 0;
  static const double _maxPrice = 5_000_000;

  int get _activeCount {
    int n = 0;
    if (_type != null) n++;
    if (_numberOfRooms != null) n++;
    if (_priceRange.start > _minPrice || _priceRange.end < _maxPrice) n++;
    return n;
  }

  @override
  void initState() {
    super.initState();
    _type = widget.current.type;
    _numberOfRooms = widget.current.numberOfRooms;
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _Handle(),
              _Header(activeCount: _activeCount, onClear: _clearAll),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  children: [
                    _Label('Property Type'),
                    const Gap(12),
                    _TypeGrid(
                      selected: _type,
                      onSelect: (t) => setState(() => _type = t),
                    ),
                    const Gap(28),
                    _PriceSection(
                      range: _priceRange,
                      min: _minPrice,
                      max: _maxPrice,
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                    const Gap(28),
                    _Label('Bedrooms / Rooms'),
                    const Gap(12),
                    _RoomsRow(
                      selected: _numberOfRooms,
                      onSelect: (n) => setState(() => _numberOfRooms = n),
                    ),
                    const Gap(40),
                  ],
                ),
              ),
              _ApplyBar(onApply: _apply),
            ],
          ),
        );
      },
    );
  }

  void _clearAll() => setState(() {
    _type = null;
    _numberOfRooms = null;
    _priceRange = const RangeValues(_minPrice, _maxPrice);
  });

  void _apply() {
    // Merge into current filters — preserves search & districtId
    final result = widget.current.copyWith(
      type: _type,
      clearType: _type == null,
      numberOfRooms: _numberOfRooms,
      clearNumberOfRooms: _numberOfRooms == null,
      minPrice: _priceRange.start > _minPrice ? _priceRange.start : null,
      clearMinPrice: !(_priceRange.start > _minPrice),
      maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
      clearMaxPrice: !(_priceRange.end < _maxPrice),
    );
    Navigator.of(context).pop(result);
  }
}

// ── Sheet sub-widgets ─────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeCount, required this.onClear});
  final int activeCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          Text('Filter Properties', style: AppTextStyles.h3),
          if (activeCount > 0) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$activeCount',
                style: AppTextStyles.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: onClear,
            child: Text(
              'Clear all',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.h4);
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onSelect});
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PropertyTypeHelper.all.map((t) {
        final sel = selected == t;
        return GestureDetector(
          onTap: () => onSelect(sel ? null : t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PropertyTypeHelper.icon(t),
                  size: 14,
                  color: sel ? Colors.white : AppColors.grey600,
                ),
                const Gap(6),
                Text(
                  PropertyTypeHelper.label(t),
                  style: AppTextStyles.labelMd.copyWith(
                    color: sel ? Colors.white : AppColors.textPrimary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({
    required this.range,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final RangeValues range;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _Label('Price Range')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${CurrencyFormatter.formatShort(range.start)} – ${CurrencyFormatter.formatShort(range.end)}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(4),
        RangeSlider(
          values: range,
          min: min,
          max: max,
          divisions: 50,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.grey200,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatShort(min),
                style: AppTextStyles.caption,
              ),
              Text(
                CurrencyFormatter.formatShort(max),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomsRow extends StatelessWidget {
  const _RoomsRow({required this.selected, required this.onSelect});
  final int? selected;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [null, 1, 2, 3, 4, 5].map((n) {
        final sel = selected == n;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(sel ? null : n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 50,
              height: 44,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                n == null ? 'Any' : '$n+',
                style: AppTextStyles.labelMd.copyWith(
                  color: sel ? Colors.white : AppColors.textPrimary,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({required this.onApply});
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: onApply,
          child: const Text('Apply Filters'),
        ),
      ),
    );
  }
}
