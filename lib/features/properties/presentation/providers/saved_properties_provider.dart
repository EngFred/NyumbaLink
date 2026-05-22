import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/saved_property.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class SavedPropertiesState {
  const SavedPropertiesState({
    this.savedList = const [],
    this.isLoading = true,
  });

  final List<SavedProperty> savedList;
  final bool isLoading;

  SavedPropertiesState copyWith({
    List<SavedProperty>? savedList,
    bool? isLoading,
  }) => SavedPropertiesState(
    savedList: savedList ?? this.savedList,
    isLoading: isLoading ?? this.isLoading,
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

final savedPropertiesProvider =
    StateNotifierProvider<SavedPropertiesNotifier, SavedPropertiesState>((ref) {
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;

      final notifier = SavedPropertiesNotifier(
        isAuthenticated: isAuthenticated,
        getFavorites: ref.watch(getFavoritesUseCaseProvider),
        toggleFavoriteUseCase: ref.watch(toggleFavoriteUseCaseProvider),
        syncFavoritesUseCase: ref.watch(syncFavoritesUseCaseProvider),
      );

      if (isAuthenticated) {
        notifier.syncData();
      } else {
        // Guest cold-start OR post-logout: just read SharedPreferences.
        // Clearing is handled explicitly in AuthNotifier.logout() BEFORE
        // this rebuild fires, so by the time load() runs here the
        // SharedPreferences are already empty on logout, and still intact
        // on a normal guest cold-start.
        notifier.load();
      }

      return notifier;
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class SavedPropertiesNotifier extends StateNotifier<SavedPropertiesState> {
  SavedPropertiesNotifier({
    required this.isAuthenticated,
    required this.getFavorites,
    required this.toggleFavoriteUseCase,
    required this.syncFavoritesUseCase,
  }) : super(const SavedPropertiesState());

  final bool isAuthenticated;
  final GetFavoritesUseCase getFavorites;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final SyncFavoritesUseCase syncFavoritesUseCase;

  /// One pending timer per propertyId.  Any new tap cancels the old timer.
  final Map<String, Timer> _pendingTimers = {};

  /// The last state the *server* confirmed, per propertyId.
  /// Populated on load/sync and updated after every successful API round-trip.
  /// This is what we revert to on network failure.
  final Map<String, bool> _confirmedServerState = {};

  /// How long after the *last* tap to wait before firing the API call.
  static const _kDebounce = Duration(milliseconds: 650);

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await getFavorites();

      // Populate confirmed server state from persisted data, but only for
      // properties that do NOT have a pending debounce timer — we must not
      // overwrite an optimistic change the user is still making.
      for (final p in list) {
        if (!_pendingTimers.containsKey(p.id)) {
          _confirmedServerState[p.id] = true;
        }
      }

      if (!mounted) return; // notifier was disposed mid-flight

      if (_pendingTimers.isEmpty) {
        // No pending taps — safe to replace the whole list.
        state = state.copyWith(savedList: list, isLoading: false);
      } else {
        // Pending taps exist: keep their optimistic state, replace the rest.
        final pendingIds = _pendingTimers.keys.toSet();
        final merged = [
          ...list.where((p) => !pendingIds.contains(p.id)),
          ...state.savedList.where((p) => pendingIds.contains(p.id)),
        ];
        state = state.copyWith(savedList: merged, isLoading: false);
      }
    } catch (_) {
      if (!mounted) return; // notifier was disposed mid-flight
      state = state.copyWith(isLoading: false);
    }
  }

  /// Instantly updates the UI (optimistic) and debounces the network call.
  ///
  /// Multiple rapid taps:
  ///   - Each tap toggles the in-memory list immediately.
  ///   - Each tap cancels and reschedules the network call.
  ///   - The API is called exactly ONCE, 650 ms after the final tap.
  ///   - If the net number of taps is even (no net change) the API is skipped.
  ///   - On network failure the UI reverts to the last server-confirmed state.
  void toggleSave(SavedProperty property) {
    final id = property.id;

    // Record the server baseline the first time this property is tapped in
    // this session (before any optimistic changes).
    _confirmedServerState.putIfAbsent(
      id,
      () => state.savedList.any((p) => p.id == id),
    );

    // --- Optimistic UI update (synchronous, instant) ---
    final currentlySaved = state.savedList.any((p) => p.id == id);
    state = state.copyWith(
      savedList: currentlySaved
          ? state.savedList.where((p) => p.id != id).toList()
          : [property, ...state.savedList],
    );

    // --- Debounce ---
    _pendingTimers[id]?.cancel();
    _pendingTimers[id] = Timer(_kDebounce, () {
      _pendingTimers.remove(id);
      _commitToggle(property); // fire-and-forget
    });
  }

  bool isSaved(String propertyId) =>
      state.savedList.any((p) => p.id == propertyId);

  Future<void> syncData() async {
    state = state.copyWith(isLoading: true);
    await syncFavoritesUseCase();
    if (!mounted) return; // notifier was disposed mid-flight
    await load();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _commitToggle(SavedProperty property) async {
    final id = property.id;
    final serverSaved = _confirmedServerState[id] ?? false;
    final desiredSaved = state.savedList.any((p) => p.id == id);

    // Even number of taps cancelled each other out — nothing to do.
    if (serverSaved == desiredSaved) return;

    try {
      final newServerSaved = await toggleFavoriteUseCase(
        property,
        isAuthenticated: isAuthenticated,
      );

      // Update our baseline with what the server now holds.
      _confirmedServerState[id] = newServerSaved;

      // Edge case: server returned a state different from our optimistic
      // prediction (e.g. another device changed it concurrently). Reconcile.
      if (newServerSaved != desiredSaved) {
        _applyServerState(property, newServerSaved);
      }
    } catch (_) {
      // Network error — revert the UI to the last known server state.
      _applyServerState(property, serverSaved);
    }
  }

  void _applyServerState(SavedProperty property, bool shouldBeSaved) {
    final id = property.id;
    final currentlySaved = state.savedList.any((p) => p.id == id);
    if (shouldBeSaved == currentlySaved) return; // already correct

    state = state.copyWith(
      savedList: shouldBeSaved
          ? [property, ...state.savedList.where((p) => p.id != id)]
          : state.savedList.where((p) => p.id != id).toList(),
    );
  }

  @override
  void dispose() {
    for (final t in _pendingTimers.values) {
      t.cancel();
    }
    _pendingTimers.clear();
    super.dispose();
  }
}
