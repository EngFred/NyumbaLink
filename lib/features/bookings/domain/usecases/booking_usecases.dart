import '../entities/booking_entities.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  const CreateBookingUseCase(this._repo);
  final BookingRepository _repo;

  Future<BookingResponse> call(
    BookingRequest request,
    String propertyTitle,
    double price,
    String location,
    String? thumbnailUrl,
    String? roomNumber,
    String? billingCycle,
    String? universityName,
  ) {
    return _repo.createBooking(
      request,
      propertyTitle,
      price,
      location,
      thumbnailUrl,
      roomNumber,
      billingCycle,
      universityName,
    );
  }
}

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repo);
  final BookingRepository _repo;

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

  Future<List<SavedBooking>> call(bool isAuthenticated) {
    return _repo.getMyBookings(isAuthenticated);
  }
}

/// Wipes locally cached bookings. Called when the user logs out so the
/// next guest session starts with a clean slate.
class ClearLocalBookingsUseCase {
  const ClearLocalBookingsUseCase(this._repo);
  final BookingRepository _repo;

  Future<void> call() => _repo.clearLocalBookings();
}
