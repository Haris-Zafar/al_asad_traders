import 'package:al_asad_traders/app/router.dart';
import 'package:al_asad_traders/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget configured with [MaterialApp.router] and Riverpod.
/// Rule: docs/ARCHITECTURE.md > Folders. Story: none.
class AlAsadApp extends ConsumerWidget {
  /// Creates the root application widget.
  const AlAsadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(routerConfig: router, theme: buildTheme(1.0));
  }
}
