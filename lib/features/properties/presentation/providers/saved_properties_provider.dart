import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../data/mappers/property_mapper.dart';
import '../../domain/entities/property_entities.dart';

class SavedProperty {
  const SavedProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    this.thumbnailUrl,
    required this.type,
  });

  final String id;
  final String title;
  final double price;
  final String location;
  final String? thumbnailUrl;
  final String type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'location': location,
    'thumbnailUrl': thumbnailUrl,
    'type': type,
  };

  factory SavedProperty.fromJson(Map<String, dynamic> json) => SavedProperty(
    id: json['id'] as String,
    title: json['title'] as String,
    price: double.parse(json['price'].toString()),
    location: json['location'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    type: json['type'] as String,
  );

  /// Fixed: Uses the same clean logic as Property.locationDisplay
  factory SavedProperty.fromDomain(Property p) => SavedProperty(
    id: p.id,
    title: p.title,
    price: p.price,
    location: _buildLocation(p),
    thumbnailUrl: p.thumbnailUrl,
    type: p.type,
  );

  static String _buildLocation(Property p) {
    final areaName = p.area?.name.trim();
    if (areaName != null && areaName.isNotEmpty) {
      return '$areaName, ${p.district.name}';
    }
    return p.district.name;
  }
}

// ── State ─────────────────────────────────────────────────────────────────────

class SavedPropertiesState {
  const SavedPropertiesState({
    this.savedList = const [],
    this.isLoading = true,
  });

  final List<SavedProperty> savedList;
  final bool isLoading;

  SavedPropertiesState copyWith({
    List<SavedProperty>? savedList,
    bool? isLoading,
  }) {
    return SavedPropertiesState(
      savedList: savedList ?? this.savedList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Provider & Notifier (unchanged) ───────────────────────────────────────────
final savedPropertiesProvider =
    StateNotifierProvider<SavedPropertiesNotifier, SavedPropertiesState>((ref) {
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;
      final remoteDataSource = ref.watch(favoritesRemoteDataSourceProvider);
      final notifier = SavedPropertiesNotifier(
        isAuthenticated,
        remoteDataSource,
      );

      if (isAuthenticated) {
        notifier.syncGuestData();
      } else {
        notifier.load();
      }

      return notifier;
    });

class SavedPropertiesNotifier extends StateNotifier<SavedPropertiesState> {
  SavedPropertiesNotifier(this._isAuthenticated, this._remoteDataSource)
    : super(const SavedPropertiesState());

  final bool _isAuthenticated;
  final FavoritesRemoteDataSource _remoteDataSource;

  static const _key = 'nyumbalink_saved_properties';

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_key) ?? [];
      final list = data
          .map(
            (e) =>
                SavedProperty.fromJson(jsonDecode(e) as Map<String, dynamic>),
          )
          .toList();
      state = state.copyWith(savedList: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleSave(Property property) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    final existingIndex = data.indexWhere(
      (e) =>
          SavedProperty.fromJson(jsonDecode(e) as Map<String, dynamic>).id ==
          property.id,
    );

    if (existingIndex >= 0) {
      data.removeAt(existingIndex);
    } else {
      data.insert(0, jsonEncode(SavedProperty.fromDomain(property).toJson()));
    }

    await prefs.setStringList(_key, data);
    await load();

    if (_isAuthenticated) {
      _remoteDataSource.toggleFavorite(property.id).catchError((_) {});
    }
  }

  bool isSaved(String propertyId) =>
      state.savedList.any((p) => p.id == propertyId);

  Future<void> syncGuestData() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getStringList(_key) ?? [];
      if (localData.isNotEmpty) {
        final localIds = localData
            .map(
              (e) => SavedProperty.fromJson(
                jsonDecode(e) as Map<String, dynamic>,
              ).id,
            )
            .toList();
        await _remoteDataSource.syncFavorites(localIds);
      }
    } catch (e) {
      debugPrint('[SavedProperties] push sync failed: $e');
    }

    try {
      final remoteModels = await _remoteDataSource.getFavorites();
      final prefs = await SharedPreferences.getInstance();
      final merged = remoteModels
          .map(
            (m) => jsonEncode(SavedProperty.fromDomain(m.toEntity()).toJson()),
          )
          .toList();
      await prefs.setStringList(_key, merged);
    } catch (e) {
      debugPrint('[SavedProperties] pull sync failed: $e');
    }

    await load();
  }
}
