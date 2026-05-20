import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entities.dart';
import '../../domain/usecases/booking_usecases.dart';
import 'booking_usecase_providers.dart';

class BookingState {
  const BookingState({
    this.isLoading = false,
    this.error,
    this.successResponse,
  });

  final bool isLoading;
  final String? error;
  final BookingResponse? successResponse;

  BookingState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    BookingResponse? successResponse,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successResponse: successResponse ?? this.successResponse,
    );
  }
}

final bookingProvider =
    StateNotifierProvider.autoDispose<BookingNotifier, BookingState>((ref) {
      return BookingNotifier(ref.watch(createBookingUseCaseProvider));
    });

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier(this._createBooking) : super(const BookingState());

  final CreateBookingUseCase _createBooking;

  Future<void> submitBooking({
    required BookingRequest request,
    required String propertyTitle,
    required double price,
    required String location,
    String? thumbnailUrl,
    String? roomNumber,
    String? billingCycle,
    String? universityName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _createBooking(
        request,
        propertyTitle,
        price,
        location,
        thumbnailUrl,
        roomNumber,
        billingCycle,
        universityName,
      );
      state = state.copyWith(isLoading: false, successResponse: response);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
