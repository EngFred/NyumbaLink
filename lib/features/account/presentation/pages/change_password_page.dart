import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/account/presentation/widgets/change-password/pw_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  int get _strength {
    final v = _newCtrl.text;
    int s = 0;
    if (v.length >= 6) s++;
    if (v.length >= 10) s++;
    if (v.contains(RegExp(r'[A-Z]'))) s++;
    if (v.contains(RegExp(r'[0-9!@#\$%^&*]'))) s++;
    return s;
  }

  Color get _strengthColor {
    return switch (_strength) {
      0 || 1 => AppColors.error,
      2 => AppColors.accent,
      3 => const Color(0xFFEAB308),
      _ => AppColors.success,
    };
  }

  String get _strengthLabel {
    return switch (_strength) {
      0 || 1 => 'Weak',
      2 => 'Fair',
      3 => 'Good',
      _ => 'Strong',
    };
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(authProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authProvider.notifier)
          .changePassword(_currentCtrl.text, _newCtrl.text);
      if (success && mounted) {
        AppSnackbar.success(context, 'Password changed successfully');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        AppSnackbar.error(context, next.error!);
      }
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Change Password', style: AppTextStyles.h4),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.grey200),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          children: [
            Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'Keep your account secure',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 400.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(),

            const Gap(40),

            // ── Standalone Fields ──────────────────────────────────────────
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PwField(
                      controller: _currentCtrl,
                      label: 'Current Password',
                      hint: 'Enter your current password',
                      obscure: _obscureCurrent,
                      enabled: !isLoading,
                      onToggle: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                    ),

                    PwField(
                      controller: _newCtrl,
                      label: 'New Password',
                      hint: 'At least 8 characters',
                      obscure: _obscureNew,
                      enabled: !isLoading,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.length < 8)
                          return 'At least 8 characters';
                        return null;
                      },
                    ),

                    if (_newCtrl.text.isNotEmpty)
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(4, (i) {
                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: i < 3 ? 4 : 0,
                                      ),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: i < _strength
                                            ? _strengthColor
                                            : AppColors.grey200,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const Gap(6),
                              Text(
                                'Strength: $_strengthLabel',
                                style: AppTextStyles.caption.copyWith(
                                  color: _strengthColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    PwField(
                      controller: _confirmCtrl,
                      label: 'Confirm New Password',
                      hint: 'Re-enter your new password',
                      obscure: _obscureConfirm,
                      enabled: !isLoading,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) =>
                          v != _newCtrl.text ? 'Passwords do not match' : null,
                    ),
                  ],
                )
                .animate(delay: 80.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(24),

            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 18),
                        Gap(10),
                        Text('Update Password'),
                      ],
                    ),
            ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
