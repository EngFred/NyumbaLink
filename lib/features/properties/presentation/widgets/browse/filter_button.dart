import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.hasActive, required this.onTap});
  final bool hasActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasActive ? AppColors.primary : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: hasActive ? null : Border.all(color: AppColors.grey200),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: hasActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
          if (hasActive)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
