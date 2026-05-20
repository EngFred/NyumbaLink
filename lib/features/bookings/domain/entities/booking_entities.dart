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
    required this.propertyId,
    required this.propertyTitle,
    required this.price,
    required this.location,
    this.billingCycle,
    this.universityName,
    this.thumbnailUrl,
    this.roomNumber,
    required this.bookedAt,
    required this.isCancelled,
  });

  final String id;
  final String cancellationToken;
  final String propertyId;
  final String propertyTitle;
  final double price;
  final String location;
  final String? billingCycle;
  final String? universityName;
  final String? thumbnailUrl;
  final String? roomNumber;
  final String bookedAt;
  final bool isCancelled;

  /// Factory used when creating SavedBooking manually (e.g. after successful booking)
  /// Now consistent with backend logic
  factory SavedBooking.fromDomain({
    required String id,
    required String cancellationToken,
    required String propertyId,
    required String propertyTitle,
    required double price,
    required String? areaName,
    required String districtName,
    String? billingCycle,
    String? universityName,
    String? thumbnailUrl,
    String? roomNumber,
    required String bookedAt,
    bool isCancelled = false,
  }) {
    final location = _buildLocation(areaName, districtName);
    return SavedBooking(
      id: id,
      cancellationToken: cancellationToken,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      price: price,
      location: location,
      billingCycle: billingCycle,
      universityName: universityName,
      thumbnailUrl: thumbnailUrl,
      roomNumber: roomNumber,
      bookedAt: bookedAt,
      isCancelled: isCancelled,
    );
  }

  static String _buildLocation(String? areaName, String districtName) {
    final cleanArea = areaName?.trim();
    if (cleanArea != null && cleanArea.isNotEmpty) {
      return '$cleanArea, $districtName';
    }
    return districtName;
  }
}
