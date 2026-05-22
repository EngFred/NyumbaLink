import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/providers/theme_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(
                    Icons.palette_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const Gap(12),
                  Text(
                    'App Theme',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            const Divider(height: 1, color: AppColors.grey200),

            _buildThemeOption(
              context: context,
              ref: ref,
              label: 'Light',
              icon: Icons.light_mode_outlined,
              value: ThemeMode.light,
              currentValue: currentTheme,
            ),
            const Divider(height: 1, color: AppColors.grey100, indent: 56),

            _buildThemeOption(
              context: context,
              ref: ref,
              label: 'Dark',
              icon: Icons.dark_mode_outlined,
              value: ThemeMode.dark,
              currentValue: currentTheme,
            ),
            const Divider(height: 1, color: AppColors.grey100, indent: 56),

            _buildThemeOption(
              context: context,
              ref: ref,
              label: 'System Default',
              icon: Icons.settings_system_daydream_outlined,
              value: ThemeMode.system,
              currentValue: currentTheme,
            ),

            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode currentValue,
  }) {
    final isSelected = value == currentValue;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey500,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLg.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(value);
        Navigator.pop(context); // Dismiss sheet immediately after selection
      },
    );
  }
}
