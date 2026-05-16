import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<AuthUserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: data,
      );
      return AuthUserModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _dio.patch(
        '/users/me/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }

  /// Schedules permanent account deletion (30-day grace period).
  /// The server immediately invalidates the token, so the local session
  /// must be cleared after this call.
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/users/me');
    } on DioException catch (e) {
      throw handleDioException(e);
    }
  }
}
