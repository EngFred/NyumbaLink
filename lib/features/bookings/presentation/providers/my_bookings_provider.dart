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
//
// Mirrors the same pattern as savedPropertiesProvider:
// Riverpod recreates this notifier whenever isAuthenticated changes, which
// covers app start (checkAuthStatus), login, and register — all automatically.

final myBookingsProvider =
    StateNotifierProvider.autoDispose<MyBookingsNotifier, MyBookingsState>((
      ref,
    ) {
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;
      final notifier = MyBookingsNotifier(
        ref.watch(bookingRepositoryProvider),
        isAuthenticated,
      );

      if (isAuthenticated) {
        // Authenticated: pull server statuses into local, then display.
        // This keeps CONFIRMED / COMPLETED / CANCELLED states from the admin
        // in sync without requiring the user to log out and back in.
        notifier.syncAndLoad();
      } else {
        // Guest: just read local storage.
        notifier.load();
      }

      return notifier;
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class MyBookingsNotifier extends StateNotifier<MyBookingsState> {
  MyBookingsNotifier(this._repository, this._isAuthenticated)
    : super(const MyBookingsState());

  final BookingRepository _repository;
  final bool _isAuthenticated;

  // ── Read from local (always) ──────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _repository.getMyBookings(false);
      state = state.copyWith(isLoading: false, bookings: bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Sync server → local, then display ────────────────────────────────────
  //
  // Pulls the authoritative server list, merges statuses into local storage,
  // then reads from local for display. Called on every authenticated init so
  // status changes made by the admin (CONFIRMED, COMPLETED, CANCELLED) are
  // always visible without a logout/login cycle.

  Future<void> syncAndLoad() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.syncFromServer();
    } catch (_) {
      // Sync failure is silent — fall through to read whatever is in local.
    }
    try {
      final bookings = await _repository.getMyBookings(false);
      state = state.copyWith(isLoading: false, bookings: bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> cancelBooking(String id, String token) async {
    state = state.copyWith(isCancelling: true, clearError: true);
    try {
      await _repository.cancelBooking(id, token, _isAuthenticated);
      final bookings = await _repository.getMyBookings(false);
      state = state.copyWith(isCancelling: false, bookings: bookings);
    } catch (e) {
      final message = e.toString();

      // If the server says the booking is already in a terminal state,
      // sync from server so local reflects the true status, then clear
      // the cancelling overlay without showing a confusing error.
      if (message.contains('COMPLETED') || message.contains('CANCELLED')) {
        try {
          await _repository.syncFromServer();
          final bookings = await _repository.getMyBookings(false);
          state = state.copyWith(isCancelling: false, bookings: bookings);
        } catch (_) {
          state = state.copyWith(isCancelling: false);
        }
      } else {
        state = state.copyWith(isCancelling: false, error: message);
      }
    }
  }
}
