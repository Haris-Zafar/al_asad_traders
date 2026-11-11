import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/features/people/data/bank_accounts_repository.dart';
import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BankAccountsRepository (S10, T-11)', () {
    late FakeFirebaseFirestore firestore;
    late BankAccountsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = BankAccountsRepository(firestore);
    });

    test('saveBankAccount creates profile bank account and retrieves it via stream', () async {
      final account = BankAccount(
        id: '',
        profileId: 'main',
        name: 'Meezan Bank',
        accountNumber: 'PK36MEZN000123',
        notes: 'Main account',
        createdAt: DateTime.now(),
      );

      await repository.saveBankAccount(account);

      final accounts = await repository.watchProfileBankAccounts().first;
      expect(accounts.length, equals(1));
      expect(accounts.first.name, equals('Meezan Bank'));
      expect(accounts.first.accountNumber, equals('PK36MEZN000123'));
      expect(accounts.first.profileId, equals('main'));
      expect(accounts.first.hasValidOwner, isTrue);
    });

    test(
      'saveBankAccount creates buyer bank account and retrieves it via stream',
      () async {
        final account = BankAccount(
          id: '',
          buyerId: 'b1',
          name: 'HBL',
          accountNumber: '12345678',
          createdAt: DateTime.now(),
        );

        await repository.saveBankAccount(account);

        final accounts = await repository.watchBuyerBankAccounts('b1').first;
        expect(accounts.length, equals(1));
        expect(accounts.first.name, equals('HBL'));
        expect(accounts.first.buyerId, equals('b1'));
        expect(accounts.first.hasValidOwner, isTrue);
      },
    );

    test('saveBankAccount creates supplier bank account and retrieves it via stream', () async {
      final account = BankAccount(
        id: '',
        supplierId: 's1',
        name: 'UBL',
        accountNumber: '87654321',
        createdAt: DateTime.now(),
      );

      await repository.saveBankAccount(account);

      final accounts = await repository.watchSupplierBankAccounts('s1').first;
      expect(accounts.length, equals(1));
      expect(accounts.first.name, equals('UBL'));
      expect(accounts.first.supplierId, equals('s1'));
      expect(accounts.first.hasValidOwner, isTrue);
    });

    test(
      'saveBankAccount throws ValidationException when bank name is empty',
      () async {
        final invalid = BankAccount(
          id: '',
          profileId: 'main',
          name: '  ',
          accountNumber: '1234',
          createdAt: DateTime.now(),
        );

        expect(
          () => repository.saveBankAccount(invalid),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'saveBankAccount throws ValidationException when account number is empty',
      () async {
        final invalid = BankAccount(
          id: '',
          profileId: 'main',
          name: 'Meezan',
          accountNumber: '  ',
          createdAt: DateTime.now(),
        );

        expect(
          () => repository.saveBankAccount(invalid),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('saveBankAccount throws ValidationException when owner is missing or multiple', () async {
      final noOwner = BankAccount(
        id: '',
        name: 'Bank',
        accountNumber: '1234',
        createdAt: DateTime.now(),
      );

      expect(
        () => repository.saveBankAccount(noOwner),
        throwsA(isA<ValidationException>()),
      );

      final multiOwner = BankAccount(
        id: '',
        profileId: 'main',
        buyerId: 'b1',
        name: 'Bank',
        accountNumber: '1234',
        createdAt: DateTime.now(),
      );

      expect(
        () => repository.saveBankAccount(multiOwner),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'archiveBankAccount and unarchiveBankAccount toggle archivedAt',
      () async {
        final account = BankAccount(
          id: 'ba_to_archive',
          profileId: 'main',
          name: 'Meezan Bank',
          accountNumber: '1234',
          createdAt: DateTime.now(),
        );

        await repository.saveBankAccount(account);

        await repository.archiveBankAccount('ba_to_archive');
        var accounts = await repository.watchProfileBankAccounts().first;
        expect(accounts.first.isArchived, isTrue);

        await repository.unarchiveBankAccount('ba_to_archive');
        accounts = await repository.watchProfileBankAccounts().first;
        expect(accounts.first.isArchived, isFalse);
      },
    );
  });
}
