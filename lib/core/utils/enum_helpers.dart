import 'package:flutter/material.dart';
import '../config/feature_flags.dart';

// ── Property Type ─────────────────────────────────────────────────────────────

abstract final class PropertyTypeHelper {
  static const _labels = {
    'RESIDENTIAL_HOUSE': 'Rentals',
    'APARTMENT': 'Apartments',
    'AIRBNB': 'Airbnbs',
    'OFFICE_SPACE': 'Office Spaces',
    'BUSINESS_SPACE': 'Business Spaces',
    'HOSTEL': 'Hostel',
    'HOTEL_LODGE': 'Hotels / Guesthouses',
  };

  static const _icons = {
    'RESIDENTIAL_HOUSE': Icons.home_rounded,
    'APARTMENT': Icons.apartment_rounded,
    'AIRBNB': Icons.king_bed_rounded,
    'OFFICE_SPACE': Icons.business_center_rounded,
    'BUSINESS_SPACE': Icons.storefront_rounded,
    'HOSTEL': Icons.hotel_rounded,
    'HOTEL_LODGE': Icons.villa_rounded,
  };

  static String label(String type) => _labels[type] ?? type;
  static IconData icon(String type) => _icons[type] ?? Icons.home_rounded;

  /// The canonical ordered list of ALL property types supported by the backend.
  /// Kept private so nothing references it directly — use [all] instead.
  static const _all = [
    'RESIDENTIAL_HOUSE',
    'APARTMENT',
    'AIRBNB',
    'OFFICE_SPACE',
    'BUSINESS_SPACE',
    'HOSTEL',
    'HOTEL_LODGE',
  ];

  /// The list of property types visible in the consumer UI.
  ///
  /// Respects [FeatureFlags.showHostelListings] — when the flag is off,
  /// HOSTEL is silently excluded. Every widget that renders a type list
  /// (category grid, filter sheet) must use this getter, never [_all].
  static List<String> get all => FeatureFlags.showHostelListings
      ? List.unmodifiable(_all)
      : List.unmodifiable(_all.where((t) => t != 'HOSTEL'));
}

// ── Billing Cycle ─────────────────────────────────────────────────────────────

abstract final class BillingCycleHelper {
  static const _labels = {
    'DAILY': '/day',
    'MONTHLY': '/mo',
    'QUARTERLY': '/3 mo',
    'FOUR_MONTHS': '/4 mo',
    'BIANNUAL': '/6 mo',
    'ANNUAL': '/yr',
  };

  static const _full = {
    'DAILY': 'per day',
    'MONTHLY': 'per month',
    'QUARTERLY': 'per quarter',
    'FOUR_MONTHS': 'per 4 months',
    'BIANNUAL': 'per 6 months',
    'ANNUAL': 'per year',
  };

  static String short(String? cycle) => _labels[cycle] ?? '/mo';
  static String full(String? cycle) => _full[cycle] ?? 'per month';
}

// ── Furnishing Status ─────────────────────────────────────────────────────────

abstract final class FurnishingHelper {
  static const _labels = {
    'FURNISHED': 'Furnished',
    'SEMI_FURNISHED': 'Semi-Furnished',
    'UNFURNISHED': 'Unfurnished',
  };

  static String label(String? s) => _labels[s] ?? '';
}

// ── Property Status ───────────────────────────────────────────────────────────

abstract final class PropertyStatusHelper {
  static Color color(String status, {bool bg = false}) {
    if (status == 'AVAILABLE') {
      return bg ? const Color(0xFFDCFCE7) : const Color(0xFF16A34A);
    }
    return bg ? const Color(0xFFF1F3F5) : const Color(0xFF6C757D);
  }

  static String label(String status) =>
      status == 'AVAILABLE' ? 'Available' : 'Rented';
}

// ── Hostel Room Status ────────────────────────────────────────────────────────

abstract final class RoomStatusHelper {
  static Color color(String status, {bool bg = false}) {
    switch (status) {
      case 'AVAILABLE':
        return bg ? const Color(0xFFDCFCE7) : const Color(0xFF16A34A);
      case 'RESERVED':
        return bg ? const Color(0xFFFEF3C7) : const Color(0xFFD97706);
      case 'OCCUPIED':
        return bg ? const Color(0xFFDBEAFE) : const Color(0xFF2563EB);
      case 'MAINTENANCE':
        return bg ? const Color(0xFFF1F3F5) : const Color(0xFF6C757D);
      default:
        return bg ? const Color(0xFFF1F3F5) : const Color(0xFF6C757D);
    }
  }

  static String label(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Available';
      case 'RESERVED':
        return 'Reserved';
      case 'OCCUPIED':
        return 'Occupied';
      case 'MAINTENANCE':
        return 'Maintenance';
      default:
        return status;
    }
  }
}

// ── Hostel Room Type ──────────────────────────────────────────────────────────

abstract final class RoomTypeHelper {
  static const _labels = {
    'SINGLE': 'Single',
    'DOUBLE': 'Double',
    'SHARED': 'Shared',
  };
  static String label(String t) => _labels[t] ?? t;
}

class ResidentialSubtypeHelper {
  static String label(String s) => switch (s) {
    'BUNGALOW' => 'Bungalow',
    'MANSION' => 'Mansion',
    'TOWNHOUSE' => 'Townhouse',
    'VILLA' => 'Villa',
    'DUPLEX' => 'Duplex',
    _ => s,
  };
}
