import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:al_asad_traders/core/theme/status_colors.dart';
import 'package:flutter/material.dart';

/// Visual indicator displaying cloud sync status using both an icon and words.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class SyncChip extends StatelessWidget {
  /// Creates a [SyncChip].
  const SyncChip({super.key, required this.isSynced, this.onTap});

  /// True if all local mutations have reached the remote server.
  final bool isSynced;

  /// Optional tap handler (e.g. to explain sync state or trigger sync).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final StatusColors? statusColors = Theme.of(context)
        .extension<StatusColors>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final IconData icon = isSynced
        ? Icons.cloud_done_outlined
        : Icons.cloud_off_outlined;
    final String label = isSynced ? AppStrings.synced : AppStrings.notSyncedYet;
    final Color tintColor = isSynced
        ? (statusColors?.success ?? colors.primary)
        : (statusColors?.onErrorContainer ?? colors.error);
    final Color backgroundColor = isSynced
        ? colors.surface
        : (statusColors?.errorContainer ?? colors.errorContainer);

    final Widget chipContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: tintColor, width: AppSizes.borderWidth),
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
          Icon(icon, size: AppSizes.iconSize * 0.7, color: tintColor),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: tintColor,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
          child: Center(child: chipContent),
        ),
      );
    }

    return chipContent;
  }
}
