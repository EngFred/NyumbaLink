import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _onboardingKey = 'rentora_onboarding_complete';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    // Run auth check and minimum splash duration in parallel
    final results = await Future.wait([
      ref.read(authProvider.notifier).checkAuthStatus(),
      Future.delayed(const Duration(milliseconds: 2200)),
      SharedPreferences.getInstance(),
    ]);

    if (!mounted) return;

    final prefs = results[2] as SharedPreferences;
    final onboardingSeen = prefs.getBool(_onboardingKey) ?? false;

    if (!onboardingSeen) {
      context.go('/onboarding');
    } else {
      context.go(AppRoutes.browse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
            Image.asset(
                  'assets/images/logo_with_title.jpeg',
                  width: MediaQuery.of(context).size.width * 0.65,
                  fit: BoxFit.contain,
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                ),
      ),
    );
  }
}
