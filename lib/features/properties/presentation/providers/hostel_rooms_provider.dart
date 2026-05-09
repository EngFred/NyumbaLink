import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/usecases/property_usecases.dart';
import 'usecase_providers.dart';

class HostelRoomsState {
  const HostelRoomsState({
    this.rooms = const [],
    this.stats,
    this.isLoading = true,
    this.error,
  });

  final List<HostelRoom> rooms;
  final HostelStats? stats;
  final bool isLoading;
  final String? error;

  HostelRoomsState copyWith({
    List<HostelRoom>? rooms,
    HostelStats? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HostelRoomsState(
      rooms: rooms ?? this.rooms,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final hostelRoomsProvider = StateNotifierProvider.family
    .autoDispose<HostelRoomsNotifier, HostelRoomsState, String>((ref, id) {
      return HostelRoomsNotifier(
        ref.watch(getHostelRoomsUseCaseProvider),
        ref.watch(getHostelStatsUseCaseProvider),
        id,
      )..load();
    });

class HostelRoomsNotifier extends StateNotifier<HostelRoomsState> {
  HostelRoomsNotifier(this._getRooms, this._getStats, this.propertyId)
    : super(const HostelRoomsState());

  final GetHostelRoomsUseCase _getRooms;
  final GetHostelStatsUseCase _getStats;
  final String propertyId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final responses = await Future.wait([
        _getRooms(propertyId),
        _getStats(propertyId),
      ]);
      state = state.copyWith(
        rooms: responses[0] as List<HostelRoom>,
        stats: responses[1] as HostelStats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Added the missing refresh method here
  Future<void> refresh() async {
    await load();
  }
}
