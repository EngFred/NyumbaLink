import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/property_repository_impl.dart';
import '../../domain/usecases/property_usecases.dart';

final getPropertiesUseCaseProvider = Provider(
  (ref) => GetPropertiesUseCase(ref.watch(propertyRepositoryProvider)),
);
final getPropertyDetailsUseCaseProvider = Provider(
  (ref) => GetPropertyDetailsUseCase(ref.watch(propertyRepositoryProvider)),
);
final incrementEnquiryUseCaseProvider = Provider(
  (ref) => IncrementEnquiryUseCase(ref.watch(propertyRepositoryProvider)),
);
final getHostelRoomsUseCaseProvider = Provider(
  (ref) => GetHostelRoomsUseCase(ref.watch(propertyRepositoryProvider)),
);
final getHostelStatsUseCaseProvider = Provider(
  (ref) => GetHostelStatsUseCase(ref.watch(propertyRepositoryProvider)),
);
