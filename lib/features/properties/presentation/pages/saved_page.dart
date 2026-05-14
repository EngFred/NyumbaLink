import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/dismiss_background.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/empty_state.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/guest_banner.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/saved_header.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/saved_property_card.dart';
import 'package:rentora/features/properties/presentation/widgets/saved-properties/saved_skeleton.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    if (state.isLoading) return const SavedSkeleton();

    // Empty — authenticated
    if (state.savedList.isEmpty && isAuthenticated) {
      return const EmptyState();
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
            child: SavedHeader(
              count: list.length,
              isAuthenticated: isAuthenticated,
            ).animate().fadeIn(duration: 300.ms),
          ),

          // ── Guest banner ──────────────────────────────────────────────────
          if (!isAuthenticated)
            SliverToBoxAdapter(
              child: const GuestBanner()
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
                    background: const DismissBackground(),
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
                        SavedPropertyCard(
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
