import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: RoomFilter.values.map((f) {
          final isSel = selected == f;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(f),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSel
                      ? Border.all(color: AppColors.grey200)
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _label(f),
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSel
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_count(f)}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: isSel ? AppColors.primary : AppColors.textHint,
                          fontWeight: FontWeight.bold,
                        ),
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
