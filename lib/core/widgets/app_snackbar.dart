import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Replaces the repeated SnackBar configuration across 8+ files.
abstract class AppSnackbar {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.grey700);

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
