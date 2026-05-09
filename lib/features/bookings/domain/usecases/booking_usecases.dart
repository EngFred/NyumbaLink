import '../entities/booking_entities.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  const CreateBookingUseCase(this._repo);
  final BookingRepository _repo;

  Future<BookingResponse> call(
    BookingRequest request,
    String propertyTitle,
    String? roomNumber,
  ) {
    return _repo.createBooking(request, propertyTitle, roomNumber);
  }
}

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repo);
  final BookingRepository _repo;

  // Added isAuthenticated parameter
  Future<void> call(
    String id,
    String token,
    bool isAuthenticated, {
    String? reason,
  }) {
    return _repo.cancelBooking(id, token, isAuthenticated, reason: reason);
  }
}

class GetMyBookingsUseCase {
  const GetMyBookingsUseCase(this._repo);
  final BookingRepository _repo;

  // Added isAuthenticated parameter
  Future<List<SavedBooking>> call(bool isAuthenticated) {
    return _repo.getMyBookings(isAuthenticated);
  }
}
