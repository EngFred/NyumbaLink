import '../../domain/entities/hostel_alert.dart';

class HostelAlertModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final DateTime createdAt;

  const HostelAlertModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.createdAt,
  });

  factory HostelAlertModel.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    return HostelAlertModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      propertyTitle: property['title'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  HostelAlert toEntity() => HostelAlert(
    id: id,
    propertyId: propertyId,
    propertyTitle: propertyTitle,
    createdAt: createdAt,
  );
}
