import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/products/data/product_repository.dart';
import 'package:al_asad_traders/features/products/models/product.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRepository (S1, S4)', () {
    late FakeFirebaseFirestore firestore;
    late ProductRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ProductRepository(firestore);
    });

    test('getProduct returns null when product does not exist', () async {
      final product = await repository.getProduct('non_existent');
      expect(product, isNull);
    });

    test('saveProduct creates new product and retrieves it', () async {
      final newProduct = Product(
        id: '',
        name: 'Sugar 1kg',
        sku: '1234567890123',
        defaultSupplierRate: 140,
        defaultBuyerRate: 150,
        defaultRetailPrice: 160,
        notes: 'Fine grain',
        createdAt: DateTime.now(),
      );

      await repository.saveProduct(newProduct);

      final products = await repository.watchProducts().first;
      expect(products.length, equals(1));
      expect(products.first.name, equals('Sugar 1kg'));
      expect(products.first.sku, equals('1234567890123'));
      expect(products.first.defaultRetailPrice, equals(160));
      expect(products.first.isArchived, isFalse);
    });

    test('saveProduct updates existing product', () async {
      final product = Product(
        id: 'p1',
        name: 'Rice',
        defaultSupplierRate: 100,
        defaultBuyerRate: 110,
        defaultRetailPrice: 120,
        createdAt: DateTime.now(),
      );
      await repository.saveProduct(product);

      final updated = product.copyWith(
        name: 'Basmati Rice',
        defaultRetailPrice: 130,
      );
      await repository.saveProduct(updated);

      final fetched = await repository.getProduct('p1');
      expect(fetched?.name, equals('Basmati Rice'));
      expect(fetched?.defaultRetailPrice, equals(130));
    });

    test('saveProduct throws ValidationException when name is empty or prices negative', () async {
      final invalidName = Product(
        id: '',
        name: '   ',
        defaultSupplierRate: 100,
        defaultBuyerRate: 110,
        defaultRetailPrice: 120,
        createdAt: DateTime.now(),
      );
      expect(
        () => repository.saveProduct(invalidName),
        throwsA(isA<ValidationException>()),
      );

      final negativePrice = Product(
        id: '',
        name: 'Salt',
        defaultSupplierRate: -5,
        defaultBuyerRate: 110,
        defaultRetailPrice: 120,
        createdAt: DateTime.now(),
      );
      expect(
        () => repository.saveProduct(negativePrice),
        throwsA(isA<ValidationException>()),
      );
    });

    test('checkArchiveWarnings returns warnings when referenced in demand or bills', () async {
      await firestore.collection('demandItems').add({
        'productId': 'p1',
        'quantity': 5,
      });
      await firestore.collection('summaryItems').add({
        'productId': 'p1',
        'quantity': 10,
      });
      await firestore.collection('billItems').add({
        'productId': 'p1',
        'quantity': 2,
      });

      final warnings = await repository.checkArchiveWarnings('p1');
      expect(warnings.length, equals(3));
      expect(warnings, contains('Product has active demand items'));
      expect(warnings, contains('Product has active buying list items'));
      expect(warnings, contains('Product is referenced in bills'));
    });

    test(
      'getProductBySku returns product when productSkus entry exists (S2)',
      () async {
        final product = Product(
          id: 'p-sku-1',
          name: 'Tea 500g',
          sku: '8901234567890',
          defaultSupplierRate: 500,
          defaultBuyerRate: 550,
          defaultRetailPrice: 600,
          createdAt: DateTime.now(),
        );
        await repository.saveProduct(product);

        final found = await repository.getProductBySku('8901234567890');
        expect(found, isNotNull);
        expect(found?.name, equals('Tea 500g'));
        expect(found?.id, equals('p-sku-1'));

        final notFound = await repository.getProductBySku('0000000000000');
        expect(notFound, isNull);
      },
    );

    test(
      'saveProduct batches productSkus creation, updates and deletions (S2)',
      () async {
        final product = Product(
          id: 'p-batched',
          name: 'Soap',
          sku: 'SKU-OLD',
          defaultSupplierRate: 50,
          defaultBuyerRate: 60,
          defaultRetailPrice: 70,
          createdAt: DateTime.now(),
        );
        await repository.saveProduct(product);

        // Verify productSkus/SKU-OLD created
        final oldSkuDoc = await firestore
            .collection('productSkus')
            .doc('SKU-OLD')
            .get();
        expect(oldSkuDoc.exists, isTrue);
        expect(oldSkuDoc.data()?['productId'], equals('p-batched'));

        // Update SKU to SKU-NEW
        final updated = product.copyWith(sku: 'SKU-NEW');
        await repository.saveProduct(updated);

        // Verify old SKU deleted, new SKU created
        final oldSkuAfter = await firestore
            .collection('productSkus')
            .doc('SKU-OLD')
            .get();
        expect(oldSkuAfter.exists, isFalse);

        final newSkuDoc = await firestore
            .collection('productSkus')
            .doc('SKU-NEW')
            .get();
        expect(newSkuDoc.exists, isTrue);
        expect(newSkuDoc.data()?['productId'], equals('p-batched'));

        // Remove SKU (set to null)
        final removedSku = updated.copyWith(sku: null);
        await repository.saveProduct(removedSku);

        final newSkuAfter = await firestore
            .collection('productSkus')
            .doc('SKU-NEW')
            .get();
        expect(newSkuAfter.exists, isFalse);
      },
    );
  });
}
