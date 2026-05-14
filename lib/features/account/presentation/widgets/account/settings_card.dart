import 'package:flutter/material.dart';
import 'package:rentora/features/account/presentation/widgets/account/settings_tile.dart';
import '../../../../../core/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.tiles});
  final List<SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Divider(
              height: 1,
              color: AppColors.grey100,
              indent: 52,
            );
          }
          return tiles[i ~/ 2];
        }),
      ),
    );
  }
}
