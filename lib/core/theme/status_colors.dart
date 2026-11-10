import 'package:al_asad_traders/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Theme extension for semantic and status colors that ColorScheme lacks.
/// Rule: docs/DESIGN_SYSTEM.md > Theme files. Story: none.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  /// Creates a status color palette extension.
  const StatusColors({
    required this.chipDraftBackground,
    required this.chipDraftText,
    required this.chipFinishedBackground,
    required this.chipFinishedText,
    required this.chipPaidBackground,
    required this.chipPaidText,
    required this.chipOnAccountBackground,
    required this.chipOnAccountText,
    required this.success,
    required this.errorContainer,
    required this.onErrorContainer,
  });

  /// Default light theme status colors from [AppColors].
  factory StatusColors.light() => const StatusColors(
    chipDraftBackground: AppColors.chipDraftBackground,
    chipDraftText: AppColors.chipDraftText,
    chipFinishedBackground: AppColors.chipFinishedBackground,
    chipFinishedText: AppColors.chipFinishedText,
    chipPaidBackground: AppColors.chipPaidBackground,
    chipPaidText: AppColors.chipPaidText,
    chipOnAccountBackground: AppColors.chipOnAccountBackground,
    chipOnAccountText: AppColors.chipOnAccountText,
    success: AppColors.success,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
  );

  /// Background color for draft status chips.
  final Color chipDraftBackground;

  /// Text color for draft status chips.
  final Color chipDraftText;

  /// Background color for finished status chips.
  final Color chipFinishedBackground;

  /// Text color for finished status chips.
  final Color chipFinishedText;

  /// Background color for paid status chips.
  final Color chipPaidBackground;

  /// Text color for paid status chips.
  final Color chipPaidText;

  /// Background color for on-account status chips.
  final Color chipOnAccountBackground;

  /// Text color for on-account status chips.
  final Color chipOnAccountText;

  /// Semantic success color.
  final Color success;

  /// Semantic error panel background.
  final Color errorContainer;

  /// Semantic error panel text color.
  final Color onErrorContainer;

  @override
  StatusColors copyWith({
    Color? chipDraftBackground,
    Color? chipDraftText,
    Color? chipFinishedBackground,
    Color? chipFinishedText,
    Color? chipPaidBackground,
    Color? chipPaidText,
    Color? chipOnAccountBackground,
    Color? chipOnAccountText,
    Color? success,
    Color? errorContainer,
    Color? onErrorContainer,
  }) {
    return StatusColors(
      chipDraftBackground: chipDraftBackground ?? this.chipDraftBackground,
      chipDraftText: chipDraftText ?? this.chipDraftText,
      chipFinishedBackground:
          chipFinishedBackground ?? this.chipFinishedBackground,
      chipFinishedText: chipFinishedText ?? this.chipFinishedText,
      chipPaidBackground: chipPaidBackground ?? this.chipPaidBackground,
      chipPaidText: chipPaidText ?? this.chipPaidText,
      chipOnAccountBackground:
          chipOnAccountBackground ?? this.chipOnAccountBackground,
      chipOnAccountText: chipOnAccountText ?? this.chipOnAccountText,
      success: success ?? this.success,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) {
      return this;
    }
    return StatusColors(
      chipDraftBackground:
          Color.lerp(chipDraftBackground, other.chipDraftBackground, t) ??
          chipDraftBackground,
      chipDraftText:
          Color.lerp(chipDraftText, other.chipDraftText, t) ?? chipDraftText,
      chipFinishedBackground:
          Color.lerp(chipFinishedBackground, other.chipFinishedBackground, t) ??
          chipFinishedBackground,
      chipFinishedText:
          Color.lerp(chipFinishedText, other.chipFinishedText, t) ??
          chipFinishedText,
      chipPaidBackground:
          Color.lerp(chipPaidBackground, other.chipPaidBackground, t) ??
          chipPaidBackground,
      chipPaidText:
          Color.lerp(chipPaidText, other.chipPaidText, t) ?? chipPaidText,
      chipOnAccountBackground:
          Color.lerp(
            chipOnAccountBackground,
            other.chipOnAccountBackground,
            t,
          ) ??
          chipOnAccountBackground,
      chipOnAccountText:
          Color.lerp(chipOnAccountText, other.chipOnAccountText, t) ??
          chipOnAccountText,
      success: Color.lerp(success, other.success, t) ?? success,
      errorContainer:
          Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      onErrorContainer:
          Color.lerp(onErrorContainer, other.onErrorContainer, t) ??
          onErrorContainer,
    );
  }
}
