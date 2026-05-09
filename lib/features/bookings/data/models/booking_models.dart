import 'package:intl/intl.dart';

import '../../domain/entities/booking_entities.dart';

// ── EXTENSION MAPPER ──
extension BookingRequestMapper on BookingRequest {
  Map<String, dynamic> toJson() {
    final fmt = DateFormat('yyyy-MM-dd');
    final map = <String, dynamic>{
      'renterName': renterName,
      'renterPhone': renterPhone,
      'propertyId': propertyId,
      'moveInDate': fmt.format(moveInDate),
    };

    if (renterEmail != null && renterEmail!.isNotEmpty) {
      map['renterEmail'] = renterEmail;
    }
    if (hostelRoomId != null) map['hostelRoomId'] = hostelRoomId;
    if (moveOutDate != null) map['moveOutDate'] = fmt.format(moveOutDate!);
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    if (userId != null && userId!.isNotEmpty) map['userId'] = userId;

    return map;
  }
}

// ── RESPONSE MODEL ──
class BookingResponseModel {
  const BookingResponseModel({
    required this.id,
    required this.status,
    required this.cancellationToken,
  });

  final String id;
  final String status;
  final String cancellationToken;

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      id: json['id'] as String,
      status: json['status'] as String,
      cancellationToken: json['cancellationToken'] as String,
    );
  }

  BookingResponse toEntity() {
    return BookingResponse(
      id: id,
      status: status,
      cancellationToken: cancellationToken,
    );
  }
}

// ── LOCAL (GUEST) BOOKING MODEL ──
class LocalBookingModel {
  const LocalBookingModel({
    required this.id,
    required this.cancellationToken,
    required this.propertyTitle,
    this.roomNumber,
    required this.bookedAt,
    this.isCancelled = false,
  });

  final String id;
  final String cancellationToken;
  final String propertyTitle;
  final String? roomNumber;
  final String bookedAt;
  final bool isCancelled;

  Map<String, dynamic> toJson() => {
    'id': id,
    'cancellationToken': cancellationToken,
    'propertyTitle': propertyTitle,
    'roomNumber': roomNumber,
    'bookedAt': bookedAt,
    'isCancelled': isCancelled,
  };

  factory LocalBookingModel.fromJson(
    Map<String, dynamic> json,
  ) => LocalBookingModel(
    id: json['id']?.toString() ?? '',
    cancellationToken: json['cancellationToken']?.toString() ?? '',
    propertyTitle: json['propertyTitle']?.toString() ?? '',
    roomNumber: json['roomNumber']?.toString(),
    bookedAt: json['bookedAt']?.toString() ?? DateTime.now().toIso8601String(),
    isCancelled: json['isCancelled'] == true || json['isCancelled'] == 'true',
  );

  SavedBooking toEntity() {
    return SavedBooking(
      id: id,
      cancellationToken: cancellationToken,
      propertyTitle: propertyTitle,
      roomNumber: roomNumber,
      bookedAt: bookedAt,
      isCancelled: isCancelled,
    );
  }
}

// ── REMOTE (AUTHENTICATED) BOOKING MODEL ──
class RemoteBookingModel {
  const RemoteBookingModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.propertyTitle,
    this.roomNumber,
  });

  final String id;
  final String status;
  final String createdAt;
  final String propertyTitle;
  final String? roomNumber;

  factory RemoteBookingModel.fromJson(Map<String, dynamic> json) {
    return RemoteBookingModel(
      id: json['id'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      propertyTitle: json['property']['title'] as String,
      roomNumber: json['hostelRoom']?['roomNumber'] as String?,
    );
  }

  SavedBooking toEntity() {
    return SavedBooking(
      id: id,
      cancellationToken: '', // Not needed for logged-in users
      propertyTitle: propertyTitle,
      roomNumber: roomNumber,
      bookedAt: createdAt,
      isCancelled: status == 'CANCELLED',
    );
  }
}
