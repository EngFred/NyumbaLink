import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rentora/features/properties/presentation/widgets/browse/filter_button.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
    required this.hasActiveFilters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  style: AppTextStyles.bodyMd,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by name or area…',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.grey500,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.grey500,
                            ),
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const Gap(10),
            FilterButton(hasActive: hasActiveFilters, onTap: onFilterTap),
          ],
        ),
      ),
    );
  }
}
