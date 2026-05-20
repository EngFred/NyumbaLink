import '../entities/saved_property.dart';

abstract class FavoritesRepository {
  Future<List<SavedProperty>> getFavorites();

  /// Returns the server-confirmed new saved state.
  Future<bool> toggleFavorite(
    SavedProperty property, {
    required bool isAuthenticated,
  });

  Future<void> syncFavorites();
}
