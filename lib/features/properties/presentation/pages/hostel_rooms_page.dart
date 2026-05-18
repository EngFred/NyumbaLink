import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/properties/domain/entities/room_filter.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/filter_bar.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/filter_empty_state.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/hostel_error.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/hostel_skeleton.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/no_rooms_state.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/occupancy_section.dart';
import 'package:rentora/features/properties/presentation/widgets/hostel-rooms/room_card.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/hostel_rooms_provider.dart';

class HostelRoomsPage extends ConsumerStatefulWidget {
  const HostelRoomsPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.location,
    this.imageUrl,
    this.universityName,
  });

  final String propertyId;
  final String propertyTitle;
  final String location;
  final String? imageUrl;
  final String? universityName;

  @override
  ConsumerState<HostelRoomsPage> createState() => _HostelRoomsPageState();
}

class _HostelRoomsPageState extends ConsumerState<HostelRoomsPage> {
  RoomFilter _filter = RoomFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostelRoomsProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.propertyTitle,
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
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
    if (state.isLoading) return const HostelSkeleton();

    if (state.error != null) {
      return HostelError(
        error: state.error!,
        onRetry: () =>
            ref.read(hostelRoomsProvider(widget.propertyId).notifier).refresh(),
      );
    }

    if (state.rooms.isEmpty) return const NoRoomsState();

    final filtered = _filter == RoomFilter.all
        ? state.rooms
        : state.rooms.where((r) {
            return switch (_filter) {
              RoomFilter.available => r.status == 'AVAILABLE',
              RoomFilter.occupied =>
                r.status == 'OCCUPIED' || r.status == 'RESERVED',
              RoomFilter.all => true,
            };
          }).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () =>
          ref.read(hostelRoomsProvider(widget.propertyId).notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          if (state.stats != null)
            SliverToBoxAdapter(
              child: OccupancySection(stats: state.stats!)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0, duration: 350.ms),
            ),
          SliverToBoxAdapter(
            child: FilterBar(
              selected: _filter,
              rooms: state.rooms,
              onSelected: (f) => setState(() => _filter = f),
            ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Rooms',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(child: FilterEmptyState())
                : SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (_, i) {
                      final room = filtered[i];
                      return RoomCard(
                            room: room,
                            onBook: room.isAvailable
                                ? () => context.push(
                                    AppRoutes.bookingPath(widget.propertyId),
                                    extra: {
                                      'title': widget.propertyTitle,
                                      'location': widget.location,
                                      'imageUrl': widget.imageUrl,
                                      'universityName':
                                          widget.universityName, // NEW FIX
                                      'price': room.price,
                                      'billingCycle': room.billingCycle,
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
