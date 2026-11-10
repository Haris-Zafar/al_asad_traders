import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Standard list row with multi-line title, subtitle, and non-cut trailing amount.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class AppListRow extends StatelessWidget {
  /// Creates an [AppListRow].
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.onLongPress,
  });

  /// Primary row title, wrapped up to 3 lines.
  final String title;

  /// Optional secondary subtitle.
  final String? subtitle;

  /// Optional trailing widget (e.g. status chip or money amount).
  final Widget? trailing;

  /// Optional leading widget (e.g. icon or avatar).
  final Widget? leading;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional long press callback.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final bool stackTrailing = textScale > 1.3 && trailing != null;

    final Widget textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 3,
          softWrap: true,
          style: theme.textTheme.bodyLarge,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            maxLines: 2,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    final Widget content;
    if (stackTrailing) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.s),
              ],
              Expanded(child: textColumn),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      );
    } else {
      content = Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s),
          ],
          Expanded(child: textColumn),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.s),
            trailing!,
          ],
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.m,
            right: AppSpacing.m,
            top: AppSpacing.s,
            bottom: AppSpacing.s,
          ),
          child: content,
        ),
      ),
    );
  }
}
