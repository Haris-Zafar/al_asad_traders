import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/products/data/tag_repository.dart';
import 'package:al_asad_traders/features/products/models/product_tag.dart';
import 'package:al_asad_traders/features/products/models/tag.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TagRepository & Models (S3)', () {
    late FakeFirebaseFirestore firestore;
    late TagRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = TagRepository(firestore);
    });

    test('Tag model toMap and fromMap serialization', () {
      final now = DateTime.now();
      final tag = Tag(id: 'spices', name: 'Spices', createdAt: now);
      final map = tag.toMap();
      expect(map['name'], equals('Spices'));

      final deserialized = Tag.fromMap(map, 'spices');
      expect(deserialized.id, equals('spices'));
      expect(deserialized.name, equals('Spices'));
    });

    test('ProductTag model toMap and fromMap serialization', () {
      final productTag = const ProductTag(
        id: 'p1_spices',
        productId: 'p1',
        tagId: 'spices',
      );
      final map = productTag.toMap();
      expect(map['productId'], equals('p1'));
      expect(map['tagId'], equals('spices'));

      final deserialized = ProductTag.fromMap(map, 'p1_spices');
      expect(deserialized.id, equals('p1_spices'));
      expect(deserialized.productId, equals('p1'));
      expect(deserialized.tagId, equals('spices'));
    });

    test('createTag creates tag with doc ID as lowercase name', () async {
      final tag = await repository.createTag('  Spices & Herbs  ');
      expect(tag.id, equals('spices & herbs'));
      expect(tag.name, equals('Spices & Herbs'));

      final doc = await firestore
          .collection('tags')
          .doc('spices & herbs')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['name'], equals('Spices & Herbs'));
    });

    test('createTag throws ValidationException when name is empty', () async {
      expect(
        () => repository.createTag('   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('watchTags returns tags sorted by name alphabetically', () async {
      await repository.createTag('Tea');
      await repository.createTag('Bakery');
      await repository.createTag('Spices');

      final tags = await repository.watchTags().first;
      expect(tags.length, equals(3));
      expect(tags[0].name, equals('Bakery'));
      expect(tags[1].name, equals('Spices'));
      expect(tags[2].name, equals('Tea'));
    });

    test(
      'assignTagsToProduct manages composite key productTags documents (S3)',
      () async {
        final tag1 = await repository.createTag('Spices');
        final tag2 = await repository.createTag('Tea');

        await repository.assignTagsToProduct('p1', [tag1.id, tag2.id]);

        // Verify composite key productTags documents exist
        final doc1 = await firestore
            .collection('productTags')
            .doc('p1_${tag1.id}')
            .get();
        expect(doc1.exists, isTrue);
        expect(doc1.data()?['productId'], equals('p1'));
        expect(doc1.data()?['tagId'], equals(tag1.id));

        final doc2 = await firestore
            .collection('productTags')
            .doc('p1_${tag2.id}')
            .get();
        expect(doc2.exists, isTrue);

        final productTags = await repository.watchProductTags().first;
        expect(productTags.length, equals(2));

        // Remove tag1 from product p1
        await repository.assignTagsToProduct('p1', [tag2.id]);

        final doc1After = await firestore
            .collection('productTags')
            .doc('p1_${tag1.id}')
            .get();
        expect(doc1After.exists, isFalse);

        final doc2After = await firestore
            .collection('productTags')
            .doc('p1_${tag2.id}')
            .get();
        expect(doc2After.exists, isTrue);
      },
    );

    test('watchTagsForProduct streams tag IDs for product', () async {
      final tag = await repository.createTag('Grocery');
      await repository.assignTagsToProduct('p100', [tag.id]);

      final tagIds = await repository.watchTagsForProduct('p100').first;
      expect(tagIds, contains('grocery'));
    });
  });
}
