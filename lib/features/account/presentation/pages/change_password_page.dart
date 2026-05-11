import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  // Simple strength from 0–4
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          children: [
            // ── Security icon ────────────────────────────────────────────
            Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFF1A3A6B)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),

            const Gap(12),
            Center(
              child: Text(
                'Keep your account secure',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const Gap(28),

            // ── Current password ─────────────────────────────────────────
            _PwSection(
                  number: '01',
                  title: 'Current Password',
                  icon: Icons.lock_open_outlined,
                  children: [
                    _PwField(
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
                  ],
                )
                .animate(delay: 80.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(16),

            // ── New password ─────────────────────────────────────────────
            _PwSection(
                  number: '02',
                  title: 'New Password',
                  icon: Icons.lock_outline_rounded,
                  children: [
                    _PwField(
                      controller: _newCtrl,
                      label: 'New Password',
                      hint: 'At least 6 characters',
                      obscure: _obscureNew,
                      enabled: !isLoading,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),
                    // Strength indicator
                    if (_newCtrl.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                            const Gap(4),
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
                    const Divider(
                      height: 1,
                      color: AppColors.grey100,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _PwField(
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
                .animate(delay: 130.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(32),

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
            ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _PwSection extends StatelessWidget {
  const _PwSection({
    required this.number,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String number;
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Gap(10),
                Icon(icon, size: 17, color: AppColors.primary),
                const Gap(6),
                Text(title, style: AppTextStyles.h4),
              ],
            ),
          ),
          const Gap(4),
          const Divider(color: AppColors.grey100, height: 1),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  const _PwField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.enabled,
    required this.onToggle,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final bool enabled;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscure,
                  enabled: enabled,
                  onChanged: onChanged,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  validator: validator,
                ),
              ),
              IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.grey500,
                ),
                onPressed: onToggle,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
