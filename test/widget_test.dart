import 'package:al_asad_traders/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AlAsadApp(),
      ),
    );
    expect(find.byType(AlAsadApp), findsOneWidget);
  });
}
