import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../models/property_models.dart';

final favoritesRemoteDataSourceProvider = Provider<FavoritesRemoteDataSource>((
  ref,
) {
  return FavoritesRemoteDataSource(ref.watch(dioProvider));
});

class FavoritesRemoteDataSource {
  const FavoritesRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<PropertyModel>> getFavorites() async {
    try {
      final res = await _dio.get<List<dynamic>>('/favorites');
      return res.data!.map((e) => PropertyModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    try {
      await _dio.post('/favorites/$propertyId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> syncFavorites(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return;
    try {
      await _dio.post('/favorites/sync', data: {'propertyIds': propertyIds});
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
