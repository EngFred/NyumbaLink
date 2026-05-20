import 'package:intl/intl.dart';
import '../../domain/entities/booking_entities.dart';

// ── EXTENSION MAPPER ──────────────────────────────────────────────────────────
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

// ── RESPONSE MODEL ────────────────────────────────────────────────────────────
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
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      cancellationToken: json['cancellationToken']?.toString() ?? '',
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

// ── LOCAL (GUEST) BOOKING MODEL ───────────────────────────────────────────────
class LocalBookingModel {
  const LocalBookingModel({
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
    this.isCancelled = false,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'cancellationToken': cancellationToken,
    'propertyId': propertyId,
    'propertyTitle': propertyTitle,
    'price': price,
    'location': location,
    'billingCycle': billingCycle,
    'universityName': universityName,
    'thumbnailUrl': thumbnailUrl,
    'roomNumber': roomNumber,
    'bookedAt': bookedAt,
    'isCancelled': isCancelled,
  };

  factory LocalBookingModel.fromJson(
    Map<String, dynamic> json,
  ) => LocalBookingModel(
    id: json['id']?.toString() ?? '',
    cancellationToken: json['cancellationToken']?.toString() ?? '',
    propertyId: json['propertyId']?.toString() ?? '',
    propertyTitle: json['propertyTitle']?.toString() ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    location: json['location']?.toString() ?? '',
    billingCycle: json['billingCycle']?.toString(),
    universityName: json['universityName']?.toString(),
    thumbnailUrl: json['thumbnailUrl']?.toString(),
    roomNumber: json['roomNumber']?.toString(),
    bookedAt: json['bookedAt']?.toString() ?? DateTime.now().toIso8601String(),
    isCancelled: json['isCancelled'] == true || json['isCancelled'] == 'true',
  );

  SavedBooking toEntity() {
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
}

// ── REMOTE (AUTHENTICATED) BOOKING MODEL ──────────────────────────────────────
class RemoteBookingModel {
  const RemoteBookingModel({
    required this.id,
    required this.status,
    required this.isCancelled,
    required this.createdAt,
    required this.propertyId,
    required this.propertyTitle,
    required this.price,
    required this.location,
    this.billingCycle,
    this.universityName,
    this.thumbnailUrl,
    this.roomNumber,
  });

  final String id;
  final String status;
  final bool isCancelled;
  final String createdAt;
  final String propertyId;
  final String propertyTitle;
  final double price;
  final String location;
  final String? billingCycle;
  final String? universityName;
  final String? thumbnailUrl;
  final String? roomNumber;

  factory RemoteBookingModel.fromJson(Map<String, dynamic> json) {
    return RemoteBookingModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isCancelled: json['isCancelled'] == true,
      createdAt:
          json['bookedAt']?.toString() ?? DateTime.now().toIso8601String(),
      propertyId: json['propertyId']?.toString() ?? '',
      propertyTitle: json['propertyTitle']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location']?.toString() ?? '',
      billingCycle: json['billingCycle']?.toString(),
      universityName: json['universityName']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      roomNumber: json['roomNumber']?.toString(),
    );
  }

  SavedBooking toEntity() {
    return SavedBooking(
      id: id,
      // Raw token is never returned by the server after initial creation.
      // It is preserved from local storage by BookingsLocalDataSource.upsertFromRemote.
      cancellationToken: '',
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      price: price,
      location: location,
      billingCycle: billingCycle,
      universityName: universityName,
      thumbnailUrl: thumbnailUrl,
      roomNumber: roomNumber,
      bookedAt: createdAt,
      isCancelled: isCancelled,
    );
  }
}
