import '../../domain/entities/area_alert.dart';

class AreaAlertModel {
  final String id;
  final String areaId;
  final String areaName;
  final String districtName;
  final DateTime createdAt;

  const AreaAlertModel({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.districtName,
    required this.createdAt,
  });

  factory AreaAlertModel.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>? ?? {};
    final district = area['district'] as Map<String, dynamic>? ?? {};

    return AreaAlertModel(
      id: json['id'] as String,
      areaId: json['areaId'] as String,
      areaName: area['name'] as String? ?? '',
      districtName: district['name'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  AreaAlert toEntity() => AreaAlert(
    id: id,
    areaId: areaId,
    areaName: areaName,
    districtName: districtName,
    createdAt: createdAt,
  );
}
