import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/data/tag_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:al_asad_traders/features/products/providers/product_provider.dart';
import 'package:al_asad_traders/features/products/ui/product_detail_screen.dart';
import 'package:al_asad_traders/features/products/ui/product_list_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ProductListScreen & ProductDetailScreen (S1, S3, S4)', () {
    late FakeFirebaseFirestore firestore;
    late ProductRepository repo;
    late TagRepository tagRepo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = ProductRepository(firestore);
      tagRepo = TagRepository(firestore);
    });

    testWidgets(
      'ProductListScreen renders product list, supports search and add product',
      (WidgetTester tester) async {
        final p1 = Product(
          id: 'p1',
          name: 'Sugar 1kg',
          sku: '111',
          defaultSupplierRate: 140,
          defaultBuyerRate: 150,
          defaultRetailPrice: 160,
          createdAt: DateTime.now(),
        );
        final p2 = Product(
          id: 'p2',
          name: 'Flour 10kg',
          sku: '222',
          defaultSupplierRate: 800,
          defaultBuyerRate: 850,
          defaultRetailPrice: 900,
          createdAt: DateTime.now(),
        );
        await repo.saveProduct(p1);
        await repo.saveProduct(p2);

        final container = ProviderContainer(
          overrides: [
            productRepositoryProvider.overrideWithValue(repo),
            tagRepositoryProvider.overrideWithValue(tagRepo),
          ],
        );

        await tester.pumpApp(const ProductListScreen(), container: container);
        await tester.pumpAndSettle();

        expect(find.text('Sugar 1kg'), findsOneWidget);
        expect(find.text('Flour 10kg'), findsOneWidget);

        // Search filtering
        await tester.enterText(
          find.byKey(const Key('products_search_field')),
          'Sugar',
        );
        await tester.pumpAndSettle();

        expect(find.text('Sugar 1kg'), findsOneWidget);
        expect(find.text('Flour 10kg'), findsNothing);

        // Open Add Product form sheet
        await tester.tap(find.byKey(const Key('add_product_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('product_name_field')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('product_name_field')),
          'Tea 500g',
        );
        await tester.enterText(
          find.byKey(const Key('product_retail_price_field')),
          '500',
        );
        await tester.ensureVisible(
          find.byKey(const Key('product_save_button')),
        );
        await tester.tap(find.byKey(const Key('product_save_button')));
        await tester.pumpAndSettle();

        final products = await repo.watchProducts().first;
        expect(products.any((p) => p.name == 'Tea 500g'), isTrue);
      },
    );

    testWidgets('ProductListScreen filters products by tag (S3)', (
      WidgetTester tester,
    ) async {
      final p1 = Product(
        id: 'p1',
        name: 'Cumin 1kg',
        defaultSupplierRate: 100,
        defaultBuyerRate: 110,
        defaultRetailPrice: 120,
        createdAt: DateTime.now(),
      );
      final p2 = Product(
        id: 'p2',
        name: 'Rice 5kg',
        defaultSupplierRate: 400,
        defaultBuyerRate: 450,
        defaultRetailPrice: 500,
        createdAt: DateTime.now(),
      );
      await repo.saveProduct(p1);
      await repo.saveProduct(p2);

      final tag = await tagRepo.createTag('Spices');
      await tagRepo.assignTagsToProduct('p1', [tag.id]);

      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
          tagRepositoryProvider.overrideWithValue(tagRepo),
        ],
      );

      await tester.pumpApp(const ProductListScreen(), container: container);
      await tester.pumpAndSettle();

      expect(find.text('Cumin 1kg'), findsOneWidget);
      expect(find.text('Rice 5kg'), findsOneWidget);
      expect(find.byKey(Key('tag_chip_${tag.id}')), findsOneWidget);

      // Select Spices tag chip
      await tester.tap(find.byKey(Key('tag_chip_${tag.id}')));
      await tester.pumpAndSettle();

      expect(find.text('Cumin 1kg'), findsOneWidget);
      expect(find.text('Rice 5kg'), findsNothing);

      // Select All tag chip
      await tester.tap(find.byKey(const Key('tag_chip_all')));
      await tester.pumpAndSettle();

      expect(find.text('Cumin 1kg'), findsOneWidget);
      expect(find.text('Rice 5kg'), findsOneWidget);
    });

    testWidgets(
      'ProductDetailScreen displays details and handles archive/unarchive',
      (WidgetTester tester) async {
        final product = Product(
          id: 'p1',
          name: 'Sugar 1kg',
          sku: '12345',
          defaultSupplierRate: 140,
          defaultBuyerRate: 150,
          defaultRetailPrice: 160,
          notes: 'Sweet',
          createdAt: DateTime.now(),
        );
        await repo.saveProduct(product);

        final container = ProviderContainer(
          overrides: [
            productRepositoryProvider.overrideWithValue(repo),
            tagRepositoryProvider.overrideWithValue(tagRepo),
          ],
        );

        await tester.pumpApp(
          const ProductDetailScreen(productId: 'p1'),
          container: container,
        );
        await tester.pumpAndSettle();

        expect(find.text('Sugar 1kg'), findsWidgets);
        expect(find.text('12345'), findsOneWidget);
        expect(find.text('Sweet'), findsOneWidget);

        // Tap Archive button ("Hide")
        await tester.tap(find.byKey(const Key('product_archive_button')));
        await tester.pumpAndSettle();

        // Confirm dialog should appear
        expect(find.text('Hide product'), findsOneWidget);
        expect(find.text('Yes, hide'), findsOneWidget);

        await tester.tap(find.text('Yes, hide'));
        await tester.pumpAndSettle();

        final archivedProduct = await repo.getProduct('p1');
        expect(archivedProduct?.isArchived, isTrue);

        // Verify button changes to "Unhide"
        expect(find.text('Unhide'), findsOneWidget);

        // Tap Unhide button
        await tester.tap(find.byKey(const Key('product_archive_button')));
        await tester.pumpAndSettle();

        final unarchivedProduct = await repo.getProduct('p1');
        expect(unarchivedProduct?.isArchived, isFalse);
      },
    );

    testWidgets(
      'ProductListScreen hides archived products by default and activeProductsProvider excludes them (S4)',
      (WidgetTester tester) async {
        final activeProd = Product(
          id: 'p-active',
          name: 'Active Product',
          defaultSupplierRate: 10,
          defaultBuyerRate: 12,
          defaultRetailPrice: 15,
          createdAt: DateTime.now(),
        );
        final archivedProd = Product(
          id: 'p-archived',
          name: 'Archived Product',
          defaultSupplierRate: 10,
          defaultBuyerRate: 12,
          defaultRetailPrice: 15,
          archivedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repo.saveProduct(activeProd);
        await repo.saveProduct(archivedProd);

        final container = ProviderContainer(
          overrides: [
            productRepositoryProvider.overrideWithValue(repo),
            tagRepositoryProvider.overrideWithValue(tagRepo),
          ],
        );
        addTearDown(container.dispose);

        // Subscribe to activeProductsProvider
        container.listen(activeProductsProvider, (_, _) {});
        await tester.pump();

        final activeList = container.read(activeProductsProvider).value ?? [];
        expect(activeList.length, equals(1));
        expect(activeList.first.id, equals('p-active'));

        // Test UI hiding archived products by default
        await tester.pumpApp(const ProductListScreen(), container: container);
        await tester.pumpAndSettle();

        expect(find.text('Active Product'), findsOneWidget);
        expect(find.text('Archived Product'), findsNothing);

        // Toggle Show Hidden chip
        await tester.tap(find.byKey(const Key('products_show_archived_chip')));
        await tester.pumpAndSettle();

        expect(find.text('Active Product'), findsOneWidget);
        expect(find.text('Archived Product'), findsOneWidget);
      },
    );
  });
}
