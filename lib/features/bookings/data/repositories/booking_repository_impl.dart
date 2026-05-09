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
  // Always saves the booking locally after the server confirms it,
  // regardless of whether the user is authenticated or not.
  // This guarantees the local store is always up-to-date and the UI
  // never has to branch on auth state for reads.

  @override
  Future<BookingResponse> createBooking(
    BookingRequest request,
    String propertyTitle,
    String? roomNumber,
  ) async {
    final responseModel = await _remoteDataSource.createBooking(
      request.toJson(),
    );

    // Always persist locally — this is our single source of truth.
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
  // Authenticated users use the secure /cancel-mine endpoint (no token needed).
  // Guest users use the public /cancel-by-renter endpoint (token required).
  // In both cases the local record is updated so the UI reflects the change
  // immediately without a round-trip.

  @override
  Future<void> cancelBooking(
    String id,
    String token,
    bool isAuthenticated, {
    String? reason,
  }) async {
    if (isAuthenticated) {
      await _remoteDataSource.cancelMine(id, reason: reason);
    } else {
      await _remoteDataSource.cancelBookingByRenter(id, token, reason: reason);
    }

    // Always update local regardless of auth state.
    await _localDataSource.markAsCancelled(id);
  }

  // ── Read ──────────────────────────────────────────────────────────────────
  //
  // SharedPreferences is ALWAYS the single source of truth for the UI.
  // The remote API is never read for display purposes.
  // The isAuthenticated flag is kept in the signature for interface
  // compatibility but is no longer used here.

  @override
  Future<List<SavedBooking>> getMyBookings(bool isAuthenticated) async {
    final localModels = await _localDataSource.getLocalBookings();
    return localModels.map((m) => m.toEntity()).toList();
  }

  // ── Sync ──────────────────────────────────────────────────────────────────
  //
  // Called once by AuthProvider right after a successful login / registration.
  // Links every locally stored booking to the user's server account using the
  // cancellation token as proof of ownership.
  // Local storage is NOT cleared — it remains the display source of truth.

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
      // Sync failure is silent — the user can still use the app offline.
    }
  }
}
