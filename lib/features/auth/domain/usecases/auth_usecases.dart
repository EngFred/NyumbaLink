import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthResponse> call(String email, String password) =>
      _repo.login(email, password);
}

class RegisterUseCase {
  const RegisterUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthResponse> call(String name, String email, String password) =>
      _repo.register(name, email, password);
}

class LogoutUseCase {
  const LogoutUseCase(this._repo);
  final AuthRepository _repo;
  Future<void> call() => _repo.logout();
}

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthUser?> call() => _repo.getCachedUser();
}

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthUser> call({String? name, String? email}) =>
      _repo.updateProfile(name: name, email: email);
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repo);
  final AuthRepository _repo;
  Future<void> call(String currentPassword, String newPassword) =>
      _repo.changePassword(currentPassword, newPassword);
}

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repo);
  final AuthRepository _repo;
  Future<void> call(String email) => _repo.forgotPassword(email);
}

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repo);
  final AuthRepository _repo;
  Future<void> call(String email, String otp, String newPassword) =>
      _repo.resetPassword(email, otp, newPassword);
}

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repo);
  final AuthRepository _repo;
  Future<void> call() => _repo.deleteAccount();
}

class GoogleSignInUseCase {
  const GoogleSignInUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthResponse> call() => _repo.googleSignIn();
}

class AppleSignInUseCase {
  const AppleSignInUseCase(this._repo);
  final AuthRepository _repo;
  Future<AuthResponse> call() => _repo.appleSignIn();
}
