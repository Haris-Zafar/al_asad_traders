import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Section header displaying a title with an optional trailing action button.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class SectionHeader extends StatelessWidget {
  /// Creates a [SectionHeader].
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  /// The section header title text.
  final String title;

  /// Optional plain English label for the trailing action button.
  final String? actionLabel;

  /// Callback when the action button is pressed.
  final VoidCallback? onAction;

  /// Custom action widget. Overrides [actionLabel] and [onAction] if provided.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final Widget? resolvedAction =
        action ??
        (actionLabel != null && onAction != null
            ? TextButton(onPressed: onAction, child: Text(actionLabel!))
            : null);

    if (textScale > 1.3 && resolvedAction != null) {
      return Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.m,
          right: AppSpacing.m,
          top: AppSpacing.m,
          bottom: AppSpacing.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium, softWrap: true),
            const SizedBox(height: AppSpacing.xs),
            resolvedAction,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
        bottom: AppSpacing.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              softWrap: true,
            ),
          ),
          if (resolvedAction != null) ...[
            const SizedBox(width: AppSpacing.s),
            resolvedAction,
          ],
        ],
      ),
    );
  }
}
