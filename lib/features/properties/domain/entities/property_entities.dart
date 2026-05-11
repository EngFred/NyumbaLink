// ── District Entity ──
class District {
  const District({required this.id, required this.name});
  final String id;
  final String name;
}

// ── Contact Entity ──
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

// ── Property Image Entity ──
class PropertyImage {
  const PropertyImage({
    required this.id,
    required this.url,
    required this.publicId,
  });
  final String id;
  final String url;
  final String publicId;
}

// ── Main Property Entity ──
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
    required this.numberOfRooms, // Added
    this.billingCycle,
    this.totalRooms, // Added
    this.hotelCategory, // Added
    this.furnishingStatus,
    this.floor,
    this.totalFloors,
    this.amenities,
    this.lat,
    this.lng,
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
  final String? billingCycle;
  final int? totalRooms;
  final String? hotelCategory;
  final String? furnishingStatus;
  final int? floor;
  final int? totalFloors;
  final List<String>? amenities;
  final double? lat;
  final double? lng;

  bool get isAvailable => status == 'AVAILABLE';
  bool get isHostel => type == 'HOSTEL';
  bool get hasImages => images.isNotEmpty;
  String? get thumbnailUrl => images.isNotEmpty ? images.first.url : null;
}

// ── Hostel Room Entity ──
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

// ── Hostel Stats Entity ──
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
