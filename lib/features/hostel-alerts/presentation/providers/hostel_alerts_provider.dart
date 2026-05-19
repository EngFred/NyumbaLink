import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentora/features/hostel-alerts/presentation/providers/hostel_alert_providers.dart';

import '../../domain/usecases/hostel_alert_usecases.dart';
import '../../domain/entities/hostel_alert.dart';

class HostelAlertsState {
  const HostelAlertsState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<HostelAlert> alerts;
  final bool isLoading;
  final String? error;

  HostelAlertsState copyWith({
    List<HostelAlert>? alerts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HostelAlertsState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final hostelAlertsProvider =
    StateNotifierProvider<HostelAlertsNotifier, HostelAlertsState>((ref) {
      final repo = ref.watch(hostelAlertRepositoryProvider);
      return HostelAlertsNotifier(
        GetMyHostelAlerts(repo),
        SubscribeToHostelAlert(repo),
        UnsubscribeFromHostelAlert(repo),
      );
    });

class HostelAlertsNotifier extends StateNotifier<HostelAlertsState> {
  final GetMyHostelAlerts _getMyAlerts;
  final SubscribeToHostelAlert _subscribe;
  final UnsubscribeFromHostelAlert _unsubscribe;

  HostelAlertsNotifier(this._getMyAlerts, this._subscribe, this._unsubscribe)
    : super(const HostelAlertsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alerts = await _getMyAlerts.call();
      state = state.copyWith(alerts: alerts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> subscribe(String propertyId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alert = await _subscribe.call(propertyId);
      state = state.copyWith(
        alerts: [alert, ...state.alerts],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unsubscribe(String propertyId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _unsubscribe.call(propertyId);
      state = state.copyWith(
        alerts: state.alerts.where((a) => a.propertyId != propertyId).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool isSubscribed(String propertyId) =>
      state.alerts.any((a) => a.propertyId == propertyId);
}
