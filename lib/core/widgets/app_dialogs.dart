import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/widgets/action_row.dart';
import 'package:al_asad_traders/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Displays a standard modal confirmation dialog with plain English buttons.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool isDanger = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);

      return AlertDialog(
        title: Text(title, style: theme.textTheme.titleMedium),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          ActionRow(
            primary: AppButton(
              label: confirmLabel ?? AppStrings.ok,
              variant: isDanger
                  ? AppButtonVariant.danger
                  : AppButtonVariant.primary,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
            secondary: AppButton(
              label: cancelLabel ?? AppStrings.cancel,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
          ),
        ],
      );
    },
  );
}

/// Displays an informational alert dialog with a single dismissal button.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
Future<void> showMessageDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? okLabel,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);

      return AlertDialog(
        title: Text(title, style: theme.textTheme.titleMedium),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          AppButton(
            label: okLabel ?? AppStrings.ok,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      );
    },
  );
}
