import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Style variant for [AppButton].
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
enum AppButtonVariant {
  /// Primary solid action button.
  primary,

  /// Secondary outlined action button.
  secondary,

  /// High-visibility danger action button (e.g. deletion, irreversible action).
  danger,
}

/// Standard full-width action button adhering to 56dp height and touch targets.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class AppButton extends StatelessWidget {
  /// Creates an [AppButton].
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width = double.infinity,
  });

  /// Plain English label text.
  final String label;

  /// Callback when pressed. Null disables the button.
  final VoidCallback? onPressed;

  /// Button visual style variant.
  final AppButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows a progress spinner instead of label/icon.
  final bool isLoading;

  /// Desired button width. Defaults to full-width [double.infinity].
  final double width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Widget content = isLoading
        ? SizedBox(
            height: AppSizes.iconSize,
            width: AppSizes.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.borderWidth,
              color: variant == AppButtonVariant.secondary
                  ? colors.primary
                  : colors.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSize),
                const SizedBox(width: AppSpacing.s),
              ],
              Flexible(
                child: Text(label, textAlign: TextAlign.center, softWrap: true),
              ),
            ],
          );

    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(onPressed: effectiveOnPressed, child: content);
      case AppButtonVariant.secondary:
        button = OutlinedButton(onPressed: effectiveOnPressed, child: content);
      case AppButtonVariant.danger:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: content,
        );
    }

    return SizedBox(width: width, height: AppSizes.buttonHeight, child: button);
  }
}
