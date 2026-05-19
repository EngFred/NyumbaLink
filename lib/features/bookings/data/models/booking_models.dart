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

// ── LOCAL (GUEST) BOOKING MODEL ──
class LocalBookingModel {
  const LocalBookingModel({
    required this.id,
    required this.cancellationToken,
    required this.propertyId,
    required this.propertyTitle,
    required this.price,
    required this.location,
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
      thumbnailUrl: thumbnailUrl,
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
    required this.propertyId,
    required this.propertyTitle,
    required this.price,
    required this.location,
    this.thumbnailUrl,
    this.roomNumber,
  });

  final String id;
  final String status;
  final String createdAt;
  final String propertyId;
  final String propertyTitle;
  final double price;
  final String location;
  final String? thumbnailUrl;
  final String? roomNumber;

  factory RemoteBookingModel.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    final images = property['images'] as List<dynamic>? ?? [];
    final thumbnail = images.isNotEmpty
        ? images.first['url']?.toString()
        : null;

    final area =
        (property['area'] as Map<String, dynamic>?)?['name']?.toString() ?? '';
    final district = property['district']?['name']?.toString() ?? '';
    final loc = district.isNotEmpty ? '$area, $district' : area;

    // Bulletproof price parsing (TypeORM sends decimals as strings)
    final priceVal = property['price'];
    double parsedPrice = 0.0;
    if (priceVal is num) {
      parsedPrice = priceVal.toDouble();
    } else if (priceVal is String) {
      parsedPrice = double.tryParse(priceVal) ?? 0.0;
    }

    return RemoteBookingModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      propertyId: property['id']?.toString() ?? '',
      propertyTitle: property['title']?.toString() ?? 'Unknown Property',
      price: parsedPrice,
      location: loc,
      thumbnailUrl: thumbnail,
      roomNumber: json['hostelRoom']?['roomNumber']?.toString(),
    );
  }

  SavedBooking toEntity() {
    return SavedBooking(
      id: id,
      cancellationToken: '', // Merged securely in LocalDataSource
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      price: price,
      location: location,
      thumbnailUrl: thumbnailUrl,
      roomNumber: roomNumber,
      bookedAt: createdAt,
      isCancelled: status == 'CANCELLED' || status == 'COMPLETED',
    );
  }
}
