import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_property_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<SavedPropertyModel>> getSavedProperties();
  Future<void> saveProperties(List<SavedPropertyModel> properties);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  const FavoritesLocalDataSourceImpl(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'rentora_saved_properties';

  @override
  Future<List<SavedPropertyModel>> getSavedProperties() async {
    final data = _prefs.getStringList(_key) ?? [];
    return data
        .map(
          (e) => SavedPropertyModel.fromJson(
            jsonDecode(e) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveProperties(List<SavedPropertyModel> properties) async {
    final encoded = properties.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_key, encoded);
  }
}
