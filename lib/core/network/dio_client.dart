import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rentora/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) => _buildDio());

// ── Factory ───────────────────────────────────────────────────────────────────

Dio _buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ── Inject Bearer Token Interceptor ──
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AuthLocalDataSource.tokenKey);

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  // Log in debug mode only
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        logPrint: (o) => debugLog(o.toString()),
      ),
    );
    return true;
  }());

  return dio;
}

void debugLog(String msg) {
  // ignore: avoid_print
  print('[NyumbaLink] $msg');
}

// ── Helper: map DioException → AppException ───────────────────────────────────

AppException handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();

    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      final data = e.response?.data;

      // Extract message from NestJS error response
      String msg = 'Something went wrong.';
      if (data is Map) {
        final raw = data['message'];
        if (raw is List) {
          msg = raw.join(', ');
        } else if (raw is String) {
          msg = raw;
        }
      }

      if (status == 401) {
        return ServerException(msg, statusCode: status);
      }

      if (status == 404) return NotFoundException(msg);
      return ServerException(msg, statusCode: status);

    default:
      return const UnexpectedException();
  }
}
