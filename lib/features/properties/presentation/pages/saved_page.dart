import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../providers/saved_properties_provider.dart';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedPropertiesProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.savedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: AppColors.grey300,
            ),
            const Gap(16),
            Text('No saved properties', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              'Properties you favorite will appear here.',
              style: AppTextStyles.bodySm,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () => context.go('/browse'),
              child: const Text('Explore Properties'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.savedList.length,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        final property = state.savedList[index];

        return GestureDetector(
          onTap: () => context.push(AppRoutes.propertyDetailPath(property.id)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  child: property.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: property.thumbnailUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.grey100,
                            width: 120,
                            height: 120,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.grey100,
                            width: 120,
                            height: 120,
                            child: const Icon(Icons.error),
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          color: AppColors.primary50,
                          child: Icon(
                            PropertyTypeHelper.icon(property.type),
                            color: AppColors.primary200,
                          ),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: AppTextStyles.labelLg,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                property.location,
                                style: AppTextStyles.bodySm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          CurrencyFormatter.formatShort(property.price),
                          style: AppTextStyles.priceSm,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
