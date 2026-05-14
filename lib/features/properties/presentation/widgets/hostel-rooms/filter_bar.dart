import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';
import '../../../domain/entities/room_filter.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selected,
    required this.rooms,
    required this.onSelected,
  });
  final RoomFilter selected;
  final List<HostelRoom> rooms;
  final ValueChanged<RoomFilter> onSelected;

  int _count(RoomFilter f) => switch (f) {
    RoomFilter.all => rooms.length,
    RoomFilter.available => rooms.where((r) => r.status == 'AVAILABLE').length,
    RoomFilter.occupied =>
      rooms
          .where((r) => r.status == 'OCCUPIED' || r.status == 'RESERVED')
          .length,
  };

  String _label(RoomFilter f) => switch (f) {
    RoomFilter.all => 'All',
    RoomFilter.available => 'Available',
    RoomFilter.occupied => 'Occupied',
  };

  Color _activeColor(RoomFilter f) => switch (f) {
    RoomFilter.all => AppColors.primary,
    RoomFilter.available => AppColors.success,
    RoomFilter.occupied => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: RoomFilter.values.map((f) {
          final isSelected = selected == f;
          final color = _activeColor(f);
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_count(f)}',
                      style: AppTextStyles.labelLg.copyWith(
                        color: isSelected ? Colors.white : AppColors.grey600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(1),
                    Text(
                      _label(f),
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected
                            ? Colors.white.withOpacity(0.85)
                            : AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
