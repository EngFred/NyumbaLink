import '../../domain/entities/complaint_entities.dart';

extension ComplaintRequestMapper on ComplaintRequest {
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'submitterName': submitterName,
      'submitterPhone': submitterPhone,
      'category': category,
      'description': description,
    };

    if (submitterEmail != null && submitterEmail!.isNotEmpty) {
      map['submitterEmail'] = submitterEmail;
    }
    if (propertyId != null && propertyId!.isNotEmpty) {
      map['propertyId'] = propertyId;
    }

    return map;
  }
}
