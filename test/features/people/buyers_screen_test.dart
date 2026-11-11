import 'package:al_asad_traders/features/people/data/buyers_repository.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:al_asad_traders/features/people/ui/buyer_detail_screen.dart';
import 'package:al_asad_traders/features/people/ui/buyers_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('BuyersScreen & BuyerDetailScreen (S9)', () {
    late FakeFirebaseFirestore firestore;
    late BuyersRepository repo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = BuyersRepository(firestore);
    });

    testWidgets(
      'BuyersScreen renders buyers list, supports search and add buyer',
      (WidgetTester tester) async {
        final buyer1 = Buyer(
          id: 'b1',
          name: 'Ali Khan',
          contactNumber: '03001111111',
          createdAt: DateTime.now(),
        );
        final buyer2 = Buyer(
          id: 'b2',
          name: 'Bilal Traders',
          contactNumber: '03002222222',
          createdAt: DateTime.now(),
        );
        await repo.saveBuyer(buyer1);
        await repo.saveBuyer(buyer2);

        final container = ProviderContainer(
          overrides: [buyersRepositoryProvider.overrideWithValue(repo)],
        );

        await tester.pumpApp(const BuyersScreen(), container: container);
        await tester.pumpAndSettle();

        expect(find.text('Ali Khan'), findsOneWidget);
        expect(find.text('Bilal Traders'), findsOneWidget);

        // Search filtering
        await tester.enterText(
          find.byKey(const Key('buyers_search_field')),
          'Ali',
        );
        await tester.pumpAndSettle();

        expect(find.text('Ali Khan'), findsOneWidget);
        expect(find.text('Bilal Traders'), findsNothing);

        // Open Add Buyer form sheet
        await tester.tap(find.byKey(const Key('add_buyer_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('buyer_name_field')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('buyer_name_field')),
          'New Buyer',
        );
        await tester.tap(find.byKey(const Key('buyer_save_button')));
        await tester.pumpAndSettle();

        final buyers = await repo.watchBuyers().first;
        expect(buyers.any((b) => b.name == 'New Buyer'), isTrue);
      },
    );

    testWidgets(
      'BuyerDetailScreen displays details and handles archive/unarchive',
      (WidgetTester tester) async {
        final buyer = Buyer(
          id: 'b1',
          name: 'Ali Khan',
          contactNumber: '03001111111',
          address: 'Gari Khata',
          notes: 'VIP Client',
          createdAt: DateTime.now(),
        );
        await repo.saveBuyer(buyer);

        final container = ProviderContainer(
          overrides: [buyersRepositoryProvider.overrideWithValue(repo)],
        );

        await tester.pumpApp(
          const BuyerDetailScreen(buyerId: 'b1'),
          container: container,
        );
        await tester.pumpAndSettle();

        expect(find.text('Ali Khan'), findsWidgets);
        expect(find.text('03001111111'), findsOneWidget);
        expect(find.text('Gari Khata'), findsOneWidget);
        expect(find.text('VIP Client'), findsOneWidget);

        // Archive buyer
        await tester.ensureVisible(find.byKey(const Key('buyer_archive_button')));
        await tester.tap(find.byKey(const Key('buyer_archive_button')));
        await tester.pumpAndSettle();

        // Confirm dialog appears
        expect(find.text('Yes, hide'), findsOneWidget);
        await tester.tap(find.text('Yes, hide'));
        await tester.pumpAndSettle();

        final archivedBuyer = await repo.getBuyer('b1');
        expect(archivedBuyer?.isArchived, isTrue);
      },
    );
  });
}
