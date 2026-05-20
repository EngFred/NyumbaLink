import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/saved_property.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_providers.dart';

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
  }) {
    return SavedPropertiesState(
      savedList: savedList ?? this.savedList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

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
        notifier.load();
      }

      return notifier;
    });

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

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await getFavorites();
      state = state.copyWith(savedList: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleSave(SavedProperty property) async {
    await toggleFavoriteUseCase(property, isAuthenticated: isAuthenticated);
    await load();
  }

  bool isSaved(String propertyId) =>
      state.savedList.any((p) => p.id == propertyId);

  Future<void> syncData() async {
    state = state.copyWith(isLoading: true);
    await syncFavoritesUseCase();
    await load();
  }
}
