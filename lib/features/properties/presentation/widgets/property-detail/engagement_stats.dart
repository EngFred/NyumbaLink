import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/property-detail/stat_pill.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/property_entities.dart';

class EngagementStats extends StatelessWidget {
  const EngagementStats({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          StatPill(
            icon: Icons.visibility_outlined,
            label: '${property.viewCount} views',
          ),
          const Gap(12),
          StatPill(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${property.enquiryCount} enquiries',
          ),
          const Spacer(),
          Text(
            _formatDate(property.createdAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Listed ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
