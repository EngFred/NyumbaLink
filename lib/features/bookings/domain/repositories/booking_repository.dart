import '../entities/booking_entities.dart';

abstract class BookingRepository {
  Future<BookingResponse> createBooking(
    BookingRequest request,
    String propertyTitle,
    String? roomNumber,
  );
  Future<void> cancelBooking(String id, String token, {String? reason});
  Future<List<SavedBooking>> getMyBookings();
}
