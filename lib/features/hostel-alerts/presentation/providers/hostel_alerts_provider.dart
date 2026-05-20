import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Model ──────────────────────────────────────────────────────────────────────

class HostelAlertSubscription {
  const HostelAlertSubscription({required this.id, required this.propertyId});

  final String id;
  final String propertyId;

  factory HostelAlertSubscription.fromJson(Map<String, dynamic> json) {
    return HostelAlertSubscription(
      // Support both "propertyId" and "hostelId" field names from the API.
      id: json['id'] as String,
      propertyId: (json['propertyId'] ?? json['hostelId']) as String,
    );
  }
}

// ── State ──────────────────────────────────────────────────────────────────────

class HostelAlertsState {
  const HostelAlertsState({
    this.alerts = const [],
    this.isLoading = false,
    this.pendingIds = const {},
  });

  final List<HostelAlertSubscription> alerts;

  /// True while the full subscription list is being fetched.
  final bool isLoading;

  /// PropertyIds currently mid-subscribe or mid-unsubscribe.
  /// Used to show a per-button loading spinner.
  final Set<String> pendingIds;

  bool isSubscribed(String propertyId) =>
      alerts.any((a) => a.propertyId == propertyId);

  bool isPending(String propertyId) => pendingIds.contains(propertyId);

  HostelAlertsState copyWith({
    List<HostelAlertSubscription>? alerts,
    bool? isLoading,
    Set<String>? pendingIds,
  }) => HostelAlertsState(
    alerts: alerts ?? this.alerts,
    isLoading: isLoading ?? this.isLoading,
    pendingIds: pendingIds ?? this.pendingIds,
  );
}

// ── Provider ───────────────────────────────────────────────────────────────────

final hostelAlertsProvider =
    StateNotifierProvider<HostelAlertsNotifier, HostelAlertsState>((ref) {
      final notifier = HostelAlertsNotifier(ref.watch(dioProvider));

      // Load subscriptions whenever the user is authenticated.
      // When they log out, auth state changes cause this provider to rebuild and
      // the notifier is re-created with an empty state automatically.
      final isAuthenticated = ref.watch(
        authProvider.select((s) => s.isAuthenticated),
      );
      if (isAuthenticated) {
        notifier.loadSubscriptions();
      }

      return notifier;
    });

// ── Notifier ───────────────────────────────────────────────────────────────────

class HostelAlertsNotifier extends StateNotifier<HostelAlertsState> {
  HostelAlertsNotifier(this._dio) : super(const HostelAlertsState());

  final Dio _dio;
  static const _base = '/user-hostel-alerts';

  // ── Read ─────────────────────────────────────────────────────────────────────

  Future<void> loadSubscriptions() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _dio.get<List<dynamic>>('$_base/my');
      final list = (res.data ?? [])
          .map(
            (e) => HostelAlertSubscription.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      state = state.copyWith(alerts: list, isLoading: false);
    } on Exception catch (e) {
      debugPrint('[HostelAlerts] loadSubscriptions failed: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  bool isSubscribed(String propertyId) => state.isSubscribed(propertyId);

  // ── Write ─────────────────────────────────────────────────────────────────────

  /// Subscribe to room alerts for [propertyId].
  ///
  /// A 409 "already subscribed" response is treated as a successful
  /// subscription — the local state is updated to reflect reality.
  Future<void> subscribe(String propertyId) async {
    if (state.isPending(propertyId)) return;
    _setPending(propertyId, true);

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        _base,
        data: {'propertyId': propertyId},
      );

      final data = res.data ?? {};
      final subscription = data.containsKey('id')
          ? HostelAlertSubscription.fromJson(data)
          // Fallback if the server returns a non-standard body.
          : HostelAlertSubscription(id: propertyId, propertyId: propertyId);

      _upsertAlert(subscription);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // Server says we are already subscribed.
        // Ensure the local state reflects this truth.
        if (!state.isSubscribed(propertyId)) {
          _upsertAlert(
            HostelAlertSubscription(
              // Placeholder id — will be corrected on next loadSubscriptions().
              id: propertyId,
              propertyId: propertyId,
            ),
          );
        }
        // Do NOT rethrow — 409 is success from the UX perspective.
      } else {
        rethrow;
      }
    } finally {
      _setPending(propertyId, false);
    }
  }

  /// Unsubscribe from room alerts for [propertyId].
  ///
  /// Uses optimistic removal so the UI responds immediately.
  Future<void> unsubscribe(String propertyId) async {
    if (state.isPending(propertyId)) return;
    _setPending(propertyId, true);

    // Snapshot the current list for rollback on failure.
    final previous = List<HostelAlertSubscription>.from(state.alerts);

    // Optimistic remove.
    state = state.copyWith(
      alerts: state.alerts.where((a) => a.propertyId != propertyId).toList(),
    );

    try {
      final sub = previous.firstWhere(
        (a) => a.propertyId == propertyId,
        // If somehow we don't have the id, use propertyId as a fallback
        // so the DELETE still fires with something meaningful.
        orElse: () =>
            HostelAlertSubscription(id: propertyId, propertyId: propertyId),
      );
      await _dio.delete<void>('$_base/${sub.propertyId}');
    } on DioException catch (e) {
      debugPrint('[HostelAlerts] unsubscribe failed: $e');
      // Revert optimistic change.
      state = state.copyWith(alerts: previous);
      rethrow;
    } finally {
      _setPending(propertyId, false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _upsertAlert(HostelAlertSubscription alert) {
    final without = state.alerts
        .where((a) => a.propertyId != alert.propertyId)
        .toList();
    state = state.copyWith(alerts: [...without, alert]);
  }

  void _setPending(String propertyId, bool pending) {
    final updated = Set<String>.from(state.pendingIds);
    pending ? updated.add(propertyId) : updated.remove(propertyId);
    state = state.copyWith(pendingIds: updated);
  }
}
