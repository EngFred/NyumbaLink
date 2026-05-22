import '../../domain/entities/area_alert.dart';

class AreaAlertModel extends AreaAlert {
  const AreaAlertModel({
    required super.areaId,
    required super.areaName,
    required super.districtName,
    required super.createdAt,
    super.propertyTypes,
  });

  factory AreaAlertModel.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>;
    final district = area['district'] as Map<String, dynamic>;

    // propertyTypes arrives as a comma-separated string from TypeORM
    // simple-array, or null if the user subscribed to all types.
    final rawTypes = json['propertyTypes'];
    List<String>? types;
    if (rawTypes is String && rawTypes.isNotEmpty) {
      types = rawTypes.split(',').map((t) => t.trim()).toList();
    } else if (rawTypes is List) {
      types = rawTypes.cast<String>();
    }

    return AreaAlertModel(
      areaId: area['id'] as String,
      areaName: area['name'] as String,
      districtName: district['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      propertyTypes: types,
    );
  }

  AreaAlert toEntity() => AreaAlert(
    areaId: areaId,
    areaName: areaName,
    districtName: districtName,
    createdAt: createdAt,
    propertyTypes: propertyTypes,
  );
}
