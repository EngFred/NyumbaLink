/// Base exception for all app-level errors.
class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thrown when there is no internet / the request times out.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// Thrown for 4xx / 5xx responses from the server.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// 404 — resource not found.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}

/// Generic unexpected error.
class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
