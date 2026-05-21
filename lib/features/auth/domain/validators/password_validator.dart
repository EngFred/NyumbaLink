class PasswordValidator {
  const PasswordValidator._();

  /// Returns null if valid, or an error message string.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters required';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
    if (!value.contains(RegExp(r'[!@#\$%^&*]'))) {
      return 'Must contain a special character';
    }
    return null;
  }
}
