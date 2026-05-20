import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/saved_property_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<SavedPropertyModel>> getFavorites();
  Future<void> toggleFavorite(String propertyId);
  Future<void> syncFavorites(List<String> propertyIds);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  const FavoritesRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<SavedPropertyModel>> getFavorites() async {
    try {
      final res = await _dio.get<List<dynamic>>('/favorites');
      return res.data!
          .map((e) => SavedPropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> toggleFavorite(String propertyId) async {
    try {
      await _dio.post('/favorites/$propertyId');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  @override
  Future<void> syncFavorites(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return;
    try {
      await _dio.post('/favorites/sync', data: {'propertyIds': propertyIds});
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
