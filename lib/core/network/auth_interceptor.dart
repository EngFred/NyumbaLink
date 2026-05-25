// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:rentora/core/router/app_router.dart';
// import 'package:rentora/core/constants/app_constants.dart';
// import '../../features/auth/presentation/providers/auth_provider.dart';

// class AuthInterceptor extends Interceptor {
//   AuthInterceptor(this._ref);

//   final Ref _ref;

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     final hadToken = err.requestOptions.headers['Authorization'] != null;
//     final isAuthenticated = _ref.read(authProvider).isAuthenticated;

//     if (err.response?.statusCode == 401 && hadToken && isAuthenticated) {
//       _ref.read(authProvider.notifier).logout().then((_) {
//         appRouter.go(AppRoutes.login);
//       });
//     }

//     handler.next(err);
//   }
// }
