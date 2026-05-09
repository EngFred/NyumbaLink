import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  CurrencyFormatter._();

  static final _fmt = NumberFormat('#,###', 'en_UG');

  /// Format a price as "UGX 800,000"
  static String format(num amount) => 'UGX ${_fmt.format(amount)}';

  /// Short format: "UGX 800K" for amounts >= 100,000
  static String formatShort(num amount) {
    if (amount >= 1_000_000) {
      return 'UGX ${(amount / 1_000_000).toStringAsFixed(1)}M';
    } else if (amount >= 1_000) {
      return 'UGX ${(amount / 1_000).toStringAsFixed(0)}K';
    }
    return format(amount);
  }
}
