/// Standard design system spacing tokens.
/// Rule: docs/DESIGN_SYSTEM.md > Spacing and sizes. Story: none.
abstract final class AppSpacing {
  /// Extra small spacing gap (4 dp).
  static const double xs = 4.0;

  /// Small spacing gap (8 dp) - row gap and neighbor margins.
  static const double s = 8.0;

  /// Medium spacing gap (16 dp) - standard screen padding.
  static const double m = 16.0;

  /// Large spacing gap (24 dp).
  static const double l = 24.0;

  /// Extra large spacing gap (32 dp).
  static const double xl = 32.0;
}

/// Standard design system dimensional tokens.
/// Rule: docs/DESIGN_SYSTEM.md > Spacing and sizes. Story: none.
abstract final class AppSizes {
  /// Minimum touch target size (56 dp).
  static const double touchTarget = 56.0;

  /// Standard height for buttons, input fields, and bottom bar items (56 dp).
  static const double buttonHeight = 56.0;

  /// Standard icon dimension (28 dp).
  static const double iconSize = 28.0;

  /// Standard corner radius for cards, buttons, fields, sheets (12 dp).
  static const double radius = 12.0;

  /// Standard border width for cards and fields (1.5 dp).
  static const double borderWidth = 1.5;

  /// Focus outline width for accessible focus borders (3.0 dp).
  static const double focusWidth = 3.0;

  /// Maximum content width before centering on wide displays (600 dp).
  static const double maxContentWidth = 600.0;
}
