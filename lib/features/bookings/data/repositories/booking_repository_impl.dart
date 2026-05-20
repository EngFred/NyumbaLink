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

  @override
  Future<BookingResponse> createBooking(
    BookingRequest request,
    String propertyTitle,
    double price,
    String location,
    String? thumbnailUrl,
    String? roomNumber,
    String? billingCycle,
    String? universityName,
  ) async {
    final responseModel = await _remoteDataSource.createBooking(
      request.toJson(),
    );
    // Save immediately with ALL rich data so the UI looks perfect instantly
    await _localDataSource.saveBookingLocally(
      bookingId: responseModel.id,
      cancellationToken: responseModel.cancellationToken,
      propertyId: request.propertyId,
      propertyTitle: propertyTitle,
      price: price,
      location: location,
      billingCycle: billingCycle,
      universityName: universityName,
      thumbnailUrl: thumbnailUrl,
      roomNumber: roomNumber,
    );
    return responseModel.toEntity();
  }

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

  @override
  Future<List<SavedBooking>> getMyBookings(bool isAuthenticated) async {
    final localModels = await _localDataSource.getLocalBookings();
    return localModels.map((m) => m.toEntity()).toList();
  }

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

  @override
  Future<void> syncFromServer() async {
    try {
      await syncGuestData();
      final remoteBookings = await _remoteDataSource.getMyBookings();
      final remoteAsLocal = remoteBookings.map((r) {
        return LocalBookingModel(
          id: r.id,
          cancellationToken: '',
          propertyId: r.propertyId,
          propertyTitle: r.propertyTitle,
          price: r.price,
          location: r.location,
          billingCycle: r.billingCycle,
          universityName: r.universityName,
          thumbnailUrl: r.thumbnailUrl,
          roomNumber: r.roomNumber,
          bookedAt: r.createdAt,
          isCancelled: r.status == 'CANCELLED' || r.status == 'COMPLETED',
        );
      }).toList();
      await _localDataSource.upsertFromRemote(remoteAsLocal);
    } catch (_) {}
  }
}
