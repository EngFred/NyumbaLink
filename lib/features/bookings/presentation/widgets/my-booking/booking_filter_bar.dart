import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/bookings/domain/entities/booking_filter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ── Filter bar ────────────────────────────────────────────────────────────────
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

  Color _color(BookingFilter f) => switch (f) {
    BookingFilter.all => AppColors.primary,
    BookingFilter.active => AppColors.success,
    BookingFilter.cancelled => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: BookingFilter.values.map((f) {
          final isSel = selected == f;
          final color = _color(f);

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSel ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSel
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
                        color: isSel ? Colors.white : AppColors.grey600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(1),
                    Text(
                      _label(f),
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSel
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
