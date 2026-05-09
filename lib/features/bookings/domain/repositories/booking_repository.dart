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
}
