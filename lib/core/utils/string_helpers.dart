extension StringHelpers on String {
  /// Ensures only the very first letter is capitalised.
  /// Handles all-caps, all-lowercase, or mixed input.
  ///
  /// 'cozy apartment in kololo'  → 'Cozy apartment in kololo'
  /// 'STUDIO FOR RENT'           → 'Studio for rent'
  /// 'nice 2-bedroom flat'       → 'Nice 2-bedroom flat'
  String toSentenceCase() {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }
}
