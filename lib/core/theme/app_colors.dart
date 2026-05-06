import 'package:flutter/material.dart';

/// NyumbaLink brand colors — extracted directly from the logo.
///
/// Primary   → Deep Blue   #1B6FD8  (house outline, chain links)
/// Accent    → Warm Orange #F5971D  (location pin)
/// Dark      → Deep Navy   #2D2B70  (roof / dark elements)
abstract final class AppColors {
  AppColors._();

  // ─── Core Brand ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1B6FD8);
  static const Color accent = Color(0xFFF5971D);
  static const Color dark = Color(0xFF2D2B70);

  // ─── Primary shades ───────────────────────────────────────────────────────
  static const Color primary50 = Color(0xFFE8F1FD);
  static const Color primary100 = Color(0xFFBDD5F8);
  static const Color primary200 = Color(0xFF8EB8F3);
  static const Color primary300 = Color(0xFF5C9AEE);
  static const Color primary400 = Color(0xFF3585E9);
  static const Color primary500 = Color(0xFF1B6FD8); // base
  static const Color primary600 = Color(0xFF1664C5);
  static const Color primary700 = Color(0xFF1157AE);
  static const Color primary800 = Color(0xFF0C4A97);
  static const Color primary900 = Color(0xFF073371);

  // ─── Accent shades ────────────────────────────────────────────────────────
  static const Color accent50 = Color(0xFFFEF4E8);
  static const Color accent100 = Color(0xFFFDE0BB);
  static const Color accent200 = Color(0xFFFBCA8B);
  static const Color accent300 = Color(0xFFF9B45A);
  static const Color accent400 = Color(0xFFF7A336);
  static const Color accent500 = Color(0xFFF5971D); // base
  static const Color accent600 = Color(0xFFE08B18);
  static const Color accent700 = Color(0xFFC47912);
  static const Color accent800 = Color(0xFFA8680C);
  static const Color accent900 = Color(0xFF7C4D07);

  // ─── Neutrals ─────────────────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F5);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF6C757D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Property status ──────────────────────────────────────────────────────
  static const Color statusAvailable = Color(0xFF22C55E);
  static const Color statusAvailableBg = Color(0xFFDCFCE7);
  static const Color statusRented = Color(0xFF6C757D);
  static const Color statusRentedBg = Color(0xFFF1F3F5);

  // ─── Hostel room status ───────────────────────────────────────────────────
  static const Color roomAvailable = Color(0xFF22C55E);
  static const Color roomAvailableBg = Color(0xFFDCFCE7);
  static const Color roomReserved = Color(0xFFF59E0B);
  static const Color roomReservedBg = Color(0xFFFEF3C7);
  static const Color roomOccupied = Color(0xFF3B82F6);
  static const Color roomOccupiedBg = Color(0xFFDBEAFE);
  static const Color roomMaintenance = Color(0xFF6C757D);
  static const Color roomMaintenanceBg = Color(0xFFF1F3F5);

  // ─── Surface / Background ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3F5);
  static const Color divider = Color(0xFFE9ECEF);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF495057);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);
}
