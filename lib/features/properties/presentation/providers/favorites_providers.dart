import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/favorites_local_datasource.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/favorites_usecases.dart';

// Needs to be overridden in main.dart or initialized beforehand
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((
  ref,
) {
  return FavoritesLocalDataSourceImpl(ref.watch(sharedPreferencesProvider));
});

final favoritesRemoteDataSourceProvider = Provider<FavoritesRemoteDataSource>((
  ref,
) {
  return FavoritesRemoteDataSourceImpl(ref.watch(dioProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    ref.watch(favoritesLocalDataSourceProvider),
    ref.watch(favoritesRemoteDataSourceProvider),
  );
});

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  return GetFavoritesUseCase(ref.watch(favoritesRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(favoritesRepositoryProvider));
});

final syncFavoritesUseCaseProvider = Provider<SyncFavoritesUseCase>((ref) {
  return SyncFavoritesUseCase(ref.watch(favoritesRepositoryProvider));
});
