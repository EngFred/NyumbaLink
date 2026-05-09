import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
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
}
