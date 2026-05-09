import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/booking_entities.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/bookings_local_datasource.dart';
import '../datasources/bookings_remote_datasource.dart';
import '../models/booking_models.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(
    ref.watch(bookingsRemoteDataSourceProvider),
    ref.watch(bookingsLocalDataSourceProvider),
  );
});

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final BookingsRemoteDataSource _remoteDataSource;
  final BookingsLocalDataSource _localDataSource;

  // ── Create ────────────────────────────────────────────────────────────────
  //
  // Always saves locally after the server confirms, regardless of auth state.
  // Local storage is the single source of truth for the UI.

  @override
  Future<BookingResponse> createBooking(
    BookingRequest request,
    String propertyTitle,
    String? roomNumber,
  ) async {
    final responseModel = await _remoteDataSource.createBooking(
      request.toJson(),
    );

    await _localDataSource.saveBookingLocally(
      bookingId: responseModel.id,
      cancellationToken: responseModel.cancellationToken,
      propertyTitle: propertyTitle,
      roomNumber: roomNumber,
    );

    return responseModel.toEntity();
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  //
  // Cancellation endpoint decision logic:
  //
  //   token is non-empty → use /cancel-by-renter (public, token-based).
  //                         Covers two cases:
  //                           a) actual guest user
  //                           b) authenticated user whose booking was made
  //                              as a guest BEFORE they logged in
  //                              (userId still null in DB, sync may not
  //                              have run yet or failed silently)
  //
  //   token is empty     → booking was created while already logged in
  //                         (userId set in DB from the start), so
  //                         /cancel-mine works safely.
  //
  // This means an authenticated user with a pre-login guest booking can
  // ALWAYS cancel — the token is the fallback proof of ownership even
  // when the account sync hasn't linked the booking yet.

  @override
  Future<void> cancelBooking(
    String id,
    String token,
    bool isAuthenticated, {
    String? reason,
  }) async {
    if (token.isNotEmpty) {
      // Token available → safe for all cases (guest or unsynced booking).
      await _remoteDataSource.cancelBookingByRenter(id, token, reason: reason);
    } else {
      // No token → booking was made while logged in → use secure endpoint.
      await _remoteDataSource.cancelMine(id, reason: reason);
    }

    // Always update local immediately so the UI reflects the change.
    await _localDataSource.markAsCancelled(id);
  }

  // ── Read ──────────────────────────────────────────────────────────────────
  //
  // SharedPreferences is ALWAYS the single source of truth for the UI.
  // isAuthenticated is kept for interface compatibility but ignored.

  @override
  Future<List<SavedBooking>> getMyBookings(bool isAuthenticated) async {
    final localModels = await _localDataSource.getLocalBookings();
    return localModels.map((m) => m.toEntity()).toList();
  }

  // ── Sync ──────────────────────────────────────────────────────────────────
  //
  // Called once right after login / registration.
  // Links local guest bookings to the server account via cancellation tokens.
  // Even if this fails, the token-based cancel path above is the safety net.

  @override
  Future<void> syncGuestData() async {
    final localBookings = await _localDataSource.getLocalBookings();
    if (localBookings.isEmpty) return;

    final payload = localBookings
        .map((b) => {'id': b.id, 'cancellationToken': b.cancellationToken})
        .toList();

    try {
      await _remoteDataSource.syncBookings(payload);
    } catch (_) {
      // Sync failure is silent — cancel still works via the token path.
    }
  }
}
