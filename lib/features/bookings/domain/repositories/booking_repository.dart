import '../entities/booking_entities.dart';

abstract class BookingRepository {
  Future<BookingResponse> createBooking(
    BookingRequest request,
    String propertyTitle,
    double price,
    String location,
    String? thumbnailUrl,
    String? roomNumber,
    String? billingCycle,
    String? universityName,
  );

  Future<void> cancelBooking(
    String id,
    String token,
    bool isAuthenticated, {
    String? reason,
  });

  Future<List<SavedBooking>> getMyBookings(bool isAuthenticated);
  Future<void> syncGuestData();
  Future<void> syncFromServer();

  /// Wipes all locally cached bookings (called on logout).
  Future<void> clearLocalBookings();
}
