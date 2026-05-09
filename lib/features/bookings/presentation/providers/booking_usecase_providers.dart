import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/usecases/booking_usecases.dart';

final createBookingUseCaseProvider = Provider<CreateBookingUseCase>((ref) {
  return CreateBookingUseCase(ref.watch(bookingRepositoryProvider));
});

final cancelBookingUseCaseProvider = Provider<CancelBookingUseCase>((ref) {
  return CancelBookingUseCase(ref.watch(bookingRepositoryProvider));
});

final getMyBookingsUseCaseProvider = Provider<GetMyBookingsUseCase>((ref) {
  return GetMyBookingsUseCase(ref.watch(bookingRepositoryProvider));
});
