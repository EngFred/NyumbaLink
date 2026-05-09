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

  @override
  Future<void> cancelBooking(String id, String token, {String? reason}) async {
    await _remoteDataSource.cancelBookingByRenter(id, token, reason: reason);
    await _localDataSource.markAsCancelled(id);
  }

  @override
  Future<List<SavedBooking>> getMyBookings() async {
    final localModels = await _localDataSource.getLocalBookings();
    return localModels.map((m) => m.toEntity()).toList();
  }
}
