import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String name, String email, String password);
  Future<void> logout();
  Future<AuthUser?> getCachedUser();
  Future<String?> getCachedToken();

  Future<AuthUser> updateProfile({String? name, String? email});
  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);

  /// Schedules permanent account deletion. Clears local session data.
  Future<void> deleteAccount();
}
