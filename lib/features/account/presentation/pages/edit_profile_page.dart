import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:rentora/features/account/presentation/widgets/edit-profile/profile_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});
  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  void _submit() async {
    if (ref.read(authProvider).isLoading) return;
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authProvider.notifier)
          .updateProfile(
            _nameController.text.trim(),
            _emailController.text.trim(),
          );
      if (success && mounted) {
        AppSnackbar.success(context, 'Profile updated successfully');
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
        title: Text('Edit Profile', style: AppTextStyles.h4),
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
                  child: ValueListenableBuilder(
                    valueListenable: _nameController,
                    builder: (_, value, __) {
                      return Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.08),
                            ),
                            child: Center(
                              child: Text(
                                _initials(value.text),
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),
                          Text(
                            'Your display name drives\nthe initials above',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textHint,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                )
                .animate()
                .fadeIn(duration: 350.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 350.ms,
                  curve: Curves.easeOut,
                ),

            const Gap(40),

            // ── Standalone Fields ──────────────────────────────────────────
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.badge_outlined,
                      enabled: !isLoading,
                      capitalization: TextCapitalization.words,
                      validator: (v) => (v?.trim().length ?? 0) < 2
                          ? 'Name is too short'
                          : null,
                    ),

                    ProfileField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      enabled: false,
                      inputType: TextInputType.emailAddress,
                    ),

                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: AppColors.textHint.withOpacity(0.8),
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              'Email address edit is currently not available.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textHint,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                .animate(delay: 80.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.04, end: 0),

            const Gap(40),

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
                        Icon(Icons.save_rounded, size: 18),
                        Gap(10),
                        Text('Save Changes'),
                      ],
                    ),
            ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
