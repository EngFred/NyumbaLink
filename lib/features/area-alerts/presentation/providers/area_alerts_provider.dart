import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/area_alert.dart';
import '../../domain/usecases/area_alert_usecases.dart';
import 'area_alert_providers.dart'; // Imports the repo provider

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
        UpdateAreaAlert(
          repo,
        ), // ── PRO FIX: Injected the new update use case ──
      );
    });

class AreaAlertsNotifier extends StateNotifier<AreaAlertsState> {
  final GetMyAreaAlerts _getMyAlerts;
  final SubscribeToAreaAlert _subscribe;
  final UnsubscribeFromAreaAlert _unsubscribe;
  final UpdateAreaAlert _update; // ── PRO FIX: Declared the use case ──

  AreaAlertsNotifier(
    this._getMyAlerts,
    this._subscribe,
    this._unsubscribe,
    this._update, // ── PRO FIX: Added to constructor ──
  ) : super(const AreaAlertsState());

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

  Future<void> updateAlert(String areaId, {List<String>? propertyTypes}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedAlert = await _update.call(
        areaId,
        propertyTypes: propertyTypes,
      );
      // Replace the old alert with the updated one in the list
      final newAlerts = state.alerts
          .map((a) => a.areaId == areaId ? updatedAlert : a)
          .toList();
      state = state.copyWith(alerts: newAlerts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
