import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/property_entities.dart';
import '../../domain/entities/property_filters.dart';
import '../../domain/usecases/property_usecases.dart';
import 'usecase_providers.dart';

class PropertiesState {
  const PropertiesState({
    this.properties = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.filters = const PropertyFilters(),
    this.total = 0,
    this.currentPage = 1,
    this.hasNextPage = true,
  });

  final List<Property> properties;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PropertyFilters filters;
  final int total;
  final int currentPage;
  final bool hasNextPage;

  PropertiesState copyWith({
    List<Property>? properties,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    PropertyFilters? filters,
    int? total,
    int? currentPage,
    bool? hasNextPage,
  }) {
    return PropertiesState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      filters: filters ?? this.filters,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

final propertiesProvider =
    StateNotifierProvider<PropertiesNotifier, PropertiesState>((ref) {
      return PropertiesNotifier(ref.watch(getPropertiesUseCaseProvider))
        ..load();
    });

class PropertiesNotifier extends StateNotifier<PropertiesState> {
  PropertiesNotifier(this._getProperties) : super(const PropertiesState());

  final GetPropertiesUseCase _getProperties;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final filters = state.filters.copyWith(page: 1);
      final res = await _getProperties(filters);

      state = state.copyWith(
        properties: res.data,
        isLoading: false,
        total: res.meta.total,
        currentPage: res.meta.page,
        hasNextPage: res.hasNextPage,
        filters: filters,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final filters = state.filters.copyWith(page: nextPage);
      final res = await _getProperties(filters);

      state = state.copyWith(
        properties: [...state.properties, ...res.data],
        isLoadingMore: false,
        currentPage: res.meta.page,
        hasNextPage: res.hasNextPage,
        filters: filters,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> applyFilters(PropertyFilters newFilters) async {
    state = state.copyWith(filters: newFilters);
    await load();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const PropertyFilters());
    await load();
  }
}
