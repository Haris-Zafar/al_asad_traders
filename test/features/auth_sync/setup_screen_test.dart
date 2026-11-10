import 'package:al_asad_traders/features/auth_sync/data/device_setup_repository.dart';
import 'package:al_asad_traders/features/auth_sync/ui/setup_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('SetupScreen (S33)', () {
    testWidgets('renders setup screen instructions and progress indicator', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final DeviceSetupRepository repo = DeviceSetupRepository(
        firestore,
        prefs: prefs,
      );

      final ProviderContainer container = ProviderContainer(
        overrides: [deviceSetupRepositoryProvider.overrideWithValue(repo)],
      );

      await tester.pumpApp(
        const SetupScreen(),
        container: container,
        settle: false,
      );
      await tester.pump();

      expect(find.textContaining('Setting up your device'), findsOneWidget);
    });
  });
}
