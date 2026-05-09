import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking_models.dart';

final bookingsLocalDataSourceProvider = Provider<BookingsLocalDataSource>((
  ref,
) {
  return BookingsLocalDataSource();
});

class BookingsLocalDataSource {
  static const _savedBookingsKey = 'nyumbalink_saved_bookings';

  Future<void> saveBookingLocally({
    required String bookingId,
    required String cancellationToken,
    required String propertyTitle,
    String? roomNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getStringList(_savedBookingsKey) ?? [];

    final newEntry = LocalBookingModel(
      id: bookingId,
      cancellationToken: cancellationToken,
      propertyTitle: propertyTitle,
      roomNumber: roomNumber,
      bookedAt: DateTime.now().toIso8601String(),
    );

    existingData.add(jsonEncode(newEntry.toJson()));
    await prefs.setStringList(_savedBookingsKey, existingData);
  }

  Future<List<LocalBookingModel>> getLocalBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getStringList(_savedBookingsKey) ?? [];

    return existingData
        .map(
          (e) =>
              LocalBookingModel.fromJson(jsonDecode(e) as Map<String, dynamic>),
        )
        .toList()
        .reversed
        .toList();
  }

  Future<void> markAsCancelled(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getStringList(_savedBookingsKey) ?? [];

    final updatedData = existingData.map((e) {
      final model = LocalBookingModel.fromJson(
        jsonDecode(e) as Map<String, dynamic>,
      );
      if (model.id == bookingId) {
        return jsonEncode(
          LocalBookingModel(
            id: model.id,
            cancellationToken: model.cancellationToken,
            propertyTitle: model.propertyTitle,
            roomNumber: model.roomNumber,
            bookedAt: model.bookedAt,
            isCancelled: true,
          ).toJson(),
        );
      }
      return e;
    }).toList();

    await prefs.setStringList(_savedBookingsKey, updatedData);
  }
}
