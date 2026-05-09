import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/booking_entities.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../data/repositories/booking_repository_impl.dart';

// ── State ─────────────────────────────────────────────────────────────────────

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

// ── Provider ──────────────────────────────────────────────────────────────────

final myBookingsProvider =
    StateNotifierProvider.autoDispose<MyBookingsNotifier, MyBookingsState>((
      ref,
    ) {
      // isAuthenticated is passed so the notifier knows which cancellation
      // endpoint to call. It is no longer used for reads — those always
      // come from SharedPreferences.
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;
      return MyBookingsNotifier(
        ref.watch(bookingRepositoryProvider),
        isAuthenticated,
      )..load();
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class MyBookingsNotifier extends StateNotifier<MyBookingsState> {
  MyBookingsNotifier(this._repository, this._isAuthenticated)
    : super(const MyBookingsState());

  final BookingRepository _repository;

  // Only used to decide WHICH cancellation endpoint to hit —
  // never used to decide where to READ bookings from.
  final bool _isAuthenticated;

  // ── Load ──────────────────────────────────────────────────────────────────
  //
  // Always reads from SharedPreferences via the repository.
  // No remote read is ever performed here.

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // isAuthenticated = false forces the repository to read from local
      // storage. Since we changed the repository to always read locally,
      // this flag is effectively ignored — but we pass false explicitly
      // to make the intent clear and stay interface-compatible.
      final bookings = await _repository.getMyBookings(false);
      state = state.copyWith(isLoading: false, bookings: bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  //
  // The token parameter is used only for guest cancellations.
  // Authenticated users cancel via /cancel-mine (no token needed).
  // After a successful API call the local record is updated by the
  // repository, then we reload from local storage.

  Future<void> cancelBooking(String id, String token) async {
    state = state.copyWith(isCancelling: true, clearError: true);
    try {
      await _repository.cancelBooking(id, token, _isAuthenticated);
      // Reload from local — the repository already marked it cancelled there.
      final bookings = await _repository.getMyBookings(false);
      state = state.copyWith(isCancelling: false, bookings: bookings);
    } catch (e) {
      state = state.copyWith(isCancelling: false, error: e.toString());
    }
  }
}
