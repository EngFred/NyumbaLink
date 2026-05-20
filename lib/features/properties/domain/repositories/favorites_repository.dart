import '../entities/saved_property.dart';

abstract class FavoritesRepository {
  Future<List<SavedProperty>> getFavorites();
  Future<void> toggleFavorite(
    SavedProperty property, {
    required bool isAuthenticated,
  });
  Future<void> syncFavorites();
}
