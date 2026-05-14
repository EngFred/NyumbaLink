import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/enum_helpers.dart';

class HeroFallback extends StatelessWidget {
  const HeroFallback({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary50, AppColors.primary100],
        ),
      ),
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 80,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}
