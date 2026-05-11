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
import '../../domain/entities/property_entities.dart';
import '../providers/hostel_rooms_provider.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class HostelRoomsPage extends ConsumerStatefulWidget {
  const HostelRoomsPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });
  final String propertyId;
  final String propertyTitle;

  @override
  ConsumerState<HostelRoomsPage> createState() => _HostelRoomsPageState();
}

class _HostelRoomsPageState extends ConsumerState<HostelRoomsPage> {
  _RoomFilter _filter = _RoomFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostelRoomsProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.propertyTitle, style: AppTextStyles.h4),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, HostelRoomsState state) {
    if (state.isLoading) return const _HostelSkeleton();
    if (state.error != null) {
      return _HostelError(
        error: state.error!,
        onRetry: () =>
            ref.read(hostelRoomsProvider(widget.propertyId).notifier).refresh(),
      );
    }
    if (state.rooms.isEmpty) {
      return const _NoRoomsState();
    }

    final filtered = _filter == _RoomFilter.all
        ? state.rooms
        : state.rooms.where((r) {
            return switch (_filter) {
              _RoomFilter.available => r.status == 'AVAILABLE',
              _RoomFilter.occupied =>
                r.status == 'OCCUPIED' || r.status == 'RESERVED',
              _RoomFilter.all => true,
            };
          }).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(hostelRoomsProvider(widget.propertyId).notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // ── Stats ────────────────────────────────────────────────────────
          if (state.stats != null)
            SliverToBoxAdapter(
              child: _OccupancySection(stats: state.stats!)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0, duration: 350.ms),
            ),

          // ── Filter bar ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _FilterBar(
              selected: _filter,
              rooms: state.rooms,
              onSelected: (f) => setState(() => _filter = f),
            ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
          ),

          // ── Room list header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text('Rooms', style: AppTextStyles.h3),
                  const Spacer(),
                  Text(
                    '${filtered.length} shown',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          ),

          // ── Rooms ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(child: _FilterEmptyState())
                : SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (_, i) {
                      final room = filtered[i];
                      return _RoomCard(
                            room: room,
                            onBook: room.isAvailable
                                ? () => context.push(
                                    AppRoutes.bookingPath(widget.propertyId),
                                    extra: {
                                      'title': widget.propertyTitle,
                                      'hostelRoomId': room.id,
                                      'roomNumber': room.roomNumber,
                                    },
                                  )
                                : null,
                          )
                          .animate(delay: Duration(milliseconds: 120 + i * 55))
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.08, end: 0, duration: 300.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Filter enum ───────────────────────────────────────────────────────────────

enum _RoomFilter { all, available, occupied }

// ── Occupancy section ─────────────────────────────────────────────────────────

class _OccupancySection extends StatelessWidget {
  const _OccupancySection({required this.stats});
  final HostelStats stats;

  @override
  Widget build(BuildContext context) {
    final occupancyPct = stats.total > 0
        ? (stats.occupied + stats.reserved) / stats.total
        : 0.0;
    final availablePct = stats.total > 0 ? stats.available / stats.total : 0.0;
    final maintenancePct = stats.total > 0
        ? stats.maintenance / stats.total
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Occupancy Overview', style: AppTextStyles.h4),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: occupancyPct > 0.8
                      ? AppColors.errorLight
                      : AppColors.primary50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(occupancyPct * 100).toStringAsFixed(0)}% occupied',
                  style: AppTextStyles.labelSm.copyWith(
                    color: occupancyPct > 0.8
                        ? AppColors.error
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const Gap(16),

          // Segmented occupancy bar
          _OccupancyBar(
            availablePct: availablePct,
            occupiedPct: occupancyPct,
            maintenancePct: maintenancePct,
          ),

          const Gap(16),

          // Stat pills
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  count: stats.total,
                  label: 'Total',
                  color: AppColors.primary,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _StatCard(
                  count: stats.available,
                  label: 'Available',
                  color: AppColors.success,
                ),
              ),
              const Gap(8),
              Expanded(
                child: _StatCard(
                  count: stats.occupied + stats.reserved,
                  label: 'Occupied',
                  color: AppColors.error,
                ),
              ),
              if (stats.maintenance > 0) ...[
                const Gap(8),
                Expanded(
                  child: _StatCard(
                    count: stats.maintenance,
                    label: 'Maint.',
                    color: AppColors.accent,
                  ),
                ),
              ],
            ],
          ),

          // Capacity cap hint
          if (stats.slotsRemaining != null && stats.slotsRemaining! > 0) ...[
            const Gap(12),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.grey500,
                ),
                const Gap(6),
                Text(
                  '${stats.slotsRemaining} slots remaining before capacity cap',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({
    required this.availablePct,
    required this.occupiedPct,
    required this.maintenancePct,
  });
  final double availablePct;
  final double occupiedPct;
  final double maintenancePct;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                // Background
                Container(width: w, color: AppColors.grey200),
                // Maintenance (rightmost — rendered first, behind others)
                if (maintenancePct > 0)
                  Positioned(
                    right: 0,
                    width: w * maintenancePct,
                    top: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: maintenancePct),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => Container(
                        width: w * v,
                        color: AppColors.accent.withOpacity(0.6),
                      ),
                    ),
                  ),
                // Occupied
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: occupiedPct),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => Container(
                    width: w * v,
                    color: AppColors.error.withOpacity(0.75),
                  ),
                ),
                // Available
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: availablePct),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (_, v, __) =>
                      Container(width: w * v, color: AppColors.success),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
  });
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTextStyles.h2.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.rooms,
    required this.onSelected,
  });
  final _RoomFilter selected;
  final List<HostelRoom> rooms;
  final ValueChanged<_RoomFilter> onSelected;

  int _count(_RoomFilter f) => switch (f) {
    _RoomFilter.all => rooms.length,
    _RoomFilter.available => rooms.where((r) => r.status == 'AVAILABLE').length,
    _RoomFilter.occupied =>
      rooms
          .where((r) => r.status == 'OCCUPIED' || r.status == 'RESERVED')
          .length,
  };

  String _label(_RoomFilter f) => switch (f) {
    _RoomFilter.all => 'All',
    _RoomFilter.available => 'Available',
    _RoomFilter.occupied => 'Occupied',
  };

  Color _activeColor(_RoomFilter f) => switch (f) {
    _RoomFilter.all => AppColors.primary,
    _RoomFilter.available => AppColors.success,
    _RoomFilter.occupied => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _RoomFilter.values.map((f) {
          final isSelected = selected == f;
          final color = _activeColor(f);
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_count(f)}',
                      style: AppTextStyles.labelLg.copyWith(
                        color: isSelected ? Colors.white : AppColors.grey600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Gap(1),
                    Text(
                      _label(f),
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSelected
                            ? Colors.white.withOpacity(0.85)
                            : AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Room card ─────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onBook});
  final HostelRoom room;
  final VoidCallback? onBook;

  Color get _statusColor => switch (room.status) {
    'AVAILABLE' => AppColors.success,
    'OCCUPIED' => AppColors.error,
    'RESERVED' => AppColors.accent,
    'MAINTENANCE' => AppColors.grey500,
    _ => AppColors.grey400,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status strip
              Container(width: 5, color: _statusColor),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Room number + Status badge
                      Row(
                        children: [
                          Text(
                            'Room ${room.roomNumber}',
                            style: AppTextStyles.h3,
                          ),
                          const Spacer(),
                          _RoomStatusBadge(status: room.status),
                        ],
                      ),

                      const Gap(8),

                      // Row 2: Type + Floor
                      Row(
                        children: [
                          const Icon(
                            Icons.bed_rounded,
                            size: 14,
                            color: AppColors.grey500,
                          ),
                          const Gap(4),
                          Text(
                            RoomTypeHelper.label(room.type),
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (room.floor != null) ...[
                            const Gap(12),
                            const Icon(
                              Icons.layers_outlined,
                              size: 14,
                              color: AppColors.grey500,
                            ),
                            const Gap(4),
                            Text(
                              'Floor ${room.floor}',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Amenities (if any)
                      if (room.amenities != null &&
                          room.amenities!.isNotEmpty) ...[
                        const Gap(8),
                        Text(
                          room.amenities!.take(3).join(' · '),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const Gap(14),

                      // Price + CTA
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyFormatter.format(room.price),
                                style: AppTextStyles.priceMd,
                              ),
                              Text(
                                BillingCycleHelper.full(room.billingCycle),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (room.isAvailable)
                            ElevatedButton(
                              onPressed: onBook,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                textStyle: AppTextStyles.buttonSm,
                              ),
                              child: const Text('Book'),
                            )
                          else
                            Text(
                              RoomStatusHelper.label(room.status),
                              style: AppTextStyles.labelSm.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

class _RoomStatusBadge extends StatelessWidget {
  const _RoomStatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = RoomStatusHelper.color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: RoomStatusHelper.color(status, bg: true),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        RoomStatusHelper.label(status),
        style: AppTextStyles.labelSm.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ── Empty / error / skeleton states ──────────────────────────────────────────

class _NoRoomsState extends StatelessWidget {
  const _NoRoomsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hotel_outlined,
                size: 40,
                color: AppColors.primary200,
              ),
            ),
            const Gap(20),
            Text('No rooms available yet', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              'This hostel has no room listings at the moment.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterEmptyState extends StatelessWidget {
  const _FilterEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(
          'No rooms match this filter.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _HostelError extends StatelessWidget {
  const _HostelError({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const Gap(16),
            Text('Failed to load rooms', style: AppTextStyles.h3),
            const Gap(8),
            Text(
              error,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _HostelSkeleton extends StatelessWidget {
  const _HostelSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats skeleton
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Gap(16),
          // Filter skeleton
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const Gap(20),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
