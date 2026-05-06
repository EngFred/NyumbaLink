import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/properties/presentation/pages/browse_page.dart';
import '../../features/properties/presentation/pages/property_detail_page.dart';
import '../../features/properties/presentation/pages/hostel_rooms_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../constants/app_constants.dart';
import '../widgets/main_shell.dart';

/// The top-level router for NyumbaLink.
///
/// Navigation structure:
///
///  /              → SplashPage  (initial, auto-redirects after 2s)
///  ShellRoute     → MainShell  (bottom navigation bar)
///    /browse      → BrowsePage
///    /saved       → SavedPage  (placeholder)
///    /account     → AccountPage (placeholder → login/register)
///  /properties/:id        → PropertyDetailPage (full-screen push)
///  /properties/:id/rooms  → HostelRoomsPage    (full-screen push)
///  /properties/:id/book   → BookingPage        (full-screen push)
///  /login                 → LoginPage
///  /register              → RegisterPage
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Splash ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // ── Auth ───────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RegisterPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),

    // ── Main Shell (Bottom Nav) ─────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.browse,
          name: 'browse',
          builder: (context, state) => const BrowsePage(),
        ),
        // Saved & Account tabs navigate here but are placeholders
        GoRoute(
          path: '/saved',
          name: 'saved',
          builder: (context, state) => const _PlaceholderPage(label: 'Saved'),
        ),
        GoRoute(
          path: '/account',
          name: 'account',
          builder: (context, state) => const _PlaceholderPage(label: 'Account'),
        ),
      ],
    ),

    // ── Property Detail ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.propertyDetail,
      name: 'propertyDetail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(
          key: state.pageKey,
          child: PropertyDetailPage(propertyId: id),
        );
      },
    ),

    // ── Hostel Rooms ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.hostelRooms,
      name: 'hostelRooms',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        // Pass the property title via extra for the app bar
        final title = state.extra as String? ?? 'Hostel Rooms';
        return MaterialPage(
          key: state.pageKey,
          child: HostelRoomsPage(propertyId: id, propertyTitle: title),
        );
      },
    ),

    // ── Booking ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.booking,
      name: 'booking',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        // extra: Map<String, dynamic> with { title, hostelRoomId?, roomNumber? }
        final extra = (state.extra as Map<String, dynamic>?) ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: BookingPage(
            propertyId: id,
            propertyTitle: extra['title'] as String? ?? '',
            hostelRoomId: extra['hostelRoomId'] as String?,
            roomNumber: extra['roomNumber'] as String?,
          ),
          transitionsBuilder: _slideUpTransition,
        );
      },
    ),
  ],
);

// ─── Shared transition builders ─────────────────────────────────────────────

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

/// Temporary placeholder tab for tabs not yet built.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$label — coming soon',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
