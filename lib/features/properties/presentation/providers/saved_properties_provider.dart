import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../domain/entities/property_entities.dart';

/// A lightweight entity stored locally — avoids serialising the full Property object.
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

  factory SavedProperty.fromDomain(Property p) => SavedProperty(
    id: p.id,
    title: p.title,
    price: p.price,
    location: '${p.area}, ${p.district.name}',
    thumbnailUrl: p.thumbnailUrl,
    type: p.type,
  );
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

// ── Provider ──────────────────────────────────────────────────────────────────

final savedPropertiesProvider =
    StateNotifierProvider<SavedPropertiesNotifier, SavedPropertiesState>((ref) {
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;
      final remoteDataSource = ref.watch(favoritesRemoteDataSourceProvider);
      return SavedPropertiesNotifier(isAuthenticated, remoteDataSource)..load();
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class SavedPropertiesNotifier extends StateNotifier<SavedPropertiesState> {
  SavedPropertiesNotifier(this._isAuthenticated, this._remoteDataSource)
    : super(const SavedPropertiesState());

  final bool _isAuthenticated;
  final FavoritesRemoteDataSource _remoteDataSource;

  static const _key = 'nyumbalink_saved_properties';

  // ── Read ──────────────────────────────────────────────────────────────────
  //
  // SharedPreferences is ALWAYS the single source of truth for the UI.
  // The remote API is never read for display purposes — only written to
  // (toggle / sync) as a fire-and-forget side-effect when the user is
  // authenticated.

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

  // ── Write ─────────────────────────────────────────────────────────────────

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

    // Refresh UI from local immediately — no waiting on network.
    await load();

    // Fire-and-forget: keep the server in sync when logged in.
    if (_isAuthenticated) {
      _remoteDataSource.toggleFavorite(property.id).catchError((_) {});
    }
  }

  bool isSaved(String propertyId) =>
      state.savedList.any((p) => p.id == propertyId);

  // ── Sync ──────────────────────────────────────────────────────────────────
  //
  // Called once by AuthProvider right after a successful login / registration.
  // Pushes every locally saved property ID to the backend so the user's
  // favourites are available on other devices.
  // Local storage is NOT cleared — it remains the display source of truth.

  Future<void> syncGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    if (data.isEmpty) return;

    final ids = data
        .map(
          (e) =>
              SavedProperty.fromJson(jsonDecode(e) as Map<String, dynamic>).id,
        )
        .toList();

    try {
      await _remoteDataSource.syncFavorites(ids);
    } catch (_) {
      // Sync failure is silent — the user can still use the app offline.
    }
  }
}
