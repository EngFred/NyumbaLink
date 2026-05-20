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
  static const _savedBookingsKey = 'rentora_saved_bookings';

  Future<void> upsertFromRemote(List<LocalBookingModel> remoteEntries) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_savedBookingsKey) ?? [];
    final map = <String, LocalBookingModel>{};

    for (final raw in existing) {
      try {
        final m = LocalBookingModel.fromJson(jsonDecode(raw));
        map[m.id] = m;
      } catch (_) {}
    }

    for (final entry in remoteEntries) {
      final existingEntry = map[entry.id];
      // CRITICAL FIX: Preserve the cancellation token if the remote doesn't have it
      final tokenToKeep = (existingEntry?.cancellationToken.isNotEmpty == true)
          ? existingEntry!.cancellationToken
          : entry.cancellationToken;

      map[entry.id] = LocalBookingModel(
        id: entry.id,
        cancellationToken: tokenToKeep,
        propertyId: entry.propertyId,
        propertyTitle: entry.propertyTitle,
        price: entry.price,
        location: entry.location,
        billingCycle: entry.billingCycle,
        universityName: entry.universityName,
        thumbnailUrl: entry.thumbnailUrl,
        roomNumber: entry.roomNumber,
        bookedAt: entry.bookedAt,
        isCancelled: entry.isCancelled,
      );
    }

    final merged = map.values.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_savedBookingsKey, merged);
  }

  Future<void> saveBookingLocally({
    required String bookingId,
    required String cancellationToken,
    required String propertyId,
    required String propertyTitle,
    required double price,
    required String location,
    String? billingCycle,
    String? universityName,
    String? thumbnailUrl,
    String? roomNumber,
    String? remoteStatus,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_savedBookingsKey) ?? [];

    final entry = LocalBookingModel(
      id: bookingId,
      cancellationToken: cancellationToken,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      price: price,
      location: location,
      billingCycle: billingCycle,
      universityName: universityName,
      thumbnailUrl: thumbnailUrl,
      roomNumber: roomNumber,
      bookedAt: DateTime.now().toIso8601String(),
      isCancelled: false,
    );

    existing.insert(0, jsonEncode(entry.toJson()));
    await prefs.setStringList(_savedBookingsKey, existing);
  }

  Future<List<LocalBookingModel>> getLocalBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_savedBookingsKey) ?? [];
    return data
        .map((e) {
          try {
            return LocalBookingModel.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<LocalBookingModel>()
        .toList();
  }

  Future<void> markAsCancelled(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_savedBookingsKey) ?? [];
    final updated = data.map((e) {
      final m = LocalBookingModel.fromJson(jsonDecode(e));
      if (m.id == bookingId) {
        return jsonEncode(
          LocalBookingModel(
            id: m.id,
            cancellationToken: m.cancellationToken,
            propertyId: m.propertyId,
            propertyTitle: m.propertyTitle,
            price: m.price,
            location: m.location,
            billingCycle: m.billingCycle,
            universityName: m.universityName,
            thumbnailUrl: m.thumbnailUrl,
            roomNumber: m.roomNumber,
            bookedAt: m.bookedAt,
            isCancelled: true,
          ).toJson(),
        );
      }
      return e;
    }).toList();
    await prefs.setStringList(_savedBookingsKey, updated);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedBookingsKey);
  }
}
