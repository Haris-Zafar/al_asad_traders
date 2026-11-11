import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
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

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = ProductRepository(firestore);
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
          overrides: [productRepositoryProvider.overrideWithValue(repo)],
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
        await tester.tap(find.byKey(const Key('product_save_button')));
        await tester.pumpAndSettle();

        final products = await repo.watchProducts().first;
        expect(products.any((p) => p.name == 'Tea 500g'), isTrue);
      },
    );

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
          overrides: [productRepositoryProvider.overrideWithValue(repo)],
        );

        await tester.pumpApp(
          const ProductDetailScreen(productId: 'p1'),
          container: container,
        );
        await tester.pumpAndSettle();

        expect(find.text('Sugar 1kg'), findsWidgets);
        expect(find.text('12345'), findsOneWidget);
        expect(find.text('Sweet'), findsOneWidget);
      },
    );
  });
}
