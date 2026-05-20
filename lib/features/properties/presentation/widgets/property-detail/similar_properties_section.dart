import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/property_entities.dart';
import '../../providers/similar_properties_provider.dart';

// ── Similar Properties Section ────────────────────────────────────────────────

class SimilarPropertiesSection extends ConsumerWidget {
  const SimilarPropertiesSection({super.key, required this.property});
  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(similarPropertiesProvider(property));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Similar Properties', style: AppTextStyles.h3),
          const Gap(4),
          Text(
            'More matching recommendations around ${property.district.name}.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500),
          ),
          const Gap(16),
          asyncValue.when(
            loading: () => _SimilarShimmer(),
            error: (_, __) => _SimilarError(),
            data: (properties) {
              if (properties.isEmpty) return _SimilarEmpty(property: property);
              return _SimilarCarousel(properties: properties);
            },
          ),
        ],
      ),
    );
  }
}

// ── Carousel of similar property cards ───────────────────────────────────────

class _SimilarCarousel extends StatelessWidget {
  const _SimilarCarousel({required this.properties});
  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: properties.length,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (context, index) {
          return _SimilarPropertyCard(property: properties[index]);
        },
      ),
    );
  }
}

// ── Single similar property card ──────────────────────────────────────────────

class _SimilarPropertyCard extends StatelessWidget {
  const _SimilarPropertyCard({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/properties/${property.id}'),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Property image or fallback
                  property.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: property.thumbnailUrl!,
                          fit: BoxFit.cover,
                          memCacheHeight: 240,
                          placeholder: (_, __) =>
                              const ColoredBox(color: AppColors.grey100),
                          errorWidget: (_, __, ___) =>
                              const _CardImageFallback(),
                        )
                      : const _CardImageFallback(),

                  // Featured badge
                  if (property.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '★ Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Status indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: property.isAvailable
                            ? AppColors.success.withOpacity(0.9)
                            : AppColors.grey600.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        property.isAvailable ? 'Available' : 'Rented',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: AppTextStyles.h4.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: AppColors.grey500,
                      ),
                      const Gap(2),
                      Expanded(
                        child: Text(
                          property.locationDisplay,
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    CurrencyFormatter.format(property.price),
                    style: AppTextStyles.priceMd.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImageFallback extends StatelessWidget {
  const _CardImageFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      child: const Center(
        child: Icon(Icons.home_rounded, size: 36, color: AppColors.primary200),
      ),
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _SimilarShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (_, __) =>
            Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1200.ms, color: AppColors.grey200),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _SimilarError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(
        'Could not load similar properties.',
        style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _SimilarEmpty extends StatelessWidget {
  const _SimilarEmpty({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const Gap(12),
          Text(
            'No similar properties found',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(4),
          Text(
            'This is one of the first ${property.type.toLowerCase().replaceAll('_', ' ')} listings in ${property.district.name}.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
