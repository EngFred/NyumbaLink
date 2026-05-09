import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/bookings/presentation/pages/my_bookings_page.dart';
import '../../features/complaints/presentation/pages/complaint_page.dart';
import '../../features/properties/presentation/pages/browse_page.dart';
import '../../features/properties/presentation/pages/property_detail_page.dart';
import '../../features/properties/presentation/pages/hostel_rooms_page.dart';
import '../../features/properties/presentation/pages/saved_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../constants/app_constants.dart';
import '../widgets/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
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
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.browse,
          name: 'browse',
          builder: (context, state) => const BrowsePage(),
        ),
        GoRoute(
          path: '/saved',
          name: 'saved',
          builder: (context, state) => const SavedPage(),
        ),
        GoRoute(
          path: '/bookings',
          name: 'bookings',
          builder: (context, state) => const MyBookingsPage(),
        ),
      ],
    ),
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
    GoRoute(
      path: AppRoutes.hostelRooms,
      name: 'hostelRooms',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final title = state.extra as String? ?? 'Hostel Rooms';
        return MaterialPage(
          key: state.pageKey,
          child: HostelRoomsPage(propertyId: id, propertyTitle: title),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.booking,
      name: 'booking',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
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
    GoRoute(
      path: '/complaint',
      name: 'complaint',
      pageBuilder: (context, state) {
        final extra = (state.extra as Map<String, dynamic>?) ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: ComplaintPage(
            propertyId: extra['propertyId'] as String?,
            propertyTitle: extra['propertyTitle'] as String?,
          ),
          transitionsBuilder: _slideUpTransition,
        );
      },
    ),
  ],
);

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
