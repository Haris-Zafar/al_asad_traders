import 'package:al_asad_traders/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper extension on [WidgetTester] to pump widgets in a standard test harness.
/// Rule: docs/TESTING.md > Helpers. Story: none.
extension PumpAppX on WidgetTester {
  /// Pumps [widget] inside [MaterialApp], [UncontrolledProviderScope], with
  /// default size 360x640 portrait and given [textScale].
  Future<void> pumpApp(
    Widget widget, {
    Size size = const Size(360, 640),
    double textScale = 1.0,
    ProviderContainer? container,
    ThemeData? theme,
    bool settle = true,
  }) async {
    view.physicalSize = Size(
      size.width * view.devicePixelRatio,
      size.height * view.devicePixelRatio,
    );
    addTearDown(view.resetPhysicalSize);

    platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(platformDispatcher.clearTextScaleFactorTestValue);

    final ProviderContainer effectiveContainer =
        container ?? ProviderContainer();
    if (container == null) {
      addTearDown(effectiveContainer.dispose);
    }

    final ThemeData effectiveTheme = theme ?? buildTheme(1.0);

    await pumpWidget(
      UncontrolledProviderScope(
        container: effectiveContainer,
        child: MaterialApp(
          theme: effectiveTheme,
          home: Scaffold(body: widget),
        ),
      ),
    );
    if (settle) {
      await pumpAndSettle();
    } else {
      await pump();
    }
  }
}
