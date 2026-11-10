import 'package:flutter/material.dart';

/// Design system color palette.
/// The only file permitted to declare hex color literals.
/// Rule: docs/DESIGN_SYSTEM.md > Colors. Story: none.
abstract final class AppColors {
  /// Pure white screen background.
  static const Color background = Color(0xFFFFFFFF);

  /// Card and sheet surface background.
  static const Color surface = Color(0xFFF4F6F9);

  /// Primary high-contrast body text.
  static const Color onSurface = Color(0xFF1A1A1A);

  /// Secondary muted text for hints, dates, and captions.
  static const Color onSurfaceMuted = Color(0xFF4A4A4A);

  /// Border color for input fields and flat cards.
  static const Color border = Color(0xFF6B7280);

  /// Primary action color for buttons, app bar, and links.
  static const Color primary = Color(0xFF1F4E8C);

  /// Accent highlight color (e.g. Put on account action).
  static const Color accent = Color(0xFFB45309);

  /// Semantic error color for error messages and danger buttons.
  static const Color error = Color(0xFFB3261E);

  /// Semantic error container panel background.
  static const Color errorContainer = Color(0xFFFBE4E2);

  /// Semantic error container text color.
  static const Color onErrorContainer = Color(0xFF8C1D18);

  /// Semantic success color for Paid, Synced statuses.
  static const Color success = Color(0xFF14532D);

  /// Neutral pure white for text on primary fills.
  static const Color white = Color(0xFFFFFFFF);

  // Status chip colors (text and icon, never color alone).

  /// Draft chip background.
  static const Color chipDraftBackground = Color(0xFFE5E7EB);

  /// Draft chip text color.
  static const Color chipDraftText = Color(0xFF1A1A1A);

  /// Finished chip background.
  static const Color chipFinishedBackground = Color(0xFFDCE6F4);

  /// Finished chip text color.
  static const Color chipFinishedText = Color(0xFF1F4E8C);

  /// Paid chip background.
  static const Color chipPaidBackground = Color(0xFFD8EFE0);

  /// Paid chip text color.
  static const Color chipPaidText = Color(0xFF14532D);

  /// On account chip background.
  static const Color chipOnAccountBackground = Color(0xFFFDE9D0);

  /// On account chip text color.
  static const Color chipOnAccountText = Color(0xFF7C3A06);
}
