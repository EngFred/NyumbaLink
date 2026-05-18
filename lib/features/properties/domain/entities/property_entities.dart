// ── District Entity ──────────────────────────────────────────────────────────
import '../../../universities/domain/entities/university.dart';

class District {
  const District({required this.id, required this.name});
  final String id;
  final String name;
}

// ── Contact Entity ────────────────────────────────────────────────────────────
class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.whatsapp,
    this.email,
  });
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? whatsapp;
  final String? email;
}

// ── Property Image Entity ─────────────────────────────────────────────────────
class PropertyImage {
  const PropertyImage({
    required this.id,
    required this.url,
    required this.publicId,
    required this.isPrimary,
  });
  final String id;
  final String url;
  final String publicId;
  final bool isPrimary;
}

// ── Main Property Entity ──────────────────────────────────────────────────────
class Property {
  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.area,
    required this.status,
    required this.district,
    required this.contact,
    required this.images,
    required this.viewCount,
    required this.enquiryCount,
    required this.createdAt,
    required this.numberOfRooms,
    required this.parkingAvailable,
    this.isFeatured = false,
    this.featuredUntil,
    this.billingCycle,
    this.totalRooms,
    this.hotelCategory,
    this.furnishingStatus,
    this.floor,
    this.address,
    this.securityDeposit,
    this.availableFrom,
    this.amenities,
    this.lat,
    this.lng,
    this.university, // NEW FIX
  });
  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final String area;
  final String status;
  final District district;
  final Contact contact;
  final List<PropertyImage> images;
  final int viewCount;
  final int enquiryCount;
  final DateTime createdAt;
  final int numberOfRooms;
  final bool parkingAvailable;

  final bool isFeatured;
  final String? featuredUntil;
  final String? billingCycle;
  final int? totalRooms;
  final String? hotelCategory;
  final String? furnishingStatus;
  final int? floor;
  final String? address;
  final double? securityDeposit;
  final DateTime? availableFrom;
  final List<String>? amenities;
  final double? lat;
  final double? lng;
  final University? university; // NEW FIX

  bool get isAvailable => status == 'AVAILABLE';
  bool get isHostel => type == 'HOSTEL';
  bool get hasImages => images.isNotEmpty;

  String? get thumbnailUrl {
    if (images.isEmpty) return null;
    final primary = images.where((i) => i.isPrimary).firstOrNull;
    return (primary ?? images.first).url;
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? price,
    String? area,
    String? status,
    District? district,
    Contact? contact,
    List<PropertyImage>? images,
    int? viewCount,
    int? enquiryCount,
    DateTime? createdAt,
    int? numberOfRooms,
    bool? parkingAvailable,
    bool? isFeatured,
    String? featuredUntil,
    String? billingCycle,
    int? totalRooms,
    String? hotelCategory,
    String? furnishingStatus,
    int? floor,
    String? address,
    double? securityDeposit,
    DateTime? availableFrom,
    List<String>? amenities,
    double? lat,
    double? lng,
    University? university,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      area: area ?? this.area,
      status: status ?? this.status,
      district: district ?? this.district,
      contact: contact ?? this.contact,
      images: images ?? this.images,
      viewCount: viewCount ?? this.viewCount,
      enquiryCount: enquiryCount ?? this.enquiryCount,
      createdAt: createdAt ?? this.createdAt,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      billingCycle: billingCycle ?? this.billingCycle,
      totalRooms: totalRooms ?? this.totalRooms,
      hotelCategory: hotelCategory ?? this.hotelCategory,
      furnishingStatus: furnishingStatus ?? this.furnishingStatus,
      floor: floor ?? this.floor,
      address: address ?? this.address,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      availableFrom: availableFrom ?? this.availableFrom,
      amenities: amenities ?? this.amenities,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      university: university ?? this.university,
    );
  }
}

// ── Hostel Room Entity ────────────────────────────────────────────────────────
class HostelRoom {
  const HostelRoom({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.price,
    required this.billingCycle,
    required this.status,
    this.floor,
    this.description,
    this.amenities,
  });
  final String id;
  final String roomNumber;
  final String type;
  final double price;
  final String billingCycle;
  final String status;
  final int? floor;
  final String? description;
  final List<String>? amenities;
  bool get isAvailable => status == 'AVAILABLE';
}

// ── Hostel Stats Entity ───────────────────────────────────────────────────────
class HostelStats {
  const HostelStats({
    required this.total,
    required this.available,
    required this.occupied,
    required this.reserved,
    required this.maintenance,
    required this.occupancyRate,
    this.capacityCap,
    this.slotsRemaining,
  });
  final int total;
  final int available;
  final int occupied;
  final int reserved;
  final int maintenance;
  final double occupancyRate;
  final int? capacityCap;
  final int? slotsRemaining;
}
