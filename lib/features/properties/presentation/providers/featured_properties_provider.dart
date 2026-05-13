import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/property_entities.dart';
import '../../domain/entities/property_filters.dart';
import '../../domain/usecases/property_usecases.dart';
import 'usecase_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class FeaturedPropertiesState {
  const FeaturedPropertiesState({
    this.properties = const [],
    this.isLoading = true,
    this.error,
  });

  final List<Property> properties;
  final bool isLoading;
  final String? error;

  FeaturedPropertiesState copyWith({
    List<Property>? properties,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FeaturedPropertiesState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final featuredPropertiesProvider =
    StateNotifierProvider.autoDispose<
      FeaturedPropertiesNotifier,
      FeaturedPropertiesState
    >((ref) {
      return FeaturedPropertiesNotifier(ref.watch(getPropertiesUseCaseProvider))
        ..load();
    });

// ── Notifier ──────────────────────────────────────────────────────────────────

class FeaturedPropertiesNotifier
    extends StateNotifier<FeaturedPropertiesState> {
  FeaturedPropertiesNotifier(this._getProperties)
    : super(const FeaturedPropertiesState());

  final GetPropertiesUseCase _getProperties;

  static const _featuredFilters = PropertyFilters(
    isFeatured: true,
    limit: 10,
    page: 1,
    status: 'AVAILABLE',
  );

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _getProperties(_featuredFilters);
      state = state.copyWith(properties: res.data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load();
}
