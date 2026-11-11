import 'package:al_asad_traders/features/people/data/suppliers_repository.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:al_asad_traders/features/people/ui/supplier_detail_screen.dart';
import 'package:al_asad_traders/features/people/ui/suppliers_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('SuppliersScreen & SupplierDetailScreen (S9)', () {
    late FakeFirebaseFirestore firestore;
    late SuppliersRepository repo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = SuppliersRepository(firestore);
    });

    testWidgets(
      'SuppliersScreen renders suppliers list, supports search and add supplier',
      (WidgetTester tester) async {
        final supplier1 = Supplier(
          id: 's1',
          name: 'Hassan Traders',
          contactNumber: '03003333333',
          createdAt: DateTime.now(),
        );
        final supplier2 = Supplier(
          id: 's2',
          name: 'Zubair Mills',
          contactNumber: '03004444444',
          createdAt: DateTime.now(),
        );
        await repo.saveSupplier(supplier1);
        await repo.saveSupplier(supplier2);

        final container = ProviderContainer(
          overrides: [suppliersRepositoryProvider.overrideWithValue(repo)],
        );

        await tester.pumpApp(const SuppliersScreen(), container: container);
        await tester.pumpAndSettle();

        expect(find.text('Hassan Traders'), findsOneWidget);
        expect(find.text('Zubair Mills'), findsOneWidget);

        // Search filtering
        await tester.enterText(
          find.byKey(const Key('suppliers_search_field')),
          'Zubair',
        );
        await tester.pumpAndSettle();

        expect(find.text('Zubair Mills'), findsOneWidget);
        expect(find.text('Hassan Traders'), findsNothing);

        // Open Add Supplier form sheet
        await tester.tap(find.byKey(const Key('add_supplier_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('supplier_name_field')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('supplier_name_field')),
          'New Supplier',
        );
        await tester.tap(find.byKey(const Key('supplier_save_button')));
        await tester.pumpAndSettle();

        final suppliers = await repo.watchSuppliers().first;
        expect(suppliers.any((s) => s.name == 'New Supplier'), isTrue);
      },
    );

    testWidgets(
      'SupplierDetailScreen displays details and handles archive/unarchive',
      (WidgetTester tester) async {
        final supplier = Supplier(
          id: 's1',
          name: 'Hassan Traders',
          contactNumber: '03003333333',
          address: 'Grain Market',
          notes: 'Top supplier',
          createdAt: DateTime.now(),
        );
        await repo.saveSupplier(supplier);

        final container = ProviderContainer(
          overrides: [suppliersRepositoryProvider.overrideWithValue(repo)],
        );

        await tester.pumpApp(
          const SupplierDetailScreen(supplierId: 's1'),
          container: container,
        );
        await tester.pumpAndSettle();

        expect(find.text('Hassan Traders'), findsWidgets);
        expect(find.text('03003333333'), findsOneWidget);
        expect(find.text('Grain Market'), findsOneWidget);
        expect(find.text('Top supplier'), findsOneWidget);

        // Archive supplier
        await tester.ensureVisible(find.byKey(const Key('supplier_archive_button')));
        await tester.tap(find.byKey(const Key('supplier_archive_button')));
        await tester.pumpAndSettle();

        // Confirm dialog appears
        expect(find.text('Yes, hide'), findsOneWidget);
        await tester.tap(find.text('Yes, hide'));
        await tester.pumpAndSettle();

        final archivedSupplier = await repo.getSupplier('s1');
        expect(archivedSupplier?.isArchived, isTrue);
      },
    );
  });
}
