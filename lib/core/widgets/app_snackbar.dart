import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../theme/app_colors.dart';

/// Replaces standard bottom SnackBars with ultra-premium top toast notifications.
abstract class AppSnackbar {
  static void success(BuildContext context, String message) => _show(
    context,
    message,
    ToastificationType.success,
    Icons.check_circle_rounded,
    AppColors.success,
  );

  static void error(BuildContext context, String message) => _show(
    context,
    message,
    ToastificationType.error,
    Icons.error_outline_rounded,
    AppColors.error,
  );

  static void info(BuildContext context, String message) => _show(
    context,
    message,
    ToastificationType.info,
    Icons.info_outline_rounded,
    AppColors.primary, // Using primary for info to keep brand consistency
  );

  static void _show(
    BuildContext context,
    String message,
    ToastificationType type,
    IconData icon,
    Color primaryColor,
  ) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.minimal,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),

      // ── PRO UX: Brand Integration ──
      primaryColor: primaryColor,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      icon: Icon(icon, color: primaryColor, size: 24),

      // ── Margins & Shapes ──
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(
        16,
      ), // Match your app's standard radius
      // ── Typography ──
      title: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          height: 1.3,
        ),
      ),

      // ── Premium Soft Shadow ──
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],

      // ── Behavior ──
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none, // Keeps it perfectly clean
      pauseOnHover: true, // Excellent UX if user holds finger on it to read
      dragToClose: true,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        // A slightly snappier, more natural slide-in animation
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
