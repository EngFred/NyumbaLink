import '../../../universities/domain/entities/university.dart';
import '../../../../../core/utils/string_helpers.dart';

class District {
  const District({required this.id, required this.name});
  final String id;
  final String name;

  String get displayName => name.toSentenceCase();
}

class Area {
  const Area({required this.id, required this.name});
  final String id;
  final String name;

  String get displayName => name.toSentenceCase();
}

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

class PropertyVideo {
  const PropertyVideo({
    required this.id,
    required this.url,
    required this.publicId,
    required this.videoType,
  });
  final String id;
  final String url;
  final String publicId;
  final String videoType; // 'INTERIOR' | 'EXTERIOR' | 'NEIGHBORHOOD'
}

class Property {
  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.status,
    required this.district,
    required this.contact,
    required this.images,
    required this.viewCount,
    required this.enquiryCount,
    required this.createdAt,
    required this.numberOfRooms,
    required this.parkingAvailable,
    this.area,
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
    this.university,
    this.listingPurpose = 'RENT',
    this.videos = const [],
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final Area? area;
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
  final University? university;
  final String listingPurpose;
  final List<PropertyVideo> videos;

  bool get isAvailable => status == 'AVAILABLE';
  bool get isHostel => type == 'HOSTEL';
  bool get hasImages => images.isNotEmpty;
  bool get isForSale => listingPurpose == 'SALE';
  bool get isForRent => listingPurpose == 'RENT';

  String get displayTitle => title.toSentenceCase();
  String get displayDescription => description.toSentenceCase();

  String get locationDisplay {
    final areaName = area?.displayName.trim();
    if (areaName != null && areaName.isNotEmpty) {
      return '$areaName, ${district.displayName}';
    }
    return district.displayName;
  }

  String? get thumbnailUrl {
    if (images.isNotEmpty) {
      final primary = images.where((i) => i.isPrimary).firstOrNull;
      return (primary ?? images.first).url;
    }
    if (videos.isNotEmpty) {
      return _videoThumbnail(videos.first.url);
    }
    return null;
  }

  static String? _videoThumbnail(String url) {
    if (!url.contains('cloudinary.com')) return null;
    return url
        .replaceFirst(
          '/video/upload/',
          '/video/upload/so_auto,w_600,q_auto,f_jpg/',
        )
        .replaceFirst(RegExp(r'\.(mp4|mov|webm)(\?.*)?$'), '.jpg');
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    double? price,
    Area? area,
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
    String? listingPurpose,
    List<PropertyVideo>? videos,
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
      listingPurpose: listingPurpose ?? this.listingPurpose,
      videos: videos ?? this.videos,
    );
  }
}

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
