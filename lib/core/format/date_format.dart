import 'package:intl/intl.dart';

/// Formatter for dates and timestamps across the application.
/// Rule: docs/ARCHITECTURE.md > Code conventions. Story: none.
abstract final class AppDateFormat {
  static final DateFormat _shortDate = DateFormat('d MMM', 'en_US');
  static final DateFormat _fullDate = DateFormat('d MMM yyyy', 'en_US');
  static final DateFormat _dateTime = DateFormat(
    'd MMM yyyy, hh:mm a',
    'en_US',
  );

  /// Formats [date] as day and abbreviated month (e.g. 12 Nov).
  static String formatShort(DateTime date) {
    return _shortDate.format(date);
  }

  /// Formats [date] as day, abbreviated month, and full year (e.g. 12 Nov 2026).
  static String format(DateTime date) {
    return _fullDate.format(date);
  }

  /// Formats [date] with full date and 12-hour time (e.g. 12 Nov 2026, 02:30 PM).
  static String formatWithTime(DateTime date) {
    return _dateTime.format(date);
  }
}
