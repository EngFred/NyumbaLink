import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/property_entities.dart';
import '../../domain/usecases/property_usecases.dart';
import 'usecase_providers.dart';

class PropertyDetailState {
  const PropertyDetailState({this.property, this.isLoading = true, this.error});
  final Property? property;
  final bool isLoading;
  final String? error;

  PropertyDetailState copyWith({
    Property? property,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PropertyDetailState(
      property: property ?? this.property,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final propertyDetailProvider = StateNotifierProvider.family
    .autoDispose<PropertyDetailNotifier, PropertyDetailState, String>((
      ref,
      id,
    ) {
      return PropertyDetailNotifier(
        ref.watch(getPropertyDetailsUseCaseProvider),
        ref.watch(incrementEnquiryUseCaseProvider),
        id,
      )..load();
    });

class PropertyDetailNotifier extends StateNotifier<PropertyDetailState> {
  PropertyDetailNotifier(
    this._getDetails,
    this._incrementEnquiry,
    this.propertyId,
  ) : super(const PropertyDetailState());

  final GetPropertyDetailsUseCase _getDetails;
  final IncrementEnquiryUseCase _incrementEnquiry;
  final String propertyId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final property = await _getDetails(propertyId);
      state = state.copyWith(property: property, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void enquire() => _incrementEnquiry(propertyId).catchError((_) {});
}
