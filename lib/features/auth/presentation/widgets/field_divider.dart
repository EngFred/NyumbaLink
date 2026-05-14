import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FieldDivider extends StatelessWidget {
  const FieldDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    color: AppColors.grey100,
    indent: 16,
    endIndent: 16,
  );
}
