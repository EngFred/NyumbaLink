import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/booking_models.dart';

final bookingsRemoteDataSourceProvider = Provider<BookingsRemoteDataSource>((
  ref,
) {
  return BookingsRemoteDataSource(ref.watch(dioProvider));
});

class BookingsRemoteDataSource {
  const BookingsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<BookingResponseModel> createBooking(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/bookings',
        data: data,
      );
      return BookingResponseModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  // ── GUEST CANCELLATION ──
  Future<void> cancelBookingByRenter(
    String id,
    String token, {
    String? reason,
  }) async {
    try {
      await _dio.patch(
        '/bookings/$id/cancel-by-renter',
        data: {
          'cancellationToken': token,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  // ── AUTHENTICATED ROUTES ──

  Future<void> cancelMine(String id, {String? reason}) async {
    try {
      await _dio.patch(
        '/bookings/$id/cancel-mine',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<List<RemoteBookingModel>> getMyBookings() async {
    try {
      final res = await _dio.get<List<dynamic>>('/bookings/me');
      return res.data!.map((e) => RemoteBookingModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> syncBookings(List<Map<String, dynamic>> localBookings) async {
    if (localBookings.isEmpty) return;
    try {
      await _dio.post('/bookings/sync', data: {'bookings': localBookings});
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
