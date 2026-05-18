import 'package:flutter/material.dart';
import 'package:rentora/features/bookings/domain/entities/booking_filter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class BookingFilterBar extends StatelessWidget {
  const BookingFilterBar({
    super.key,
    required this.selected,
    required this.bookings,
    required this.onSelected,
  });
  final BookingFilter selected;
  final List<dynamic> bookings;
  final ValueChanged<BookingFilter> onSelected;

  int _count(BookingFilter f) => switch (f) {
    BookingFilter.all => bookings.length,
    BookingFilter.active => bookings.where((b) => !b.isCancelled).length,
    BookingFilter.cancelled => bookings.where((b) => b.isCancelled).length,
  };

  String _label(BookingFilter f) => switch (f) {
    BookingFilter.all => 'All',
    BookingFilter.active => 'Active',
    BookingFilter.cancelled => 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: BookingFilter.values.map((f) {
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
