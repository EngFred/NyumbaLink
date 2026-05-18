class BookingRequest {
  const BookingRequest({
    required this.renterName,
    required this.renterPhone,
    this.renterEmail,
    required this.propertyId,
    this.hostelRoomId,
    required this.moveInDate,
    this.moveOutDate,
    this.notes,
    this.userId,
  });

  final String renterName;
  final String renterPhone;
  final String? renterEmail;
  final String propertyId;
  final String? hostelRoomId;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String? notes;
  final String? userId;
}

class BookingResponse {
  const BookingResponse({
    required this.id,
    required this.status,
    required this.cancellationToken,
  });

  final String id;
  final String status;
  final String cancellationToken;
}

class SavedBooking {
  const SavedBooking({
    required this.id,
    required this.cancellationToken,
    required this.propertyTitle,
    required this.price,
    required this.location,
    this.thumbnailUrl,
    this.roomNumber,
    required this.bookedAt,
    required this.isCancelled,
  });

  final String id;
  final String cancellationToken;
  final String propertyTitle;
  final double price;
  final String location;
  final String? thumbnailUrl;
  final String? roomNumber;
  final String bookedAt;
  final bool isCancelled;
}
