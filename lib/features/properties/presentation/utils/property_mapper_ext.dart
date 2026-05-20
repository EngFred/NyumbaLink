import '../../domain/entities/property_entities.dart';
import '../../domain/entities/saved_property.dart';

extension PropertyToSavedX on Property {
  SavedProperty toSavedProperty() {
    return SavedProperty(
      id: id,
      title: title,
      price: price,
      location: locationDisplay,
      type: type,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
