import 'package:al_asad_traders/core/strings.dart';
import 'package:intl/intl.dart';

/// Formatter for monetary amounts and integer numbers.
/// Rule: docs/DESIGN_SYSTEM.md > Plain words. Story: none.
abstract final class MoneyFormat {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  /// Formats a whole-number [amount] with thousands separator.
  /// Example: 1500 -> '1,500', -1500 -> '-1,500'.
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Formats a whole-number [amount] prefixed with [AppStrings.currency].
  /// Example: 1500 -> 'Rs 1,500', -1500 -> '-Rs 1,500'.
  static String formatWithCurrency(int amount) {
    if (amount < 0) {
      return '-${AppStrings.currency} ${_formatter.format(amount.abs())}';
    }
    return '${AppStrings.currency} ${_formatter.format(amount)}';
  }

  /// Parses user input containing optional thousands separators into an integer.
  /// Returns `null` if the input is not a valid integer.
  static int? parse(String text) {
    final String clean = text.replaceAll(',', '').trim();
    return int.tryParse(clean);
  }
}
