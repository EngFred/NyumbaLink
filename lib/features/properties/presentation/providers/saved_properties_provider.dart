import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/property_entities.dart';

/// A lightweight entity to store locally so we don't have to save/parse the massive full Property object
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

  // Helper to map from the full domain Property
  factory SavedProperty.fromDomain(Property p) => SavedProperty(
    id: p.id,
    title: p.title,
    price: p.price,
    location: '${p.area}, ${p.district.name}',
    thumbnailUrl: p.thumbnailUrl,
    type: p.type,
  );
}

// ── State ──

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

// ── Provider ──

final savedPropertiesProvider =
    StateNotifierProvider<SavedPropertiesNotifier, SavedPropertiesState>((ref) {
      return SavedPropertiesNotifier()..load();
    });

class SavedPropertiesNotifier extends StateNotifier<SavedPropertiesState> {
  SavedPropertiesNotifier() : super(const SavedPropertiesState());

  static const _key = 'nyumbalink_saved_properties';

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    final list = data
        .map((e) => SavedProperty.fromJson(jsonDecode(e)))
        .toList();
    state = state.copyWith(savedList: list, isLoading: false);
  }

  Future<void> toggleSave(Property property) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    final existingIndex = data.indexWhere(
      (e) => SavedProperty.fromJson(jsonDecode(e)).id == property.id,
    );

    if (existingIndex >= 0) {
      // It's already saved; remove it
      data.removeAt(existingIndex);
    } else {
      // Not saved; add it
      final newSummary = SavedProperty.fromDomain(property);
      data.insert(0, jsonEncode(newSummary.toJson())); // Add to top of list
    }

    await prefs.setStringList(_key, data);
    await load(); // Refresh state
  }

  bool isSaved(String propertyId) {
    return state.savedList.any((p) => p.id == propertyId);
  }
}
