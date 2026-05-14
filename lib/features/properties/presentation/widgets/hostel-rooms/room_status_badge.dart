import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/enum_helpers.dart';

class RoomStatusBadge extends StatelessWidget {
  const RoomStatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = RoomStatusHelper.color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: RoomStatusHelper.color(status, bg: true),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        RoomStatusHelper.label(status),
        style: AppTextStyles.labelSm.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
