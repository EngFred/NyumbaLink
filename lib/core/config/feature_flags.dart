/// Central place for toggling features on/off in the consumer app.
///
/// These flags are intentionally compile-time constants so the compiler
/// can dead-code-eliminate any branch that is permanently off, and so
/// there is a single, grep-able source of truth for every feature gate.
///
/// HOW TO RE-ENABLE HOSTELS:
///   Flip [showHostelListings] to `true` and hot-restart. Nothing else
///   needs to change — the backend, admin panel, and data are untouched.
abstract final class FeatureFlags {
  /// Controls whether HOSTEL property listings are visible in the consumer app.
  ///
  /// Set to `false` temporarily because hostel owners are not yet onboarded /
  /// cooperating. The HOSTEL type still exists on the backend and in the admin
  /// panel — we are only hiding it from the renter-facing mobile UI.
  static const bool showHostelListings = false;
}
