abstract final class AppConstants {
  AppConstants._();

  // ─── API ──────────────────────────────────────────────────────────────────
  static const String baseUrl =
      'https://rentfinda-api-production.up.railway.app/api/v1';

  // ─── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'NyumbaLink';
  static const String appTagline = 'Find your perfect home in Uganda';

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 12;

  // ─── Geospatial ───────────────────────────────────────────────────────────
  static const double defaultRadiusKm = 5.0;

  // ─── Timeouts ─────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Splash ───────────────────────────────────────────────────────────────
  static const Duration splashDuration = Duration(seconds: 2);
}

/// Route path constants — single source of truth.
/// Use these everywhere instead of raw strings.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String browse = '/browse';
  static const String propertyDetail = '/properties/:id';
  static const String hostelRooms = '/properties/:id/rooms';
  static const String booking = '/properties/:id/book';
  static const String login = '/login';
  static const String register = '/register';

  /// Build property detail path with a real id.
  static String propertyDetailPath(String id) => '/properties/$id';

  /// Build hostel rooms path with a real id.
  static String hostelRoomsPath(String id) => '/properties/$id/rooms';

  /// Build booking path with a real property id.
  static String bookingPath(String id) => '/properties/$id/book';
}
