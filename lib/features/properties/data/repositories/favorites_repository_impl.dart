import 'package:flutter/foundation.dart';
import '../../domain/entities/saved_property.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../models/saved_property_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._local, this._remote);

  final FavoritesLocalDataSource _local;
  final FavoritesRemoteDataSource _remote;

  @override
  Future<List<SavedProperty>> getFavorites() => _local.getSavedProperties();

  @override
  Future<bool> toggleFavorite(
    SavedProperty property, {
    required bool isAuthenticated,
  }) async {
    if (!isAuthenticated) {
      return _toggleLocal(property);
    }

    // For authenticated users the server is the single source of truth.
    // We do NOT touch local storage before the API call — that's the
    // provider's job via optimistic in-memory state.
    try {
      final serverSaved = await _remote.toggleFavorite(property.id);
      // Write the confirmed server state to the local cache (best-effort,
      // runs async so it never blocks the UI).
      _persistServerState(property, serverSaved).ignore();
      return serverSaved;
    } on Exception catch (e) {
      debugPrint('[FavoritesRepository] toggleFavorite remote failed: $e');
      rethrow; // Provider will revert the optimistic UI on catch.
    }
  }

  @override
  Future<void> syncFavorites() async {
    try {
      final local = await _local.getSavedProperties();
      if (local.isNotEmpty) {
        await _remote.syncFavorites(local.map((e) => e.id).toList());
      }
      final remote = await _remote.getFavorites();
      await _local.saveProperties(remote);
    } on Exception catch (e) {
      debugPrint('[FavoritesRepository] syncFavorites failed: $e');
    }
  }

  @override
  Future<void> clearLocalFavorites() => _local.saveProperties([]);

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<bool> _toggleLocal(SavedProperty property) async {
    final list = await _local.getSavedProperties();
    final index = list.indexWhere((p) => p.id == property.id);
    final nowSaved = index < 0;
    if (nowSaved) {
      list.insert(0, SavedPropertyModel.fromEntity(property));
    } else {
      list.removeAt(index);
    }
    await _local.saveProperties(list);
    return nowSaved;
  }

  Future<void> _persistServerState(SavedProperty property, bool saved) async {
    try {
      final list = await _local.getSavedProperties();
      final filtered = list.where((p) => p.id != property.id).toList();
      if (saved) {
        filtered.insert(0, SavedPropertyModel.fromEntity(property));
      }
      await _local.saveProperties(filtered);
    } on Exception catch (e) {
      debugPrint('[FavoritesRepository] _persistServerState failed: $e');
    }
  }
}
