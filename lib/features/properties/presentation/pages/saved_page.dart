import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/property_entities.dart';
import '../providers/saved_properties_provider.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedPropertiesProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    // Loading
    if (state.isLoading) return const _SavedSkeleton();

    // Empty — authenticated
    if (state.savedList.isEmpty && isAuthenticated) {
      return const _EmptyState();
    }

    final list = state.savedList;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: isAuthenticated
          ? () => ref.read(savedPropertiesProvider.notifier).syncGuestData()
          : () => ref.read(savedPropertiesProvider.notifier).load(),
      child: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SavedHeader(
              count: list.length,
              isAuthenticated: isAuthenticated,
            ).animate().fadeIn(duration: 300.ms),
          ),

          // ── Guest banner ──────────────────────────────────────────────────
          if (!isAuthenticated)
            SliverToBoxAdapter(
              child: _GuestBanner()
                  .animate(delay: 60.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0, duration: 300.ms),
            ),

          // ── Empty guest ───────────────────────────────────────────────────
          if (list.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No saved properties yet.\nTap ♡ on any listing to save it.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            // ── List ──────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final property = list[index];
                  return Dismissible(
                    key: ValueKey(property.id),
                    direction: DismissDirection.endToStart,
                    background: _DismissBackground(),
                    confirmDismiss: (_) async {
                      await ref
                          .read(savedPropertiesProvider.notifier)
                          .toggleSave(
                            // Build a minimal Property from SavedProperty
                            _SavedPropertyAdapter.toProperty(property),
                          );
                      return false; // Let the state update handle removal
                    },
                    child:
                        _SavedPropertyCard(
                              property: property,
                              onTap: () => context.push(
                                AppRoutes.propertyDetailPath(property.id),
                              ),
                              onRemove: () => ref
                                  .read(savedPropertiesProvider.notifier)
                                  .toggleSave(
                                    _SavedPropertyAdapter.toProperty(property),
                                  ),
                            )
                            .animate(
                              delay: Duration(milliseconds: 80 + index * 50),
                            )
                            .fadeIn(duration: 280.ms)
                            .slideX(begin: 0.04, end: 0, duration: 280.ms),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SavedHeader extends StatelessWidget {
  const _SavedHeader({required this.count, required this.isAuthenticated});
  final int count;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (count > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count ${count == 1 ? 'property' : 'properties'}',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Gap(8),
            Text(
              'saved',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else
            Text(
              'Your saved properties',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const Spacer(),
          if (isAuthenticated && count > 0)
            const Icon(
              Icons.cloud_done_outlined,
              size: 18,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

// ── Guest banner ──────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.07),
            AppColors.accent.withOpacity(0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_sync_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sync across devices', style: AppTextStyles.labelLg),
                const Gap(4),
                Text(
                  'Sign in to back up your saved properties and access them from any device.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.register),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create an account',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Saved property card ───────────────────────────────────────────────────────

class _SavedPropertyCard extends StatelessWidget {
  const _SavedPropertyCard({
    required this.property,
    required this.onTap,
    required this.onRemove,
  });
  final SavedProperty property;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Thumbnail ────────────────────────────────────────────────
              SizedBox(
                width: 110,
                child: property.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: property.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const ColoredBox(color: AppColors.grey100),
                        errorWidget: (_, __, ___) =>
                            _ThumbnailFallback(type: property.type),
                      )
                    : _ThumbnailFallback(type: property.type),
              ),

              // ── Info ──────────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: AppTextStyles.labelLg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 11,
                                color: AppColors.accent,
                              ),
                              const Gap(3),
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
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatShort(property.price),
                            style: AppTextStyles.priceSm,
                          ),
                          _TypePill(type: property.type),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary50,
      child: Center(
        child: Icon(
          PropertyTypeHelper.icon(type),
          size: 32,
          color: AppColors.primary200,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        PropertyTypeHelper.label(type),
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            color: AppColors.error,
            size: 22,
          ),
          const Gap(4),
          Text(
            'Remove',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 46,
                    color: AppColors.primary200,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.06, 1.06),
                  duration: 1600.ms,
                  curve: Curves.easeInOut,
                ),
            const Gap(24),
            Text(
              'Nothing saved yet',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              'Tap the ♡ on any property to save it here for easy access.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            ElevatedButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Explore Properties'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SavedSkeleton extends StatelessWidget {
  const _SavedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (_) => Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Adapter: SavedProperty → minimal Property ────────────────────────────────
// (needed for toggleSave which expects a full Property)

class _SavedPropertyAdapter {
  static Property toProperty(SavedProperty s) {
    final parts = s.location.split(', ');
    final area = parts.isNotEmpty ? parts[0] : s.location;
    final districtName = parts.length > 1 ? parts[1] : '';
    return Property(
      id: s.id,
      title: s.title,
      description: '',
      type: s.type,
      price: s.price,
      area: area,
      status: 'AVAILABLE',
      district: District(id: '', name: districtName),
      contact: const Contact(id: '', name: '', phone: '', role: ''),
      images: s.thumbnailUrl != null
          ? [
              PropertyImage(
                id: '',
                url: s.thumbnailUrl!,
                publicId: '',
                isPrimary: true,
              ),
            ]
          : [],
      viewCount: 0,
      enquiryCount: 0,
      createdAt: DateTime.now(),
      numberOfRooms: 1,
      parkingAvailable: false,
    );
  }
}
