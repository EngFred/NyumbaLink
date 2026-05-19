import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentora/features/hostel-alerts/domain/entities/hostel_alert.dart';

import '../../../../../core/network/dio_client.dart';

final hostelAlertsRemoteDataSourceProvider =
    Provider<HostelAlertsRemoteDataSource>(
      (ref) => HostelAlertsRemoteDataSource(ref.watch(dioProvider)),
    );

class HostelAlertsRemoteDataSource {
  const HostelAlertsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<HostelAlert> subscribe(String propertyId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/user-hostel-alerts',
      data: {'propertyId': propertyId},
    );
    return _fromJson(res.data!);
  }

  Future<void> unsubscribe(String propertyId) async {
    await _dio.delete('/user-hostel-alerts/$propertyId');
  }

  Future<List<HostelAlert>> getMyAlerts() async {
    final res = await _dio.get<List<dynamic>>('/user-hostel-alerts/my');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(_fromJson)
        .toList();
  }

  HostelAlert _fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    return HostelAlert(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      propertyTitle: property['title'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
