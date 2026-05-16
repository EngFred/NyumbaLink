import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_field.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_hero.dart';
import 'package:rentora/features/auth/presentation/widgets/auth_section.dart';
import 'package:rentora/features/auth/presentation/widgets/submit_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(authProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final success = await ref
          .read(authProvider.notifier)
          .forgotPassword(email);

      if (success && mounted) {
        // Matches the backend 200 response intent perfectly
        AppSnackbar.success(
          context,
          'If that email is registered, you will receive a reset code shortly.',
        );
        context.push('/reset-password', extra: email);
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
            title: 'Reset Password',
            subtitle: 'Enter your email to receive a recovery code',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthSection(
                          children: [
                            AuthField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                              inputType: TextInputType.emailAddress,
                              action: TextInputAction.done,
                              enabled: !isLoading,
                              onFieldSubmitted: (_) => _submit(),
                              validator: (v) => !(v?.contains('@') ?? false)
                                  ? 'Enter a valid email address'
                                  : null,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    const Gap(24),
                    SubmitButton(
                          isLoading: isLoading,
                          label: 'Send Reset Code',
                          icon: Icons.send_rounded,
                          onPressed: _submit,
                        )
                        .animate(delay: 60.ms)
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
