import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_field.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_hero.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_section.dart';
import 'package:rentora/features/auth/presentation/widgets/submit_button.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(authProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      if (success && mounted) context.go('/browse');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        AppSnackbar.error(context, next.error!);
      }
    });
    final isLoading = ref.watch(authProvider).isLoading;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Hero header ───────────────────────────────────────────────
          const AuthHero(
            title: 'Welcome back',
            subtitle: 'Sign in to continue your search',
          ),
          // ── Form body ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Email ──────────────────────────────────────────
                    AuthSection(
                          children: [
                            AuthField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                              inputType: TextInputType.emailAddress,
                              action: TextInputAction.next,
                              enabled: !isLoading,
                              validator: (v) => (v?.trim().isEmpty ?? true)
                                  ? 'Email is required'
                                  : null,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    const Gap(16),
                    // ── Password ───────────────────────────────────────
                    AuthSection(
                          children: [
                            AuthField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              enabled: !isLoading,
                              action: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: AppColors.grey500,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (v) => (v?.isEmpty ?? true)
                                  ? 'Password is required'
                                  : null,
                            ),
                          ],
                        )
                        .animate(delay: 60.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    // ── Forgot password ────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : () {},
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
                    const Gap(8),
                    // ── Submit ─────────────────────────────────────────
                    SubmitButton(
                          isLoading: isLoading,
                          label: 'Sign In',
                          icon: Icons.login_rounded,
                          onPressed: _submit,
                        )
                        .animate(delay: 140.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    const Gap(28),
                    // ── Register link ──────────────────────────────────
                    AuthFooterLink(
                      message: "Don't have an account? ",
                      linkText: 'Sign up',
                      onTap: isLoading
                          ? null
                          : () => context.go(AppRoutes.register),
                    ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
