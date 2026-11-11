import 'package:al_asad_traders/features/people/data/bank_accounts_repository.dart';
import 'package:al_asad_traders/features/people/data/buyers_repository.dart';
import 'package:al_asad_traders/features/people/data/profile_repository.dart';
import 'package:al_asad_traders/features/people/data/suppliers_repository.dart';
import 'package:al_asad_traders/features/people/models/bank_account.dart';
import 'package:al_asad_traders/features/people/models/buyer.dart';
import 'package:al_asad_traders/features/people/models/profile.dart';
import 'package:al_asad_traders/features/people/models/supplier.dart';
import 'package:al_asad_traders/features/people/ui/business_profile_screen.dart';
import 'package:al_asad_traders/features/people/ui/buyer_detail_screen.dart';
import 'package:al_asad_traders/features/people/ui/supplier_detail_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('Bank Accounts Management UI (S10, T-11)', () {
    late FakeFirebaseFirestore firestore;
    late BankAccountsRepository bankRepo;
    late BuyersRepository buyersRepo;
    late SuppliersRepository suppliersRepo;
    late ProfileRepository profileRepo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      bankRepo = BankAccountsRepository(firestore);
      buyersRepo = BuyersRepository(firestore);
      suppliersRepo = SuppliersRepository(firestore);
      profileRepo = ProfileRepository(firestore);
    });

    testWidgets(
      'BuyerDetailScreen opens BankAccountsListSheet and adds a bank account',
      (WidgetTester tester) async {
        final buyer = Buyer(
          id: 'b1',
          name: 'Ali Khan',
          createdAt: DateTime.now(),
        );
        await buyersRepo.saveBuyer(buyer);

        final container = ProviderContainer(
          overrides: [
            bankAccountsRepositoryProvider.overrideWithValue(bankRepo),
            buyersRepositoryProvider.overrideWithValue(buyersRepo),
          ],
        );

        await tester.pumpApp(
          const BuyerDetailScreen(buyerId: 'b1'),
          container: container,
        );
        await tester.pumpAndSettle();

        // Tap bank accounts row
        await tester.ensureVisible(
          find.byKey(const Key('buyer_bank_accounts_row')),
        );
        await tester.tap(find.byKey(const Key('buyer_bank_accounts_row')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('bank_accounts_list_sheet')),
          findsOneWidget,
        );
        expect(find.text('No bank accounts added'), findsOneWidget);

        // Tap Add Bank Account
        await tester.tap(find.byKey(const Key('add_bank_account_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('bank_account_form_sheet')),
          findsOneWidget,
        );

        // Fill form
        await tester.enterText(
          find.byKey(const Key('bank_name_field')),
          'Meezan Bank',
        );
        await tester.enterText(
          find.byKey(const Key('account_number_field')),
          'PK36MEZN00012345678901',
        );
        await tester.tap(find.byKey(const Key('save_bank_account_button')));
        await tester.pumpAndSettle();

        final accounts = await bankRepo.watchBuyerBankAccounts('b1').first;
        expect(accounts.length, equals(1));
        expect(accounts.first.name, equals('Meezan Bank'));
        expect(accounts.first.accountNumber, equals('PK36MEZN00012345678901'));
        expect(accounts.first.buyerId, equals('b1'));
      },
    );

    testWidgets('SupplierDetailScreen manages bank accounts for supplier', (
      WidgetTester tester,
    ) async {
      final supplier = Supplier(
        id: 's1',
        name: 'ABC Supplier',
        createdAt: DateTime.now(),
      );
      await suppliersRepo.saveSupplier(supplier);

      final account = BankAccount(
        id: 'ba_s1',
        supplierId: 's1',
        name: 'HBL',
        accountNumber: '9876543210',
        createdAt: DateTime.now(),
      );
      await bankRepo.saveBankAccount(account);

      final container = ProviderContainer(
        overrides: [
          bankAccountsRepositoryProvider.overrideWithValue(bankRepo),
          suppliersRepositoryProvider.overrideWithValue(suppliersRepo),
        ],
      );

      await tester.pumpApp(
        const SupplierDetailScreen(supplierId: 's1'),
        container: container,
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('supplier_bank_accounts_row')),
      );
      await tester.tap(find.byKey(const Key('supplier_bank_accounts_row')));
      await tester.pumpAndSettle();

      expect(find.text('HBL'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      // Edit bank account
      await tester.tap(find.byKey(const Key('edit_bank_account_ba_s1')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('bank_name_field')),
        'HBL Main Branch',
      );
      await tester.tap(find.byKey(const Key('save_bank_account_button')));
      await tester.pumpAndSettle();

      final accounts = await bankRepo.watchSupplierBankAccounts('s1').first;
      expect(accounts.first.name, equals('HBL Main Branch'));
    });

    testWidgets('BusinessProfileScreen manages own profile bank accounts', (
      WidgetTester tester,
    ) async {
      final profile = Profile(
        id: 'main',
        businessName: 'Al Asad Traders',
        businessAddress: 'Main Bazar',
        contactNumber1: '03001234567',
      );
      await profileRepo.saveProfile(profile);

      final account = BankAccount(
        id: 'ba_p1',
        profileId: 'main',
        name: 'UBL',
        accountNumber: '1122334455',
        createdAt: DateTime.now(),
      );
      await bankRepo.saveBankAccount(account);

      final container = ProviderContainer(
        overrides: [
          bankAccountsRepositoryProvider.overrideWithValue(bankRepo),
          profileRepositoryProvider.overrideWithValue(profileRepo),
        ],
      );

      await tester.pumpApp(const BusinessProfileScreen(), container: container);
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('profile_bank_accounts_row')),
      );
      await tester.tap(find.byKey(const Key('profile_bank_accounts_row')));
      await tester.pumpAndSettle();

      expect(find.text('UBL'), findsOneWidget);
      expect(find.text('1122334455'), findsOneWidget);

      // Archive bank account
      await tester.tap(find.byKey(const Key('archive_bank_account_ba_p1')));
      await tester.pumpAndSettle();

      expect(find.text('Yes, hide'), findsOneWidget);
      await tester.tap(find.text('Yes, hide'));
      await tester.pumpAndSettle();

      final accounts = await bankRepo.watchProfileBankAccounts().first;
      expect(accounts.first.isArchived, isTrue);
    });
  });
}
