import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/account/presentation/pages/about_page.dart';
import '../../features/account/presentation/pages/account_page.dart';
import '../../features/account/presentation/pages/change_password_page.dart';
import '../../features/account/presentation/pages/edit_profile_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/bookings/presentation/pages/booking_page.dart';
import '../../features/bookings/presentation/pages/my_bookings_page.dart';
import '../../features/complaints/presentation/pages/complaint_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/properties/presentation/pages/browse_page.dart';
import '../../features/properties/presentation/pages/hostel_rooms_page.dart';
import '../../features/properties/presentation/pages/property_detail_page.dart';
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
    // ── Onboarding ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingPage(),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    // ── Auth ──────────────────────────────────────────────────────────────────
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
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ForgotPasswordPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: 'resetPassword',
      pageBuilder: (context, state) {
        final email = state.extra as String? ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: ResetPasswordPage(email: email),
          transitionsBuilder: _slideUpTransition,
        );
      },
    ),
    // ── Deep link redirect ────────────────────────────────────────────────────
    GoRoute(
      path: '/p/:id',
      name: 'propertyDeepLink',
      redirect: (context, state) {
        final id = state.pathParameters['id'];
        if (id != null && id.isNotEmpty) return '/properties/$id';
        return AppRoutes.browse;
      },
    ),
    // ── Main shell (bottom nav tabs) ──────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.browse,
              name: 'browse',
              builder: (context, state) => const BrowsePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              name: 'saved',
              builder: (context, state) => const SavedPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookings',
              name: 'bookings',
              builder: (context, state) => const MyBookingsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              name: 'account',
              builder: (context, state) => const AccountPage(),
            ),
          ],
        ),
      ],
    ),
    // ── Property detail & rooms ───────────────────────────────────────────────
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
            // ── NEW FIXES: Parsing the required fields from the extra map ──
            price: (extra['price'] as num?)?.toDouble() ?? 0.0,
            location: extra['location'] as String? ?? '',
            imageUrl: extra['imageUrl'] as String?,
            // ─────────────────────────────────────────────────────────────────
            hostelRoomId: extra['hostelRoomId'] as String?,
            roomNumber: extra['roomNumber'] as String?,
          ),
          transitionsBuilder: _slideUpTransition,
        );
      },
    ),
    // ── Other routes ──────────────────────────────────────────────────────────
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
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NotificationsPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'editProfile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EditProfilePage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: '/change-password',
      name: 'changePassword',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ChangePasswordPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AboutPage(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
  ],
);

// ── Transition helpers ────────────────────────────────────────────────────────
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

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}
