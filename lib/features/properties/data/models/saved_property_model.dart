import '../../domain/entities/saved_property.dart';

class SavedPropertyModel extends SavedProperty {
  const SavedPropertyModel({
    required super.id,
    required super.title,
    required super.price,
    required super.location,
    required super.type,
    super.thumbnailUrl,
  });

  factory SavedPropertyModel.fromJson(Map<String, dynamic> json) {
    final location =
        json['location'] as String? ??
        (json['area'] as Map<String, dynamic>?)?['name'] as String? ??
        'Unknown';

    return SavedPropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: double.parse(json['price'].toString()),
      location: location,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'location': location,
    'thumbnailUrl': thumbnailUrl,
    'type': type,
  };

  factory SavedPropertyModel.fromEntity(SavedProperty entity) =>
      SavedPropertyModel(
        id: entity.id,
        title: entity.title,
        price: entity.price,
        location: entity.location,
        thumbnailUrl: entity.thumbnailUrl,
        type: entity.type,
      );
}
