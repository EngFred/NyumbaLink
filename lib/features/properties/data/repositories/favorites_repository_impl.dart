import 'package:flutter/foundation.dart';
import '../../domain/entities/saved_property.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../models/saved_property_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._localDataSource, this._remoteDataSource);
  final FavoritesLocalDataSource _localDataSource;
  final FavoritesRemoteDataSource _remoteDataSource;

  @override
  Future<List<SavedProperty>> getFavorites() async {
    return _localDataSource.getSavedProperties();
  }

  @override
  Future<void> toggleFavorite(
    SavedProperty property, {
    required bool isAuthenticated,
  }) async {
    final localList = await _localDataSource.getSavedProperties();
    final index = localList.indexWhere((p) => p.id == property.id);

    if (index >= 0) {
      localList.removeAt(index);
    } else {
      localList.insert(0, SavedPropertyModel.fromEntity(property));
    }

    await _localDataSource.saveProperties(localList);

    if (isAuthenticated) {
      try {
        await _remoteDataSource.toggleFavorite(property.id);
      } catch (e) {
        debugPrint('[FavoritesRepository] Remote toggle failed: $e');
      }
    }
  }

  @override
  Future<void> syncFavorites() async {
    try {
      // 1. Push local guests saves to remote
      final localData = await _localDataSource.getSavedProperties();
      if (localData.isNotEmpty) {
        final localIds = localData.map((e) => e.id).toList();
        await _remoteDataSource.syncFavorites(localIds);
      }

      // 2. Fetch merged remote list and update local
      final remoteList = await _remoteDataSource.getFavorites();
      await _localDataSource.saveProperties(remoteList);
    } catch (e) {
      debugPrint('[FavoritesRepository] Sync failed: $e');
    }
  }
}
