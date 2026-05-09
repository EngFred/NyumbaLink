// ── District ──────────────────────────────────────────────────────────────────

class DistrictModel {
  const DistrictModel({required this.id, required this.name});

  final String id;
  final String name;

  factory DistrictModel.fromJson(Map<String, dynamic> j) =>
      DistrictModel(id: j['id'] as String, name: j['name'] as String);
}

// ── Contact ───────────────────────────────────────────────────────────────────

class ContactModel {
  const ContactModel({
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

  factory ContactModel.fromJson(Map<String, dynamic> j) => ContactModel(
    id: j['id'] as String,
    name: j['name'] as String,
    phone: j['phone'] as String,
    role: j['role'] as String,
    whatsapp: j['whatsapp'] as String?,
    email: j['email'] as String?,
  );
}

// ── Property Image ────────────────────────────────────────────────────────────

class PropertyImageModel {
  const PropertyImageModel({
    required this.id,
    required this.url,
    required this.publicId,
  });

  final String id;
  final String url;
  final String publicId;

  factory PropertyImageModel.fromJson(Map<String, dynamic> j) =>
      PropertyImageModel(
        id: j['id'] as String,
        url: j['url'] as String,
        publicId: j['publicId'] as String,
      );
}

// ── Property ──────────────────────────────────────────────────────────────────

class PropertyModel {
  const PropertyModel({
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
    this.billingCycle,
    this.bedrooms,
    this.bathrooms,
    this.furnishingStatus,
    this.floor,
    this.totalFloors,
    this.amenities,
    this.lat,
    this.lng,
    this.residentialSubtype,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final String area;
  final String status;
  final DistrictModel district;
  final ContactModel contact;
  final List<PropertyImageModel> images;
  final int viewCount;
  final int enquiryCount;
  final DateTime createdAt;

  final String? billingCycle;
  final int? bedrooms;
  final int? bathrooms;
  final String? furnishingStatus;
  final int? floor;
  final int? totalFloors;
  final List<String>? amenities;
  final double? lat;
  final double? lng;
  final String? residentialSubtype;

  bool get isAvailable => status == 'AVAILABLE';
  bool get isHostel => type == 'HOSTEL';
  bool get hasImages => images.isNotEmpty;

  String? get thumbnailUrl => images.isNotEmpty ? images.first.url : null;

  factory PropertyModel.fromJson(Map<String, dynamic> j) {
    return PropertyModel(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String,
      type: j['type'] as String,
      // Safely parse decimals (Postgres sends them as Strings to avoid float precision loss)
      price: double.parse(j['price'].toString()),
      area: j['area'] as String,
      status: j['status'] as String,
      district: DistrictModel.fromJson(j['district'] as Map<String, dynamic>),
      contact: ContactModel.fromJson(j['contact'] as Map<String, dynamic>),
      images: (j['images'] as List? ?? [])
          .map((e) => PropertyImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Safely parse integers
      viewCount: int.tryParse(j['viewCount']?.toString() ?? '0') ?? 0,
      enquiryCount: int.tryParse(j['enquiryCount']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.parse(j['createdAt'] as String),
      billingCycle: j['billingCycle'] as String?,
      bedrooms: j['bedrooms'] != null
          ? int.tryParse(j['bedrooms'].toString())
          : null,
      bathrooms: j['bathrooms'] != null
          ? int.tryParse(j['bathrooms'].toString())
          : null,
      furnishingStatus: j['furnishingStatus'] as String?,
      floor: j['floor'] != null ? int.tryParse(j['floor'].toString()) : null,
      totalFloors: j['totalFloors'] != null
          ? int.tryParse(j['totalFloors'].toString())
          : null,
      amenities: (j['amenities'] as List?)?.cast<String>(),
      // Backend uses 'latitude' and 'longitude', safely parsed
      lat: j['latitude'] != null
          ? double.tryParse(j['latitude'].toString())
          : null,
      lng: j['longitude'] != null
          ? double.tryParse(j['longitude'].toString())
          : null,
      residentialSubtype: j['residentialSubtype'] as String?,
    );
  }
}

// ── Hostel Room ───────────────────────────────────────────────────────────────

class HostelRoomModel {
  const HostelRoomModel({
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

  factory HostelRoomModel.fromJson(Map<String, dynamic> j) => HostelRoomModel(
    id: j['id'] as String,
    roomNumber: j['roomNumber'] as String,
    type: j['type'] as String,
    // Safely parse decimal price
    price: double.parse(j['price'].toString()),
    billingCycle: j['billingCycle'] as String,
    status: j['status'] as String,
    floor: j['floor'] != null ? int.tryParse(j['floor'].toString()) : null,
    description: j['description'] as String?,
    amenities: (j['amenities'] as List?)?.cast<String>(),
  );
}

// ── Hostel Stats ──────────────────────────────────────────────────────────────

class HostelStatsModel {
  const HostelStatsModel({
    required this.total,
    required this.available,
    required this.occupied,
    required this.reserved,
    required this.maintenance,
    required this.occupancyRate,
  });

  final int total;
  final int available;
  final int occupied;
  final int reserved;
  final int maintenance;
  final double occupancyRate;

  factory HostelStatsModel.fromJson(Map<String, dynamic> j) => HostelStatsModel(
    total: int.tryParse(j['total'].toString()) ?? 0,
    available: int.tryParse(j['available'].toString()) ?? 0,
    occupied: int.tryParse(j['occupied'].toString()) ?? 0,
    reserved: int.tryParse(j['reserved'].toString()) ?? 0,
    maintenance: int.tryParse(j['maintenance'].toString()) ?? 0,
    occupancyRate: double.tryParse(j['occupancyRate'].toString()) ?? 0.0,
  );
}
