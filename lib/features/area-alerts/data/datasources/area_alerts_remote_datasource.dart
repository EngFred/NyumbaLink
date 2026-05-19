import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentora/features/area-alerts/domain/entities/area_alert.dart';

import '../../../../../core/network/dio_client.dart';

final areaAlertsRemoteDataSourceProvider = Provider<AreaAlertsRemoteDataSource>(
  (ref) => AreaAlertsRemoteDataSource(ref.watch(dioProvider)),
);

class AreaAlertsRemoteDataSource {
  const AreaAlertsRemoteDataSource(this._dio);
  final Dio _dio;

  /// GET /user-area-alerts/my — returns the user's active subscriptions.
  Future<List<AreaAlert>> getMyAlerts() async {
    final res = await _dio.get<List<dynamic>>('/user-area-alerts/my');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(_alertFromJson)
        .toList();
  }

  /// POST /user-area-alerts — subscribe to push notifications for [areaId].
  Future<AreaAlert> subscribe(String areaId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/user-area-alerts',
      data: {'areaId': areaId},
    );
    return _alertFromJson(res.data!);
  }

  /// DELETE /user-area-alerts/{areaId} — unsubscribe from an area.
  Future<void> unsubscribe(String areaId) async {
    await _dio.delete<void>('/user-area-alerts/$areaId');
  }

  /// GET /areas — returns every area, used to populate the "Add area" sheet.
  /// Groups areas by district for display.
  Future<List<AreaOption>> getAllAreas() async {
    final res = await _dio.get<List<dynamic>>('/areas');
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(AreaOption.fromJson)
        .toList();
  }

  // ── Mapper ─────────────────────────────────────────────────────────────

  static AreaAlert _alertFromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>? ?? {};
    final district = area['district'] as Map<String, dynamic>? ?? {};

    return AreaAlert(
      id: json['id'] as String,
      areaId: json['areaId'] as String,
      areaName: area['name'] as String? ?? '',
      districtName: district['name'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Lightweight model for the "pick an area" bottom sheet.
class AreaOption {
  const AreaOption({
    required this.id,
    required this.name,
    required this.districtId,
    required this.districtName,
  });

  final String id;
  final String name;
  final String districtId;
  final String districtName;

  factory AreaOption.fromJson(Map<String, dynamic> json) {
    final district = json['district'] as Map<String, dynamic>? ?? {};
    return AreaOption(
      id: json['id'] as String,
      name: json['name'] as String,
      districtId: district['id'] as String? ?? '',
      districtName: district['name'] as String? ?? '',
    );
  }
}
