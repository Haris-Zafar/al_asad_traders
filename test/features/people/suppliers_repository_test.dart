import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/people/data/suppliers_repository.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuppliersRepository (S9)', () {
    late FakeFirebaseFirestore firestore;
    late SuppliersRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = SuppliersRepository(firestore);
    });

    test('getSupplier returns null when supplier does not exist', () async {
      final supplier = await repository.getSupplier('non_existent');
      expect(supplier, isNull);
    });

    test('saveSupplier creates new supplier and retrieves it', () async {
      final newSupplier = Supplier(
        id: '',
        name: 'ABC Trader',
        contactNumber: '03009876543',
        address: 'Wholesale Market',
        notes: 'Main wheat supplier',
        createdAt: DateTime.now(),
      );

      await repository.saveSupplier(newSupplier);

      final suppliers = await repository.watchSuppliers().first;
      expect(suppliers.length, equals(1));
      expect(suppliers.first.name, equals('ABC Trader'));
      expect(suppliers.first.contactNumber, equals('03009876543'));
      expect(suppliers.first.isArchived, isFalse);
    });

    test('saveSupplier updates existing supplier', () async {
      final supplier = Supplier(
        id: 'supp_1',
        name: 'Old Supplier Name',
        contactNumber: '111',
        createdAt: DateTime.now(),
      );
      await repository.saveSupplier(supplier);

      final updated = supplier.copyWith(
        name: 'New Supplier Name',
        contactNumber: '222',
      );
      await repository.saveSupplier(updated);

      final fetched = await repository.getSupplier('supp_1');
      expect(fetched?.name, equals('New Supplier Name'));
      expect(fetched?.contactNumber, equals('222'));
    });

    test(
      'saveSupplier throws ValidationException when name is empty',
      () async {
        final invalidSupplier = Supplier(
          id: '',
          name: '   ',
          createdAt: DateTime.now(),
        );

        expect(
          () => repository.saveSupplier(invalidSupplier),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'checkArchiveWarnings returns warnings for open purchase lists',
      () async {
        await firestore.collection('summaries').add({
          'supplierId': 's1',
          'status': 'open',
        });

        final warnings = await repository.checkArchiveWarnings('s1');
        expect(warnings.length, equals(1));
        expect(warnings, contains('Supplier has open purchase lists'));
      },
    );

    test(
      'archiveSupplier and unarchiveSupplier toggle archivedAt timestamp',
      () async {
        final supplier = Supplier(
          id: 'supp_to_archive',
          name: 'Target Supplier',
          createdAt: DateTime.now(),
        );
        await repository.saveSupplier(supplier);

        await repository.archiveSupplier('supp_to_archive');
        var fetched = await repository.getSupplier('supp_to_archive');
        expect(fetched?.isArchived, isTrue);

        await repository.unarchiveSupplier('supp_to_archive');
        fetched = await repository.getSupplier('supp_to_archive');
        expect(fetched?.isArchived, isFalse);
      },
    );
  });
}
