import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../properties/presentation/providers/saved_properties_provider.dart';
import '../../../properties/domain/usecases/favorites_usecases.dart';
import '../../../properties/presentation/providers/favorites_providers.dart';
import '../../../bookings/data/repositories/booking_repository_impl.dart';
import '../../../bookings/domain/usecases/booking_usecases.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/fcm_service.dart';

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);
final checkAuthStatusUseCaseProvider = Provider(
  (ref) => CheckAuthStatusUseCase(ref.watch(authRepositoryProvider)),
);
final updateProfileUseCaseProvider = Provider(
  (ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)),
);
final changePasswordUseCaseProvider = Provider(
  (ref) => ChangePasswordUseCase(ref.watch(authRepositoryProvider)),
);
final forgotPasswordUseCaseProvider = Provider(
  (ref) => ForgotPasswordUseCase(ref.watch(authRepositoryProvider)),
);
final resetPasswordUseCaseProvider = Provider(
  (ref) => ResetPasswordUseCase(ref.watch(authRepositoryProvider)),
);
final deleteAccountUseCaseProvider = Provider(
  (ref) => DeleteAccountUseCase(ref.watch(authRepositoryProvider)),
);
final googleSignInUseCaseProvider = Provider(
  (ref) => GoogleSignInUseCase(ref.watch(authRepositoryProvider)),
);
final appleSignInUseCaseProvider = Provider(
  (ref) => AppleSignInUseCase(ref.watch(authRepositoryProvider)),
);

// ── Clear-on-logout use cases ─────────────────────────────────────────────────
// Defined here to avoid circular imports. Both booking and favorites files
// do not import auth_provider, so this direction is safe.
final clearLocalFavoritesUseCaseProvider = Provider(
  (ref) => ClearLocalFavoritesUseCase(ref.watch(favoritesRepositoryProvider)),
);
final clearLocalBookingsUseCaseProvider = Provider(
  (ref) => ClearLocalBookingsUseCase(ref.watch(bookingRepositoryProvider)),
);

// ── State ─────────────────────────────────────────────────────────────────────
class AuthState {
  const AuthState({this.user, this.isLoading = true, this.error});
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  bool get isAuthenticated => user != null;
  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(registerUseCaseProvider),
    ref.watch(logoutUseCaseProvider),
    ref.watch(checkAuthStatusUseCaseProvider),
    ref.watch(updateProfileUseCaseProvider),
    ref.watch(changePasswordUseCaseProvider),
    ref.watch(forgotPasswordUseCaseProvider),
    ref.watch(resetPasswordUseCaseProvider),
    ref.watch(deleteAccountUseCaseProvider),
    ref.watch(googleSignInUseCaseProvider),
    ref.watch(appleSignInUseCaseProvider),
    ref.watch(clearLocalFavoritesUseCaseProvider),
    ref.watch(clearLocalBookingsUseCaseProvider),
    ref,
  )..checkAuthStatus();
});

// ── Notifier ──────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._checkAuthStatusUseCase,
    this._updateProfileUseCase,
    this._changePasswordUseCase,
    this._forgotPasswordUseCase,
    this._resetPasswordUseCase,
    this._deleteAccountUseCase,
    this._googleSignInUseCase,
    this._appleSignInUseCase,
    this._clearLocalFavoritesUseCase,
    this._clearLocalBookingsUseCase,
    this._ref,
  ) : super(const AuthState());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AppleSignInUseCase _appleSignInUseCase;
  final ClearLocalFavoritesUseCase _clearLocalFavoritesUseCase;
  final ClearLocalBookingsUseCase _clearLocalBookingsUseCase;
  final Ref _ref;

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _checkAuthStatusUseCase();
      state = state.copyWith(user: user, isLoading: false);
      // Note: FCM initialization for restored sessions is omitted here to avoid
      // unprofessional native permission prompts popping up on Splash or Onboarding screens.
      // It is handled cleanly via initFcmToken() when entering the MainShell.
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Requests notification permissions and synchronizes the FCM token sequentially.
  /// Call this when the user arrives on the main application view to keep the onboarding clean.
  Future<void> initFcmToken() async {
    if (state.user != null) {
      try {
        final dio = _ref.read(dioProvider);
        await FcmService().requestPermission();
        await FcmService().init(dio);
      } catch (_) {
        // Fail silently in production to guarantee auth flows never break due to network drops
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _loginUseCase(email, password);
      state = state.copyWith(user: response.user, isLoading: false);
      _syncGuestData();

      // Request notification permission and register FCM token securely now that a valid auth session exists.
      final dio = _ref.read(dioProvider);
      await FcmService().requestPermission();
      await FcmService().init(dio);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _registerUseCase(name, email, password);
      state = state.copyWith(user: response.user, isLoading: false);
      _syncGuestData();

      // Request notification permission and register FCM token sequentially for the new account.
      final dio = _ref.read(dioProvider);
      await FcmService().requestPermission();
      await FcmService().init(dio);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    // 1. Trigger the loading overlay
    state = state.copyWith(isLoading: true);
    // 2. UX Polish: The local logout is so fast (< 5ms) that the user never sees
    // the loading overlay. We add a short artificial delay here so the user
    // sees the secure logout blur animation, confirming the action worked.
    await Future.delayed(const Duration(milliseconds: 600));
    // 3. Remove this device's FCM token from the backend BEFORE invalidating
    // the session — dio still carries a valid Bearer token at this point.
    // Awaiting here ensures clean state removal; errors caught to prevent blocking flows.
    final dio = _ref.read(dioProvider);
    try {
      await FcmService().removeFcmToken(dio);
    } catch (_) {}
    // 4. Perform the actual logout (invalidates the token on the server)
    await _logoutUseCase();
    // 5. Wipe all locally cached user data so the next guest session starts
    // with a clean slate. This must happen BEFORE clearUser is set — that
    // flip triggers provider rebuilds which call load(), and by then
    // SharedPreferences must already be empty.
    await Future.wait([
      _clearLocalFavoritesUseCase(),
      _clearLocalBookingsUseCase(),
    ]);
    // 6. Clear the in-memory user → isAuthenticated becomes false →
    // savedPropertiesProvider and myBookingsProvider rebuild and call
    // load() which now reads empty SharedPreferences → empty UI ✓
    state = state.copyWith(clearUser: true, isLoading: false);
  }

  Future<bool> updateProfile(String name, String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await _updateProfileUseCase(name: name, email: email);
      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _changePasswordUseCase(currentPassword, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _forgotPasswordUseCase(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _resetPasswordUseCase(email, otp, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _deleteAccountUseCase();
      state = state.copyWith(clearUser: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _googleSignInUseCase();
      state = state.copyWith(user: response.user, isLoading: false);
      _syncGuestData();

      // Register FCM token sequentially now that a valid auth session exists.
      final dio = _ref.read(dioProvider);
      await FcmService().requestPermission();
      await FcmService().init(dio);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> appleSignIn() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _appleSignInUseCase();
      state = state.copyWith(user: response.user, isLoading: false);
      _syncGuestData();

      // Register FCM token sequentially now that a valid auth session exists.
      final dio = _ref.read(dioProvider);
      await FcmService().requestPermission();
      await FcmService().init(dio);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void _syncGuestData() {
    // 1. Updated to call syncData() instead of syncGuestData()
    _ref.read(savedPropertiesProvider.notifier).syncData().catchError((_) {});
    // 2. Booking repository remains unchanged
    _ref.read(bookingRepositoryProvider).syncGuestData().catchError((_) {});
  }
}
