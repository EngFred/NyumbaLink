import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Browse / Explore screen — shell only.
/// AppBar is provided by MainShell — do NOT add one here.
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Center(child: Text('Browse screen — coming next session')),
    );
  }
}
