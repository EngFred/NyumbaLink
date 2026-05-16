import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart'; // Needed for casting to save locally

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await _remoteDataSource.login(email, password);
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as AuthUserModel,
    );
    return response;
  }

  @override
  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _remoteDataSource.register(name, email, password);
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as AuthUserModel,
    );
    return response;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAuthData();
  }

  @override
  Future<AuthUser?> getCachedUser() async {
    return _localDataSource.getUser();
  }

  @override
  Future<String?> getCachedToken() async {
    return _localDataSource.getToken();
  }

  @override
  Future<AuthUser> updateProfile({String? name, String? email}) async {
    final Map<String, dynamic> data = {};
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (email != null && email.isNotEmpty) data['email'] = email;

    final updatedUser = await _remoteDataSource.updateProfile(data);

    // We must also update the local cache so the UI reflects it instantly
    final token = await _localDataSource.getToken();
    if (token != null) {
      await _localDataSource.saveAuthData(token, updatedUser);
    }

    return updatedUser;
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _remoteDataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await _remoteDataSource.resetPassword(email, otp, newPassword);
  }
}
