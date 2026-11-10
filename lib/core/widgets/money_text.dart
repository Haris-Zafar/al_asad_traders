import 'package:al_asad_traders/core/format/money_format.dart';
import 'package:flutter/material.dart';

/// Formatted whole-number monetary amount text that is never truncated.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class MoneyText extends StatelessWidget {
  /// Creates a [MoneyText].
  const MoneyText({
    super.key,
    required this.amount,
    this.style,
    this.includeCurrency = true,
  });

  /// The integer amount in rupees (no decimals).
  final int amount;

  /// Optional text style. Defaults to theme's titleMedium or headlineMedium for totals.
  final TextStyle? style;

  /// Whether to include the 'Rs' prefix. Defaults to true.
  final bool includeCurrency;

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultStyle =
        Theme.of(context).textTheme.titleMedium ?? const TextStyle();

    final String text = includeCurrency
        ? MoneyFormat.formatWithCurrency(amount)
        : MoneyFormat.format(amount);

    return Text(
      text,
      style: style ?? defaultStyle,
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}
