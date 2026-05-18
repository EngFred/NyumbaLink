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

  /// Upserts a list of bookings into local storage (used after remote sync).
  /// Preserves existing local entries that aren't in the remote list.
  Future<void> upsertFromRemote(List<LocalBookingModel> remoteEntries) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_savedBookingsKey) ?? [];

    // Build a map of existing entries keyed by id
    final map = <String, LocalBookingModel>{};
    for (final raw in existing) {
      try {
        final m = LocalBookingModel.fromJson(jsonDecode(raw));
        map[m.id] = m;
      } catch (_) {}
    }

    // Overwrite/insert with remote data (remote is authoritative for status)
    for (final entry in remoteEntries) {
      map[entry.id] = entry;
    }

    final merged = map.values.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_savedBookingsKey, merged);
  }

  Future<void> saveBookingLocally({
    required String bookingId,
    required String cancellationToken,
    required String propertyTitle,
    double price = 0.0, // Default for backwards compatibility
    String location = '',
    String? thumbnailUrl,
    String? roomNumber,
    String? remoteStatus,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_savedBookingsKey) ?? [];

    final entry = LocalBookingModel(
      id: bookingId,
      cancellationToken: cancellationToken,
      propertyTitle: propertyTitle,
      price: price,
      location: location,
      thumbnailUrl: thumbnailUrl,
      roomNumber: roomNumber,
      bookedAt: DateTime.now().toIso8601String(),
      isCancelled: false,
    );

    existing.insert(0, jsonEncode(entry.toJson())); // newest first
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
            propertyTitle: m.propertyTitle,
            price: m.price,
            location: m.location,
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
