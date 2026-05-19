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
//
// This provider watches authProvider. Riverpod recreates it whenever
// isAuthenticated changes — including when checkAuthStatus() completes on
// app start for an already-logged-in user. We use that moment to decide
// whether to just read local (guest) or do a full bidirectional sync
// (authenticated). This means sync happens automatically for:
//   - A user who is already logged in when the app starts
//   - A user who just logged in or registered
// No manual trigger from auth_provider is needed for the already-logged-in case.

final savedPropertiesProvider =
    StateNotifierProvider<SavedPropertiesNotifier, SavedPropertiesState>((ref) {
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;
      final remoteDataSource = ref.watch(favoritesRemoteDataSourceProvider);
      final notifier = SavedPropertiesNotifier(
        isAuthenticated,
        remoteDataSource,
      );

      if (isAuthenticated) {
        // Authenticated: bidirectional sync — push local to server, then pull
        // server back to local so both are always consistent, regardless of
        // whether the user just logged in or was already logged in from a
        // previous session.
        notifier.syncGuestData();
      } else {
        // Guest: just read local storage.
        notifier.load();
      }

      return notifier;
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class SavedPropertiesNotifier extends StateNotifier<SavedPropertiesState> {
  SavedPropertiesNotifier(this._isAuthenticated, this._remoteDataSource)
    : super(const SavedPropertiesState());

  final bool _isAuthenticated;
  final FavoritesRemoteDataSource _remoteDataSource;

  static const _key = 'nyumbalink_saved_properties';

  // ── Read ──────────────────────────────────────────────────────────────────

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

  // ── Toggle ────────────────────────────────────────────────────────────────

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

    // Fire-and-forget server sync when logged in.
    if (_isAuthenticated) {
      _remoteDataSource.toggleFavorite(property.id).catchError((_) {});
    }
  }

  bool isSaved(String propertyId) =>
      state.savedList.any((p) => p.id == propertyId);

  // ── Bidirectional sync ────────────────────────────────────────────────────
  //
  // Step 1 — Push: local IDs → POST /favorites/sync (idempotent, ON CONFLICT
  //          DO NOTHING). Links any guest-saved properties to the account.
  //
  // Step 2 — Pull: GET /favorites → overwrite local storage with the server's
  //          authoritative merged list. This is what keeps local and server
  //          from diverging across sessions and devices.
  //
  // Called automatically by the provider on every authenticated init.
  // Also called by auth_provider after login/register (harmless duplicate —
  // both operations are idempotent).

  Future<void> syncGuestData() async {
    state = state.copyWith(isLoading: true);

    // Step 1: push local → server (best-effort, failure is silent)
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

    // Step 2: pull server → local (critical path — SEPARATE try-catch)
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
      // This will now print the real error instead of swallowing it
      debugPrint('[SavedProperties] pull sync failed: $e');
    }

    // Step 3: always load from local regardless of outcome
    await load();
  }
}
