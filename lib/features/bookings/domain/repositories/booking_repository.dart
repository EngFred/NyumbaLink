import '../entities/booking_entities.dart';

abstract class BookingRepository {
  Future<BookingResponse> createBooking(
    BookingRequest request,
    String propertyTitle,
    String? roomNumber,
  );
  Future<void> cancelBooking(
    String id,
    String token,
    bool isAuthenticated, {
    String? reason,
  });
  Future<List<SavedBooking>> getMyBookings(bool isAuthenticated);
  Future<void> syncGuestData();

  /// Pulls server booking statuses and merges into local storage.
  /// Ensures CONFIRMED / COMPLETED / CANCELLED states set by admin
  /// are reflected in the UI without requiring a logout/login cycle.
  Future<void> syncFromServer();
}
