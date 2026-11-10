import 'package:al_asad_traders/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Extension providing easy access to design system text styles.
/// Rule: docs/DESIGN_SYSTEM.md > Text styles. Story: none.
extension AppTextStyles on TextTheme {
  /// Totals and balance amounts (28 sp, bold).
  TextStyle get amount => displaySmall!;

  /// Screen titles (24 sp, bold).
  TextStyle get title => titleLarge!;

  /// Section headers (20 sp, bold).
  TextStyle get section => titleMedium!;

  /// Default body text (18 sp, regular).
  TextStyle get body => bodyLarge!;

  /// Item and person names, buttons (18 sp, bold).
  TextStyle get bodyStrong => bodyMedium!;

  /// Hints, dates, secondary lines (16 sp, regular).
  TextStyle get caption => bodySmall!;
}

/// Builds the [TextTheme] for the application based on [scale].
/// Rule: docs/DESIGN_SYSTEM.md > Text styles. Story: none.
TextTheme buildTextTheme([double scale = 1.0]) {
  const String fontFamily = 'Roboto';
  const double lineHeight = 1.4;

  final TextStyle amountStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0 * scale,
    fontWeight: FontWeight.bold,
    height: lineHeight,
    color: AppColors.onSurface,
  );

  final TextStyle titleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0 * scale,
    fontWeight: FontWeight.bold,
    height: lineHeight,
    color: AppColors.onSurface,
  );

  final TextStyle sectionStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0 * scale,
    fontWeight: FontWeight.bold,
    height: lineHeight,
    color: AppColors.onSurface,
  );

  final TextStyle bodyStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0 * scale,
    fontWeight: FontWeight.normal,
    height: lineHeight,
    color: AppColors.onSurface,
  );

  final TextStyle bodyStrongStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0 * scale,
    fontWeight: FontWeight.bold,
    height: lineHeight,
    color: AppColors.onSurface,
  );

  final TextStyle captionStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0 * scale,
    fontWeight: FontWeight.normal,
    height: lineHeight,
    color: AppColors.onSurfaceMuted,
  );

  return TextTheme(
    displayLarge: amountStyle,
    displayMedium: amountStyle,
    displaySmall: amountStyle,
    headlineLarge: titleStyle,
    headlineMedium: titleStyle,
    headlineSmall: sectionStyle,
    titleLarge: titleStyle,
    titleMedium: sectionStyle,
    titleSmall: bodyStrongStyle,
    bodyLarge: bodyStyle,
    bodyMedium: bodyStrongStyle,
    bodySmall: captionStyle,
    labelLarge: bodyStrongStyle,
    labelMedium: bodyStrongStyle,
    labelSmall: captionStyle,
  );
}
