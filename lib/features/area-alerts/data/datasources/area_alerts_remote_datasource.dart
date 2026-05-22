import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_client.dart';
import '../models/area_alert_model.dart';
import '../models/area_option.dart';

final areaAlertsRemoteDataSourceProvider = Provider<AreaAlertsRemoteDataSource>(
  (ref) => AreaAlertsRemoteDataSource(ref.watch(dioProvider)),
);

class AreaAlertsRemoteDataSource {
  const AreaAlertsRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<AreaAlertModel>> getMyAlerts() async {
    final res = await _dio.get<List<dynamic>>('/user-area-alerts/my');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(AreaAlertModel.fromJson)
        .toList();
  }

  Future<AreaAlertModel> subscribe(
    String areaId, {
    List<String>? propertyTypes,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/user-area-alerts',
      data: {
        'areaId': areaId,
        // Omit the key entirely when subscribing to all types —
        // the backend treats a missing / empty array as null (all types).
        if (propertyTypes != null && propertyTypes.isNotEmpty)
          'propertyTypes': propertyTypes,
      },
    );
    return AreaAlertModel.fromJson(res.data!);
  }

  Future<AreaAlertModel> updateSubscription(
    String areaId, {
    List<String>? propertyTypes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/user-area-alerts/$areaId',
      data: {
        'propertyTypes': (propertyTypes != null && propertyTypes.isNotEmpty)
            ? propertyTypes
            : null,
      },
    );
    return AreaAlertModel.fromJson(res.data!);
  }

  Future<void> unsubscribe(String areaId) async {
    await _dio.delete('/user-area-alerts/$areaId');
  }

  Future<List<AreaOption>> getAllAreas() async {
    final res = await _dio.get<List<dynamic>>('/areas');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(AreaOption.fromJson)
        .toList();
  }
}
