import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.h4.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
    );
  }
}
