import 'package:al_asad_traders/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Application scaffold ensuring safe area, standard padding, scrollable body,
/// and optional sticky footer above keyboard.
/// Rule: docs/DESIGN_SYSTEM.md > Shared widgets. Story: none.
class AppScaffold extends StatelessWidget {
  /// Creates an [AppScaffold].
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.footer,
    this.actions,
    this.leading,
    this.scrollable = true,
    this.padding,
  });

  /// The main content widget.
  final Widget body;

  /// Optional plain title string for the default app bar.
  final String? title;

  /// Optional explicit app bar. Overrides [title] if provided.
  final PreferredSizeWidget? appBar;

  /// Optional sticky footer pinned to the bottom above the keyboard and safe area.
  final Widget? footer;

  /// Optional actions for the default app bar.
  final List<Widget>? actions;

  /// Optional leading widget for the default app bar.
  final Widget? leading;

  /// Whether the body should scroll vertically. Defaults to true.
  final bool scrollable;

  /// Custom padding for the body. Defaults to [AppSpacing.m] on all sides.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget? resolvedAppBar =
        appBar ??
        (title != null
            ? AppBar(title: Text(title!), actions: actions, leading: leading)
            : null);

    return Scaffold(
      appBar: resolvedAppBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: AppSpacing.m,
                                right: AppSpacing.m,
                                top: AppSpacing.m,
                                bottom: AppSpacing.m,
                              ),
                          child: body,
                        )
                      : Padding(
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: AppSpacing.m,
                                right: AppSpacing.m,
                                top: AppSpacing.m,
                                bottom: AppSpacing.m,
                              ),
                          child: body,
                        ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.m,
                      right: AppSpacing.m,
                      top: AppSpacing.s,
                      bottom: AppSpacing.m,
                    ),
                    child: footer!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
