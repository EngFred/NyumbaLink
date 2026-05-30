import '../../../universities/data/models/university_model.dart';
import '../../../universities/domain/entities/university.dart';
import '../../domain/entities/property_entities.dart';
import '../models/property_models.dart';

extension DistrictModelX on DistrictModel {
  District toEntity() => District(id: id, name: name);
}

extension AreaModelX on AreaModel {
  Area toEntity() => Area(id: id, name: name);
}

extension ContactModelX on ContactModel {
  Contact toEntity() => Contact(
    id: id,
    name: name,
    phone: phone,
    role: role,
    whatsapp: whatsapp,
    email: email,
  );
}

extension PropertyImageModelX on PropertyImageModel {
  PropertyImage toEntity() =>
      PropertyImage(id: id, url: url, publicId: publicId, isPrimary: isPrimary);
}

extension PropertyVideoModelX on PropertyVideoModel {
  PropertyVideo toEntity() =>
      PropertyVideo(id: id, url: url, publicId: publicId, videoType: videoType);
}

extension UniversityModelX on UniversityModel {
  University toEntity() =>
      University(id: id, name: name, shortName: shortName, location: location);
}

extension PropertyModelX on PropertyModel {
  Property toEntity() => Property(
    id: id,
    title: title,
    description: description,
    type: type,
    price: price,
    area: area?.toEntity(),
    status: status,
    district: district.toEntity(),
    contact: contact.toEntity(),
    images: images.map((e) => e.toEntity()).toList(),
    viewCount: viewCount,
    enquiryCount: enquiryCount,
    createdAt: createdAt,
    numberOfRooms: numberOfRooms,
    parkingAvailable: parkingAvailable,
    isFeatured: isFeatured,
    featuredUntil: featuredUntil,
    billingCycle: billingCycle,
    totalRooms: totalRooms,
    hotelCategory: hotelCategory,
    furnishingStatus: furnishingStatus,
    floor: floor,
    address: address,
    securityDeposit: securityDeposit,
    availableFrom: availableFrom,
    amenities: amenities,
    lat: lat,
    lng: lng,
    university: university?.toEntity(),
    listingPurpose: listingPurpose,
    videos: videos.map((e) => e.toEntity()).toList(),
  );
}

extension HostelRoomModelX on HostelRoomModel {
  HostelRoom toEntity() => HostelRoom(
    id: id,
    roomNumber: roomNumber,
    type: type,
    price: price,
    billingCycle: billingCycle,
    status: status,
    floor: floor,
    description: description,
    amenities: amenities,
  );
}

extension HostelStatsModelX on HostelStatsModel {
  HostelStats toEntity() => HostelStats(
    total: total,
    available: available,
    occupied: occupied,
    reserved: reserved,
    maintenance: maintenance,
    occupancyRate: occupancyRate,
    capacityCap: capacityCap,
    slotsRemaining: slotsRemaining,
  );
}
