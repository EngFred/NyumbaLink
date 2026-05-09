import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/booking_entities.dart';
import '../../domain/usecases/booking_usecases.dart';
import 'booking_usecase_providers.dart';

class MyBookingsState {
  const MyBookingsState({
    this.bookings = const [],
    this.isLoading = true,
    this.isCancelling = false,
    this.error,
  });

  final List<SavedBooking> bookings;
  final bool isLoading;
  final bool isCancelling;
  final String? error;

  MyBookingsState copyWith({
    List<SavedBooking>? bookings,
    bool? isLoading,
    bool? isCancelling,
    String? error,
    bool clearError = false,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      isCancelling: isCancelling ?? this.isCancelling,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final myBookingsProvider =
    StateNotifierProvider.autoDispose<MyBookingsNotifier, MyBookingsState>((
      ref,
    ) {
      return MyBookingsNotifier(
        ref.watch(getMyBookingsUseCaseProvider),
        ref.watch(cancelBookingUseCaseProvider),
      )..load();
    });

class MyBookingsNotifier extends StateNotifier<MyBookingsState> {
  MyBookingsNotifier(this._getMyBookings, this._cancelBooking)
    : super(const MyBookingsState());

  final GetMyBookingsUseCase _getMyBookings;
  final CancelBookingUseCase _cancelBooking;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _getMyBookings();
      state = state.copyWith(isLoading: false, bookings: bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cancelBooking(String id, String token) async {
    state = state.copyWith(isCancelling: true, clearError: true);
    try {
      await _cancelBooking(id, token);

      // Fetch the updated list from local storage
      final bookings = await _getMyBookings();

      // Ensure we set isCancelling to false!
      state = state.copyWith(isCancelling: false, bookings: bookings);
    } catch (e) {
      // Ensure we set isCancelling to false on error too!
      state = state.copyWith(isCancelling: false, error: e.toString());
    }
  }
}
