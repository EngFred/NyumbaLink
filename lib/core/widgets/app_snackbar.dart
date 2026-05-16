import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Replaces standard bottom SnackBars with ultra-premium top toast notifications.
/// Pure drop-in replacement—zero breaking changes across your feature files.
abstract class AppSnackbar {
  static void success(BuildContext context, String message) =>
      _show(context, message, ToastificationType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, ToastificationType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, ToastificationType.info);

  static void _show(
    BuildContext context,
    String message,
    ToastificationType type,
  ) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle
          .minimal, // Sleek modern design with a thin status accent line
      alignment:
          Alignment.topCenter, // Anchors the pop-up directly to the top center
      autoCloseDuration: const Duration(seconds: 4),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), // Elegant spacing from top notches
      title: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      showProgressBar: false,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 350),
    );
  }
}
