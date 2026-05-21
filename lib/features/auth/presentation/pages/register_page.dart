import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/auth/presentation/widgets/auth_field.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_hero.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_section.dart';
import 'package:rentora/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:rentora/features/auth/presentation/widgets/submit_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/validators/password_validator.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(authProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) context.go('/browse');
    }
  }

  void _googleSignIn() async {
    final success = await ref.read(authProvider.notifier).googleSignIn();
    if (success && mounted) context.go('/browse');
  }

  void _appleSignIn() async {
    final success = await ref.read(authProvider.notifier).appleSignIn();
    if (success && mounted) context.go('/browse');
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
          const AuthHero(
            title: 'Create account',
            subtitle: 'Find your perfect home in Uganda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthSection(
                          children: [
                            AuthField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              icon: Icons.person_outline_rounded,
                              capitalization: TextCapitalization.words,
                              action: TextInputAction.next,
                              enabled: !isLoading,
                              validator: (v) => (v?.trim().isEmpty ?? true)
                                  ? 'Name is required'
                                  : null,
                            ),
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

                    AuthSection(
                          children: [
                            AuthField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'At least 8 characters',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              action: TextInputAction.next,
                              enabled: !isLoading,
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
                              // ✅ Delegates to the domain validator
                              validator: PasswordValidator.validate,
                            ),
                            AuthField(
                              controller: _confirmController,
                              label: 'Confirm Password',
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirm,
                              action: TextInputAction.done,
                              enabled: !isLoading,
                              onFieldSubmitted: (_) => _submit(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: AppColors.grey500,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              validator: (v) => v != _passwordController.text
                                  ? 'Passwords do not match'
                                  : null,
                            ),
                          ],
                        )
                        .animate(delay: 60.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),

                    const Gap(12),

                    SubmitButton(
                          isLoading: isLoading,
                          label: 'Create Account',
                          icon: Icons.person_add_rounded,
                          onPressed: _submit,
                        )
                        .animate(delay: 120.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),

                    const Gap(24),

                    // ── Social Auth ───────────────────────────────────────
                    SocialAuthButtons(
                      isLoading: isLoading,
                      onGoogleTap: _googleSignIn,
                      onAppleTap: _appleSignIn,
                    ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

                    const Gap(32),

                    AuthFooterLink(
                      message: 'Already have an account? ',
                      linkText: 'Sign in',
                      onTap: isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
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
