import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/core/widgets/guest_banner.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dismiss_background.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/saved_properties_provider.dart';
import '../widgets/saved-properties/saved_header.dart';
import '../widgets/saved-properties/saved_property_card.dart';
import '../widgets/saved-properties/saved_skeleton.dart';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedPropertiesProvider);
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    if (state.isLoading) return const SavedSkeleton();

    final list = state.savedList;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        if (isAuthenticated) {
          await ref.read(savedPropertiesProvider.notifier).syncData();
        } else {
          await ref.read(savedPropertiesProvider.notifier).load();
        }
      },
      child: CustomScrollView(
        slivers: [
          // ── Guest banner ──────────────────────────────────────────────────
          if (!isAuthenticated)
            SliverToBoxAdapter(
              child:
                  const GuestBanner(
                        title: 'Sync across devices',
                        subtitle:
                            'Sign in to back up your saved properties and access them from any device.',
                        icon: Icons.cloud_sync_rounded,
                        marginBottom: 16.0,
                      )
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.05, end: 0, duration: 300.ms),
            ),

          // ── Content ───────────────────────────────────────────────────────
          if (list.isEmpty)
            // UX POLISH: Changed from SliverFillRemaining to SliverToBoxAdapter
            // so it flows naturally below the banner without awkward centering.
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 48.0, bottom: 48.0),
                child: AppEmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No saved spaces yet',
                  subtitle:
                      'Tap the heart icon on properties to quickly pin your options here.',
                ),
              ),
            )
          else
            // ── List ────────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final property = list[index];
                  return Dismissible(
                    key: ValueKey(property.id),
                    direction: DismissDirection.endToStart,
                    background: const AppDismissBackground(
                      icon: Icons.favorite_border_rounded,
                      label: 'Remove',
                    ),
                    confirmDismiss: (_) async {
                      ref
                          .read(savedPropertiesProvider.notifier)
                          .toggleSave(property);
                      return false;
                    },
                    child:
                        SavedPropertyCard(
                              property: property,
                              onTap: () => context.push(
                                AppRoutes.propertyDetailPath(property.id),
                              ),
                              onRemove: () {
                                ref
                                    .read(savedPropertiesProvider.notifier)
                                    .toggleSave(property);
                              },
                            )
                            .animate(
                              delay: Duration(milliseconds: 80 + index * 50),
                            )
                            .fadeIn(duration: 280.ms)
                            .slideX(begin: 0.04, end: 0),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
