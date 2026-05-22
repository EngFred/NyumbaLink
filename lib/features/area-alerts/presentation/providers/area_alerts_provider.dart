import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentora/features/area-alerts/presentation/providers/area_alert_providers.dart';

import '../../domain/entities/area_alert.dart';
import '../../domain/usecases/area_alert_usecases.dart';

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

final areaAlertsProvider =
    StateNotifierProvider<AreaAlertsNotifier, AreaAlertsState>((ref) {
      final repo = ref.watch(areaAlertRepositoryProvider);
      return AreaAlertsNotifier(
        GetMyAreaAlerts(repo),
        SubscribeToAreaAlert(repo),
        UnsubscribeFromAreaAlert(repo),
      );
    });

class AreaAlertsNotifier extends StateNotifier<AreaAlertsState> {
  final GetMyAreaAlerts _getMyAlerts;
  final SubscribeToAreaAlert _subscribe;
  final UnsubscribeFromAreaAlert _unsubscribe;

  AreaAlertsNotifier(this._getMyAlerts, this._subscribe, this._unsubscribe)
    : super(const AreaAlertsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alerts = await _getMyAlerts.call();
      state = state.copyWith(alerts: alerts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> subscribe(String areaId, {List<String>? propertyTypes}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alert = await _subscribe.call(areaId, propertyTypes: propertyTypes);
      state = state.copyWith(
        alerts: [alert, ...state.alerts],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unsubscribe(String areaId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _unsubscribe.call(areaId);
      state = state.copyWith(
        alerts: state.alerts.where((a) => a.areaId != areaId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
