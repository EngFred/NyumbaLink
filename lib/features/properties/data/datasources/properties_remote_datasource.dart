import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_response.dart';
import '../models/property_models.dart';

final propertiesDataSourceProvider = Provider<PropertiesRemoteDataSource>(
  (ref) => PropertiesRemoteDataSource(ref.watch(dioProvider)),
);

class PropertiesRemoteDataSource {
  PropertiesRemoteDataSource(this._dio);
  final Dio _dio;

  Future<PaginatedResponse<PropertyModel>> getProperties(
    Map<String, dynamic> queryParams,
  ) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/properties',
        queryParameters: queryParams,
      );
      return PaginatedResponse.fromJson(res.data!, PropertyModel.fromJson);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<PropertyModel> getProperty(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/properties/$id');
      return PropertyModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> incrementEnquiry(String id) async {
    try {
      await _dio.post<void>('/properties/$id/enquiry');
    } catch (_) {}
  }

  Future<List<HostelRoomModel>> getHostelRooms(String propertyId) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '/properties/$propertyId/rooms',
      );
      return (res.data ?? [])
          .map((e) => HostelRoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<HostelStatsModel> getHostelStats(String propertyId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/properties/$propertyId/rooms/stats',
      );
      return HostelStatsModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
