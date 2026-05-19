import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/area_alerts_remote_datasource.dart';
import '../../domain/entities/area_alert.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AreaAlertsState {
  const AreaAlertsState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AreaAlert> alerts;
  final bool isLoading;
  final String? error;

  AreaAlertsState copyWith({
    List<AreaAlert>? alerts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AreaAlertsState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final areaAlertsProvider =
    StateNotifierProvider<AreaAlertsNotifier, AreaAlertsState>((ref) {
      return AreaAlertsNotifier(ref.watch(areaAlertsRemoteDataSourceProvider));
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class AreaAlertsNotifier extends StateNotifier<AreaAlertsState> {
  AreaAlertsNotifier(this._dataSource) : super(const AreaAlertsState());

  final AreaAlertsRemoteDataSource _dataSource;

  /// Fetches the authenticated user's current subscriptions.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alerts = await _dataSource.getMyAlerts();
      state = state.copyWith(alerts: alerts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Subscribes to [areaId] and inserts the new alert into the local list.
  Future<void> subscribe(String areaId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alert = await _dataSource.subscribe(areaId);
      state = state.copyWith(
        alerts: [alert, ...state.alerts],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Unsubscribes from [areaId] and removes the alert from the local list.
  Future<void> unsubscribe(String areaId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _dataSource.unsubscribe(areaId);
      state = state.copyWith(
        alerts: state.alerts.where((a) => a.areaId != areaId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
