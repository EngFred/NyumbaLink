import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

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
    // Cast to model so we can access the toJson method
    await _localDataSource.saveAuthData(
      response.accessToken,
      response.user as dynamic,
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
      response.user as dynamic,
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
}
