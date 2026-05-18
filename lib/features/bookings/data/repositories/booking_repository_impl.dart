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
  // token non-empty → /cancel-by-renter (works for guests AND unsynced bookings)
  // token empty     → /cancel-mine (booking was created while logged in)
  @override
  Future<void> cancelBooking(
    String id,
    String token,
    bool isAuthenticated, {
    String? reason,
  }) async {
    if (token.isNotEmpty) {
      await _remoteDataSource.cancelBookingByRenter(id, token, reason: reason);
    } else {
      await _remoteDataSource.cancelMine(id, reason: reason);
    }

    await _localDataSource.markAsCancelled(id);
  }

  // ── Read ──────────────────────────────────────────────────────────────────
  //
  // Always reads local. isAuthenticated ignored (kept for interface compat).
  @override
  Future<List<SavedBooking>> getMyBookings(bool isAuthenticated) async {
    final localModels = await _localDataSource.getLocalBookings();
    return localModels.map((m) => m.toEntity()).toList();
  }

  // ── Sync guest bookings to account ───────────────────────────────────────
  @override
  Future<void> syncGuestData() async {
    final localBookings = await _localDataSource.getLocalBookings();
    if (localBookings.isEmpty) return;

    final payload = localBookings
        .map((b) => {'id': b.id, 'cancellationToken': b.cancellationToken})
        .toList();

    try {
      await _remoteDataSource.syncBookings(payload);
    } catch (_) {}
  }

  // ── Bidirectional sync ────────────────────────────────────────────────────
  //
  // Step 1 — Push local guest bookings to the server account (syncGuestData).
  //
  // Step 2 — Pull server bookings and merge into local storage.
  //          This is critical: status changes made by the admin (CONFIRMED,
  //          COMPLETED, CANCELLED) exist only on the server. Without this pull,
  //          local shows "REQUESTED" forever and the Cancel button stays visible
  //          even for COMPLETED bookings, causing a confusing 400 error.
  @override
  Future<void> syncFromServer() async {
    try {
      // Step 1: push local → server
      await syncGuestData();

      // Step 2: pull server → local
      final remoteBookings = await _remoteDataSource.getMyBookings();

      final remoteAsLocal = remoteBookings.map((r) {
        // Preserve the local cancellation token if we have one — the server
        // never returns it in plaintext after the first creation response.
        return LocalBookingModel(
          id: r.id,
          cancellationToken: '', // will be merged below from local
          propertyTitle: r.propertyTitle,
          price: r.price, // NEW: Pass the price
          location: r.location, // NEW: Pass the location
          thumbnailUrl: r.thumbnailUrl, // NEW: Pass the image
          roomNumber: r.roomNumber,
          bookedAt: r.createdAt,
          isCancelled: r.status == 'CANCELLED' || r.status == 'COMPLETED',
        );
      }).toList();

      await _localDataSource.upsertFromRemote(remoteAsLocal);
    } catch (_) {
      // Sync failure is silent — local state is still usable.
    }
  }
}
