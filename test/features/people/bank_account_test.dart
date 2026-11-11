import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BankAccount Model & Validation (S10, T-11)', () {
    final now = DateTime.now();

    test('hasValidOwner returns true when exactly one owner is set', () {
      final profileAccount = BankAccount(
        id: 'ba1',
        profileId: 'main',
        name: 'Meezan Bank',
        accountNumber: 'PK36MEZN000123',
        createdAt: now,
      );
      expect(profileAccount.hasValidOwner, isTrue);

      final buyerAccount = BankAccount(
        id: 'ba2',
        buyerId: 'b1',
        name: 'HBL',
        accountNumber: '12345678',
        createdAt: now,
      );
      expect(buyerAccount.hasValidOwner, isTrue);

      final supplierAccount = BankAccount(
        id: 'ba3',
        supplierId: 's1',
        name: 'UBL',
        accountNumber: '87654321',
        createdAt: now,
      );
      expect(supplierAccount.hasValidOwner, isTrue);
    });

    test(
      'hasValidOwner returns false when no owner or multiple owners are set',
      () {
        final noOwnerAccount = BankAccount(
          id: 'ba_none',
          name: 'No Owner Bank',
          accountNumber: '0000',
          createdAt: now,
        );
        expect(noOwnerAccount.hasValidOwner, isFalse);

        final multiOwnerAccount = BankAccount(
          id: 'ba_multi',
          profileId: 'main',
          buyerId: 'b1',
          name: 'Multi Owner Bank',
          accountNumber: '9999',
          createdAt: now,
        );
        expect(multiOwnerAccount.hasValidOwner, isFalse);
      },
    );

    test(
      'fromMap and toMap correctly serialize and deserialize BankAccount',
      () {
        final account = BankAccount(
          id: 'ba_test',
          profileId: 'main',
          buyerId: null,
          supplierId: null,
          name: 'Meezan Bank',
          accountNumber: 'PK36MEZN00012345678901',
          notes: 'Main business account',
          archivedAt: null,
          createdAt: now,
        );

        final map = account.toMap();
        expect(map['profileId'], equals('main'));
        expect(map['buyerId'], isNull);
        expect(map['supplierId'], isNull);
        expect(map['name'], equals('Meezan Bank'));
        expect(map['accountNumber'], equals('PK36MEZN00012345678901'));
        expect(map['notes'], equals('Main business account'));
        expect(map['archivedAt'], isNull);
        expect(map['createdAt'], isA<Timestamp>());

        final deserialized = BankAccount.fromMap(map, 'ba_test');
        expect(deserialized.id, equals('ba_test'));
        expect(deserialized.profileId, equals('main'));
        expect(deserialized.name, equals('Meezan Bank'));
        expect(deserialized.accountNumber, equals('PK36MEZN00012345678901'));
        expect(deserialized.hasValidOwner, isTrue);
      },
    );

    test('copyWith produces updated BankAccount instance', () {
      final account = BankAccount(
        id: 'ba1',
        profileId: 'main',
        name: 'Old Bank',
        accountNumber: '1111',
        createdAt: now,
      );

      final updated = account.copyWith(name: 'New Bank', accountNumber: '2222');
      expect(updated.name, equals('New Bank'));
      expect(updated.accountNumber, equals('2222'));
      expect(updated.profileId, equals('main'));
    });
  });
}
