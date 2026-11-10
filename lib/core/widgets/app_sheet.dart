import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet frame with safe areas, drag handle, and header.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class AppSheet extends StatelessWidget {
  /// Creates an [AppSheet].
  const AppSheet({super.key, required this.child, this.title, this.trailing});

  /// Main content inside the sheet.
  final Widget child;

  /// Optional sheet header title.
  final String? title;

  /// Optional trailing header action.
  final Widget? trailing;

  /// Convenience helper to display a widget inside an [AppSheet] modal.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    Widget? trailing,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return AppSheet(title: title, trailing: trailing, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.m,
              right: AppSpacing.m,
              top: AppSpacing.s,
              bottom: AppSpacing.m,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: AppSizes.touchTarget * 0.7,
                    height: AppSpacing.xs,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AppSpacing.s),
                        trailing!,
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.s),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
