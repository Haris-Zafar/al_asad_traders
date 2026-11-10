/// User text size preferences.
/// Normal: 1.0, Large: 1.2, Extra large: 1.4.
/// Multiplied by the phone's font scale and clamped to 2.0.
/// Rule: docs/DESIGN_SYSTEM.md > Text styles. Story: none.
enum TextScaleChoice {
  /// Default normal scale (1.0).
  normal(1.0, 'Normal'),

  /// Large scale (1.2).
  large(1.2, 'Large'),

  /// Extra large scale (1.4).
  extraLarge(1.4, 'Extra large');

  const TextScaleChoice(this.factor, this.label);

  /// Scaling factor applied to text sizes.
  final double factor;

  /// Plain English label for settings UI.
  final String label;

  /// SharedPreferences storage key.
  static const String prefKey = 'text_scale_choice';

  /// Calculates effective font scale clamped to a maximum of 2.0.
  static double calculateEffectiveScale({
    required double userFactor,
    required double phoneScale,
  }) {
    return (userFactor * phoneScale).clamp(1.0, 2.0);
  }

  /// Parses a string representation back to [TextScaleChoice].
  static TextScaleChoice fromString(String? value) {
    return switch (value) {
      'large' => TextScaleChoice.large,
      'extraLarge' => TextScaleChoice.extraLarge,
      _ => TextScaleChoice.normal,
    };
  }
}
