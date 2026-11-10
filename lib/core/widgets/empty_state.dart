import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Empty state view showing an icon, a plain English sentence, and a main action button.
/// Rule: docs/UI_PLAN.md > Loading, empty and error states. Story: none.
class EmptyState extends StatelessWidget {
  /// Creates an [EmptyState].
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
  });

  /// Illustrative outline icon.
  final IconData icon;

  /// Single plain English sentence describing the empty state.
  final String message;

  /// Optional label for the primary action button.
  final String? buttonLabel;

  /// Optional callback for the primary action button.
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.xl,
          bottom: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconSize * 2.0, color: colors.outline),
            const SizedBox(height: AppSpacing.m),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.l),
              AppButton(label: buttonLabel!, onPressed: onButtonPressed!),
            ],
          ],
        ),
      ),
    );
  }
}
