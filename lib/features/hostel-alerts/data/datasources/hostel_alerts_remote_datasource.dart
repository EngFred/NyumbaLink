import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_client.dart';
import '../models/hostel_alert_model.dart';

final hostelAlertsRemoteDataSourceProvider =
    Provider<HostelAlertsRemoteDataSource>(
      (ref) => HostelAlertsRemoteDataSource(ref.watch(dioProvider)),
    );

class HostelAlertsRemoteDataSource {
  const HostelAlertsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<HostelAlertModel> subscribe(String propertyId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/user-hostel-alerts',
      data: {'propertyId': propertyId},
    );
    return HostelAlertModel.fromJson(res.data!);
  }

  Future<void> unsubscribe(String propertyId) async {
    await _dio.delete('/user-hostel-alerts/$propertyId');
  }

  Future<List<HostelAlertModel>> getMyAlerts() async {
    final res = await _dio.get<List<dynamic>>('/user-hostel-alerts/my');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(HostelAlertModel.fromJson)
        .toList();
  }
}
