import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/theme/status_colors.dart';
import 'package:flutter/material.dart';

/// Semantic status categories for bills and workflow items.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
enum AppStatus {
  /// Uncommitted work-in-progress draft.
  draft,

  /// Finalized bill with immutable items.
  finished,

  /// Fully settled in cash.
  paid,

  /// Transferred to buyer ledger account.
  onAccount,
}

/// Visual status badge showing both an icon and plain English label.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class StatusChip extends StatelessWidget {
  /// Creates a [StatusChip] for the given [status].
  const StatusChip({super.key, required this.status});

  /// The item status category.
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final StatusColors? statusColors = Theme.of(context)
        .extension<StatusColors>();
    final ThemeData theme = Theme.of(context);

    final (
      Color background,
      Color textColor,
      IconData icon,
      String label,
    ) = switch (status) {
      AppStatus.draft => (
        statusColors?.chipDraftBackground ?? theme.colorScheme.surface,
        statusColors?.chipDraftText ?? theme.colorScheme.onSurface,
        Icons.edit_outlined,
        AppStrings.draft,
      ),
      AppStatus.finished => (
        statusColors?.chipFinishedBackground ?? theme.colorScheme.surface,
        statusColors?.chipFinishedText ?? theme.colorScheme.onSurface,
        Icons.check_circle_outline,
        AppStrings.finished,
      ),
      AppStatus.paid => (
        statusColors?.chipPaidBackground ?? theme.colorScheme.surface,
        statusColors?.chipPaidText ?? theme.colorScheme.onSurface,
        Icons.done_all,
        AppStrings.paid,
      ),
      AppStatus.onAccount => (
        statusColors?.chipOnAccountBackground ?? theme.colorScheme.surface,
        statusColors?.chipOnAccountText ?? theme.colorScheme.onSurface,
        Icons.account_balance_wallet_outlined,
        AppStrings.onAccount,
      ),
    };

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.s,
        right: AppSpacing.s,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSize * 0.7, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
