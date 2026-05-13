import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ── Hero header shared by login + register ────────────────────────────────────

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 16, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1A3A6B)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Gap(24),

          // Brand mark
          Row(
            children: [
              Image.asset(
                'assets/images/no_bg.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              const Gap(5),
              Text(
                'Rentora',
                style: AppTextStyles.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(20),

          Text(
            title,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            subtitle,
            style: AppTextStyles.bodyMd.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class AuthSection extends StatelessWidget {
  const AuthSection({super.key, required this.children});

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
      child: Column(children: children),
    );
  }
}

class FieldDivider extends StatelessWidget {
  const FieldDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    color: AppColors.grey100,
    indent: 16,
    endIndent: 16,
  );
}

// ── Auth text field ───────────────────────────────────────────────────────────

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.inputType,
    this.action = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.capitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? inputType;
  final TextInputAction action;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const Gap(6),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            textInputAction: action,
            obscureText: obscureText,
            enabled: enabled,
            textCapitalization: capitalization,
            onFieldSubmitted: onFieldSubmitted,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
            validator: validator,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ── Submit button ─────────────────────────────────────────────────────────────

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final bool isLoading;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon, size: 18), const Gap(10), Text(label)],
            ),
    );
  }
}

// ── Footer link ───────────────────────────────────────────────────────────────

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.message,
    required this.linkText,
    required this.onTap,
  });

  final String message;
  final String linkText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
