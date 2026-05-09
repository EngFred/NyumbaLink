import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String name, String email, String password);
  Future<void> logout();
  Future<AuthUser?> getCachedUser();
  Future<String?> getCachedToken();

  Future<AuthUser> updateProfile({String? name, String? email});
  Future<void> changePassword(String currentPassword, String newPassword);
}
