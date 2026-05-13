import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/universities_datasource.dart';
import '../../data/repositories/universities_repository_impl.dart';
import '../../domain/entities/university.dart';
import '../../domain/repositories/universities_repository.dart';
import '../../domain/usecases/get_universities.dart';

// DataSource
final universitiesRemoteDataSourceProvider =
    Provider<UniversitiesRemoteDataSource>(
      (ref) => UniversitiesRemoteDataSource(ref.watch(dioProvider)),
    );

// Repository
final universitiesRepositoryProvider = Provider<UniversitiesRepository>(
  (ref) => UniversitiesRepositoryImpl(
    ref.watch(universitiesRemoteDataSourceProvider),
  ),
);

// UseCase
final getUniversitiesProvider = Provider<GetUniversities>(
  (ref) => GetUniversities(ref.watch(universitiesRepositoryProvider)),
);

// UI Provider
final universitiesProvider = FutureProvider.autoDispose<List<University>>((
  ref,
) async {
  return ref.watch(getUniversitiesProvider).call();
});
