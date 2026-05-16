import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_field.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_hero.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_section.dart';
import 'package:rentora/features/auth/presentation/widgets/field_divider.dart';
import 'package:rentora/features/auth/presentation/widgets/submit_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.email});
  final String email;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(authProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authProvider.notifier)
          .resetPassword(
            widget.email,
            _otpController.text.trim(),
            _passwordController.text,
          );

      if (success && mounted) {
        AppSnackbar.success(
          context,
          'Password reset successfully. You can now log in.',
        );
        // Navigate all the way back to login
        context.go('/login');
      }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const AuthHero(
            title: 'Create New Password',
            subtitle: 'Enter the 6-digit code sent to your email',
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
                              controller: _otpController,
                              label: 'Reset Code',
                              hint: 'Enter 6-digit OTP',
                              icon: Icons.dialpad_rounded,
                              inputType: TextInputType.number,
                              action: TextInputAction.next,
                              enabled: !isLoading,
                              validator: (v) => (v?.trim().length != 6)
                                  ? 'Please enter the 6-digit code'
                                  : null,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    const Gap(16),
                    AuthSection(
                          children: [
                            AuthField(
                              controller: _passwordController,
                              label: 'New Password',
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
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 8) {
                                  return 'At least 8 characters required';
                                }
                                if (!v.contains(RegExp(r'[A-Z]'))) {
                                  return 'Requires an uppercase letter';
                                }
                                if (!v.contains(RegExp(r'[0-9]'))) {
                                  return 'Requires a number';
                                }
                                return null;
                              },
                            ),
                            const FieldDivider(),
                            AuthField(
                              controller: _confirmController,
                              label: 'Confirm Password',
                              hint: 'Re-enter your new password',
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
                              validator: (v) {
                                if (v != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        )
                        .animate(delay: 60.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    const Gap(24),
                    SubmitButton(
                          isLoading: isLoading,
                          label: 'Reset Password',
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: _submit,
                        )
                        .animate(delay: 120.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
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
