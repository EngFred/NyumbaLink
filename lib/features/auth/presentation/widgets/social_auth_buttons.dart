import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Renders the "or continue with" divider + Google/Apple outlined buttons.
/// Apple button is iOS-only per App Store guidelines.
///
/// Swap [_GoogleIcon] out for an SvgPicture if you add a Google SVG asset:
///   SvgPicture.asset('assets/images/google_logo.svg', width: 20)
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.isLoading,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final bool isLoading;
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Divider ───────────────────────────────────────────────────────
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.grey200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.grey200)),
          ],
        ),

        const Gap(16),

        // ── Google Button ─────────────────────────────────────────────────
        _SocialButton(
          label: 'Continue with Google',
          icon: const _GoogleIcon(),
          onTap: isLoading ? null : onGoogleTap,
        ),

        // ── Apple Button (iOS only) ────────────────────────────────────────
        if (Platform.isIOS) ...[
          const Gap(12),
          _SocialButton(
            label: 'Continue with Apple',
            icon: const Icon(
              Icons.apple,
              size: 22,
              color: AppColors.textPrimary,
            ),
            onTap: isLoading ? null : onAppleTap,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, this.onTap});

  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.grey200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        // Mirror the disabled style so it's visually consistent with SubmitButton
        disabledForegroundColor: AppColors.textSecondary,
        disabledBackgroundColor: AppColors.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const Gap(10),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: onTap != null
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Google "G" monogram icon. No official Material icon exists for Google,
// so we render a styled Text widget. Replace with SvgPicture if you have
// the asset: SvgPicture.asset('assets/images/google_logo.svg', width: 20)
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4), // Google Blue
          ),
        ),
      ),
    );
  }
}
