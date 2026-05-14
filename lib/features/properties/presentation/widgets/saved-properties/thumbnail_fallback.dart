import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/enum_helpers.dart';

class ThumbnailFallback extends StatelessWidget {
  const ThumbnailFallback({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary50,
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 32,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}
