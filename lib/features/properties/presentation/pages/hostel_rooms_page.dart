import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/property_entities.dart';
import '../providers/hostel_rooms_provider.dart';

class HostelRoomsPage extends ConsumerWidget {
  const HostelRoomsPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  final String propertyId;
  final String propertyTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hostelRoomsProvider(propertyId));

    return Scaffold(
      appBar: AppBar(title: Text(propertyTitle, style: AppTextStyles.h4)),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    HostelRoomsState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load rooms', style: AppTextStyles.h3),
            const Gap(8),
            Text(state.error!, style: AppTextStyles.bodySm),
            const Gap(16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(hostelRoomsProvider(propertyId).notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.rooms.isEmpty) {
      return Center(
        child: Text(
          'No rooms available for this hostel yet.',
          style: AppTextStyles.bodyMd,
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(hostelRoomsProvider(propertyId).notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.stats != null) _StatsHeader(stats: state.stats!),
          const Gap(24),
          Text('Available Rooms', style: AppTextStyles.h3),
          const Gap(12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.rooms.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final room = state.rooms[index];
              return _RoomCard(
                room: room,
                onTap: room.isAvailable
                    ? () {
                        context.push(
                          AppRoutes.bookingPath(propertyId),
                          extra: {
                            'title': propertyTitle,
                            'hostelRoomId': room.id,
                            'roomNumber': room.roomNumber,
                          },
                        );
                      }
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.stats});
  final HostelStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total',
            count: stats.total,
            color: AppColors.primary,
          ),
          _StatItem(
            label: 'Available',
            count: stats.available,
            color: AppColors.success,
          ),
          _StatItem(
            label: 'Occupied',
            count: stats.occupied + stats.reserved,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: AppTextStyles.h2.copyWith(color: color)),
        const Gap(4),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});
  final HostelRoom room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAvail = room.isAvailable;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Room ${room.roomNumber}', style: AppTextStyles.h3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RoomStatusHelper.color(room.status, bg: true),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      RoomStatusHelper.label(room.status),
                      style: AppTextStyles.labelSm.copyWith(
                        color: RoomStatusHelper.color(room.status),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Row(
                children: [
                  const Icon(
                    Icons.bed_rounded,
                    size: 16,
                    color: AppColors.grey500,
                  ),
                  const Gap(4),
                  Text(
                    RoomTypeHelper.label(room.type),
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  if (isAvail)
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Book'),
                    )
                  else
                    Text(
                      'Not Available',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
