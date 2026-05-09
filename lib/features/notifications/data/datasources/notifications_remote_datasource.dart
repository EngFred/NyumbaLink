import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_response.dart';
import '../models/notification_model.dart';

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      return NotificationsRemoteDataSource(ref.watch(dioProvider));
    });

class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse.fromJson(res.data!, NotificationModel.fromJson);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/notifications/unread-count',
      );
      return int.tryParse(res.data!['count'].toString()) ?? 0;
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
