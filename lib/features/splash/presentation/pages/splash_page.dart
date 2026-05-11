import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
    // Delay bootstrap execution until after the widget tree finishes building
    // This prevents the "Tried to modify a provider..." Riverpod crash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    // Let the splash breathe for at least 2.2s while auth resolves
    await Future.wait([
      ref.read(authProvider.notifier).checkAuthStatus(),
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);

    if (!mounted) return;

    // The API allows guest users (unauthenticated) to browse listings, view property
    // details, submit booking requests, and file complaints.
    // Therefore, we drop everyone directly into the Browse page.
    context.go(AppRoutes.browse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF1A3A6B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // ── Logo mark ──────────────────────────────────────────────
              Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 28),
              // ── Brand name ─────────────────────────────────────────────
              RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nyumba',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Link',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                    'Your home, simplified.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: Colors.white.withOpacity(0.65),
                      letterSpacing: 0.3,
                    ),
                  )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
              const Spacer(flex: 2),
              // ── Loading indicator ──────────────────────────────────────
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    color: Colors.white.withOpacity(0.7),
                    minHeight: 3,
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
