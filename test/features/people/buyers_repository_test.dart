import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/people/data/buyers_repository.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuyersRepository (S9)', () {
    late FakeFirebaseFirestore firestore;
    late BuyersRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = BuyersRepository(firestore);
    });

    test('getBuyer returns null when buyer does not exist', () async {
      final buyer = await repository.getBuyer('non_existent');
      expect(buyer, isNull);
    });

    test('saveBuyer creates new buyer and retrieves it', () async {
      final newBuyer = Buyer(
        id: '',
        name: 'John Doe',
        contactNumber: '03001234567',
        address: '123 Street',
        notes: 'Regular buyer',
        createdAt: DateTime.now(),
      );

      await repository.saveBuyer(newBuyer);

      final buyers = await repository.watchBuyers().first;
      expect(buyers.length, equals(1));
      expect(buyers.first.name, equals('John Doe'));
      expect(buyers.first.contactNumber, equals('03001234567'));
      expect(buyers.first.isArchived, isFalse);
    });

    test('saveBuyer updates existing buyer', () async {
      final buyer = Buyer(
        id: 'buyer_1',
        name: 'Old Name',
        contactNumber: '111',
        createdAt: DateTime.now(),
      );
      await repository.saveBuyer(buyer);

      final updated = buyer.copyWith(name: 'New Name', contactNumber: '222');
      await repository.saveBuyer(updated);

      final fetched = await repository.getBuyer('buyer_1');
      expect(fetched?.name, equals('New Name'));
      expect(fetched?.contactNumber, equals('222'));
    });

    test('saveBuyer throws ValidationException when name is empty', () async {
      final invalidBuyer = Buyer(
        id: '',
        name: '   ',
        createdAt: DateTime.now(),
      );

      expect(
        () => repository.saveBuyer(invalidBuyer),
        throwsA(isA<ValidationException>()),
      );
    });

    test('checkArchiveWarnings returns warnings for non-zero balance, bills, demands', () async {
      // Setup Firestore data
      await firestore.collection('ledgerEntries').add({
        'buyerId': 'b1',
        'amount': 500,
      });
      await firestore.collection('bills').add({
        'buyerId': 'b1',
        'status': 'draft',
      });
      await firestore.collection('demands').add({
        'buyerId': 'b1',
        'status': 'open',
      });

      final warnings = await repository.checkArchiveWarnings('b1');
      expect(warnings.length, equals(3));
      expect(warnings, contains('Buyer has a non-zero ledger balance'));
      expect(warnings, contains('Buyer has draft or issued bills'));
      expect(warnings, contains('Buyer has open demands'));
    });

    test(
      'archiveBuyer and unarchiveBuyer toggle archivedAt timestamp',
      () async {
        final buyer = Buyer(
          id: 'buyer_to_archive',
          name: 'Target Buyer',
          createdAt: DateTime.now(),
        );
        await repository.saveBuyer(buyer);

        await repository.archiveBuyer('buyer_to_archive');
        var fetched = await repository.getBuyer('buyer_to_archive');
        expect(fetched?.isArchived, isTrue);

        await repository.unarchiveBuyer('buyer_to_archive');
        fetched = await repository.getBuyer('buyer_to_archive');
        expect(fetched?.isArchived, isFalse);
      },
    );
  });
}
