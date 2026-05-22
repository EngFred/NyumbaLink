import '../entities/saved_property.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);
  final FavoritesRepository _repository;

  Future<List<SavedProperty>> call() => _repository.getFavorites();
}

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);
  final FavoritesRepository _repository;

  /// Returns the server-confirmed new saved state.
  Future<bool> call(SavedProperty property, {required bool isAuthenticated}) =>
      _repository.toggleFavorite(property, isAuthenticated: isAuthenticated);
}

class SyncFavoritesUseCase {
  const SyncFavoritesUseCase(this._repository);
  final FavoritesRepository _repository;

  Future<void> call() => _repository.syncFavorites();
}

/// Wipes locally cached favourites. Called when the user logs out so the
/// next guest session starts with a clean slate.
class ClearLocalFavoritesUseCase {
  const ClearLocalFavoritesUseCase(this._repository);
  final FavoritesRepository _repository;

  Future<void> call() => _repository.clearLocalFavorites();
}
