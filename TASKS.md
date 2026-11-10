## T-01 Project setup, CI & rules-test scaffold | Phase 0
branch: chore/T-01-setup
depends: none
stories: none
goal: Set up project dependencies, CI workflow, rules testing infrastructure, and check_hardcoded script.
read: docs/TECH_STACK.md; docs/GIT_WORKFLOW.md; docs/TESTING.md
touch: pubspec.yaml, .github/workflows/ci.yml, rules_test/**, tool/check_hardcoded.sh
done-when: flutter analyze, flutter test, check_hardcoded.sh pass, and rules_test npm test runs
tests: CI workflow validity and empty rule test execution
commits: chore(setup): add dependencies and rules-test scaffold (T-01); ci(setup): configure github actions workflow (T-01); chore(setup): add check_hardcoded script (T-01)

## T-02 Theme, sizing, strings, errors & format | Phase 0
branch: feature/T-02-theme
depends: T-01
stories: none
goal: Implement design system theme, colors, typography, AppSizes, strings constants, error hierarchy, and formatters.
read: docs/DESIGN_SYSTEM.md; docs/ARCHITECTURE.md (Error handling); docs/UI_PLAN.md (Plain words)
touch: lib/core/theme/**, lib/core/strings.dart, lib/core/errors/**, lib/core/format/**, test/core/**
done-when: Theme builds cleanly and formatters/errors pass unit tests
tests: AppException mapping and date/money formatting tests
commits: feat(theme): implement design tokens, AppColors and text scale (T-02); feat(core): add strings constants, error hierarchy and formatters (T-02); test(core): add tests for formatting and AppException mapping (T-02)

## T-03 Shared widgets & TestEnv helpers | Phase 0
branch: feature/T-03-widgets
depends: T-02
stories: none
goal: Build core shared widgets and unit/widget test helpers.
read: docs/DESIGN_SYSTEM.md (Shared widgets); docs/TESTING.md (Helpers)
touch: lib/core/widgets/**, test/helpers/**, test/core/widgets/**
done-when: All shared widgets render without overflow at 1.0 and 1.8 font scales
tests: Widget tests for AppScaffold, AppButton, AppTextField, MoneyText, StatusChip, SyncChip at scale 1.0 and 1.8
commits: feat(widgets): build shared UI components (T-03); test(helpers): add TestEnv and pumpApp testing utilities (T-03); test(widgets): add widget tests for shared components (T-03)

## T-04 Router, app shell & tab navigation | Phase 0
branch: feature/T-04-router
depends: T-03
stories: none
goal: Configure GoRouter with StatefulShellRoute for 4 bottom navigation tabs.
read: docs/UI_PLAN.md (Navigation); docs/ARCHITECTURE.md (Folders)
touch: lib/app/**, test/app/**
done-when: App launches into 4-tab shell with working backstack navigation
tests: Widget tests for router navigation between shell tabs and Android back button handling
commits: feat(app): configure GoRouter with shell tab navigation (T-04); test(app): add router and tab navigation tests (T-04)

## T-05 Authentication & login screen | Phase 1
branch: feature/T-05-auth-login
depends: T-04
stories: S32
goal: Implement Firebase Auth persistent login and login screen.
read: docs/UI_PLAN.md (Screens - /login); docs/DATABASE.md (Security rules); wholesale_project.md (S32)
touch: lib/features/auth_sync/**, test/features/auth_sync/**, firestore.rules, rules_test/**
done-when: Login screen authenticates valid owner credentials and stays logged in
tests: Unit test for AuthRepository login, fake auth login flow, and rules test for owner auth
commits: feat(auth): implement AuthRepository and login provider (T-05); feat(auth): build LoginScreen with persistent auth (T-05); test(auth): add auth repository, provider, and rules tests (T-05)

## T-06 First setup & device letter claim | Phase 1
branch: feature/T-06-device-setup
depends: T-05
stories: S33
goal: Execute first login device setup transaction to claim invoice letter and initiate full sync.
read: docs/DATABASE.md (Atomic operations); wholesale_project.md (Invoice numbers, S33); docs/UI_PLAN.md (/setup)
touch: lib/features/auth_sync/**, test/features/auth_sync/**, firestore.rules, rules_test/**
done-when: First login assigns next available letter (e.g. A) and completes initial download
tests: Device letter claim transaction test, increment registry test, and rules test for device registration
commits: feat(auth): implement device letter claim transaction and setup service (T-06); feat(auth): add SetupScreen with progress indicator (T-06); test(auth): add device claim unit tests and security rule tests (T-06)

## T-07 Sync state provider & sync chip | Phase 1
branch: feature/T-07-sync-state
depends: T-06
stories: S34
goal: Track Firestore pending writes and display real-time Synced / Not synced yet status.
read: docs/DATABASE.md (Sync); docs/DESIGN_SYSTEM.md (Shared widgets); wholesale_project.md (S34)
touch: lib/features/auth_sync/**, test/features/auth_sync/**
done-when: SyncStateProvider reflects pending write state and updates SyncChip
tests: SyncTracker unit test with pending writes completer and widget test for SyncChip state updates
commits: feat(sync): implement SyncStateProvider listening to pending writes (T-07); feat(sync): wire SyncChip to sync state provider (T-07); test(sync): add sync tracker and provider tests (T-07)

## T-08 Logout warning & dialog | Phase 1
branch: feature/T-08-logout
depends: T-07
stories: S35
goal: Implement logout flow that clears persistence and warns if un-synced writes exist.
read: docs/DATABASE.md (Sync - Logout); docs/UI_PLAN.md (Log out dialog); wholesale_project.md (S35)
touch: lib/features/auth_sync/**, test/features/auth_sync/**
done-when: Logout shows warning when unsynced data exists and clears cache on confirm
tests: Unit test for logout cache clearance and widget test for unsynced logout dialog warning
commits: feat(auth): implement logout action with persistence clearing (T-08); feat(auth): add logout confirmation dialog with sync warning (T-08); test(auth): add logout flow and dialog widget tests (T-08)

## T-09 Profile screen & My business | Phase 1
branch: feature/T-09-profile
depends: T-05
stories: S11
goal: Manage business profile information (name, address, two contact numbers).
read: docs/DATABASE.md (Collections - profile); docs/UI_PLAN.md (/more/business); wholesale_project.md (S11)
touch: lib/features/people/**, test/features/people/**, firestore.rules, rules_test/**
done-when: Business profile can be updated and retrieved from single 'main' document
tests: ProfileRepository unit test, ProfileScreen form test, and rules test for profile 'main' document
commits: feat(people): implement Profile model and ProfileRepository (T-09); feat(people): build BusinessProfileScreen form (T-09); test(people): add profile repository, UI, and security rules tests (T-09)

## T-10 Buyer and supplier management | Phase 2
branch: feature/T-10-people
depends: T-05
stories: S9
goal: Create, update, list, search, and archive buyers and suppliers.
read: docs/DATABASE.md (Collections - buyers/suppliers); docs/UI_PLAN.md (/buyers, /suppliers); wholesale_project.md (S9, Archiving)
touch: lib/features/people/**, test/features/people/**, firestore.rules, rules_test/**
done-when: Buyer and supplier records can be created, searched, updated, and archived
tests: Buyers/Suppliers repository CRUD tests, archive warning validation, and rules tests
commits: feat(people): implement Buyer and Supplier models and repositories (T-10); feat(people): build buyer/supplier list and detail screens (T-10); test(people): add buyer/supplier repository, UI, and rules tests (T-10)

## T-11 Bank accounts (own, buyers, suppliers) | Phase 2
branch: feature/T-11-bank-accounts
depends: T-09, T-10
stories: S10
goal: Save and manage bank accounts for business profile, buyers, and suppliers.
read: docs/DATABASE.md (Collections - bankAccounts); wholesale_relationships.md (BANK_ACCOUNT); wholesale_project.md (S10)
touch: lib/features/people/**, test/features/people/**, firestore.rules, rules_test/**
done-when: Bank accounts are linked to exactly one owner (profile, buyer, or supplier)
tests: BankAccount validation test (exactly one owner ID set) and security rules single-owner enforcement test
commits: feat(people): implement BankAccount model and repository (T-11); feat(people): build bank account management UI for buyers, suppliers, and profile (T-11); test(people): add bank account validation, UI, and security rules tests (T-11)

## T-12 Add and list products | Phase 2
branch: feature/T-12-products
depends: T-05
stories: S1
goal: Add products with default prices and notes, list and search products.
read: docs/DATABASE.md (Collections - products); docs/UI_PLAN.md (/products); wholesale_project.md (S1)
touch: lib/features/products/**, test/features/products/**, firestore.rules, rules_test/**
done-when: Products are saved to Firestore and appear in searchable product list
tests: ProductRepository CRUD unit tests, product list search test, and security rules tests
commits: feat(products): implement Product model and ProductRepository (T-12); feat(products): build ProductListScreen and AddProductScreen (T-12); test(products): add product repository, UI, and security rules tests (T-12)

## T-13 Product barcode scanning & lookup | Phase 2
branch: feature/T-13-barcode
depends: T-12
stories: S2
goal: Reserve product SKUs in productSkus collection and support barcode scanning lookup.
read: docs/DATABASE.md (Atomic operations - barcode); wholesale_project.md (S2, Uniqueness); docs/UI_PLAN.md (Scan)
touch: lib/features/products/**, test/features/products/**, firestore.rules, rules_test/**
done-when: Barcode scan looks up product via productSkus collection; barcode change is batched
tests: Barcode lookup unit test, productSkus batch create/delete test, and rules test for productSkus
commits: feat(products): implement productSkus lookup and barcode batch management (T-13); feat(products): integrate MobileScanner barcode scanner UI (T-13); test(products): add barcode lookup, scanner mock, and security rules tests (T-13)

## T-14 Product tagging and filtering | Phase 2
branch: feature/T-14-product-tags
depends: T-12
stories: S3
goal: Tag products and filter product lists by tag.
read: docs/DATABASE.md (Collections - tags, productTags); wholesale_project.md (S3, Uniqueness)
touch: lib/features/products/**, test/features/products/**, firestore.rules, rules_test/**
done-when: Tags can be assigned to products and product list filters by selected tag
tests: Tag repository tests, composite key productTags test, and security rules tests for tags
commits: feat(products): implement Tag and ProductTag models and repository (T-14); feat(products): add tag chip filtering to ProductListScreen (T-14); test(products): add tag management, UI filter, and security rules tests (T-14)

## T-15 Archive products | Phase 2
branch: feature/T-15-archive-product
depends: T-12
stories: S4
goal: Soft-delete/archive products and hide archived products from pickers.
read: wholesale_project.md (S4, Archiving); docs/UI_PLAN.md (Interaction rules)
touch: lib/features/products/**, test/features/products/**
done-when: Archiving product sets archivedAt timestamp and hides it from picker lists
tests: Unit test for product archive logic and picker filtering excluding archived products
commits: feat(products): implement product archiving logic in repository (T-15); feat(products): add archive action and confirmation dialog to ProductDetailScreen (T-15); test(products): add product archive unit and widget tests (T-15)

## T-16 Buyer and supplier rates | Phase 2
branch: feature/T-16-rates
depends: T-10, T-12
stories: S5
goal: Manage buyer-specific and supplier-specific rate entries with effective dates.
read: docs/DATABASE.md (Collections - buyerRates, supplierRates); wholesale_project.md (S5, Prices)
touch: lib/features/prices/**, test/features/prices/**, firestore.rules, rules_test/**
done-when: Buyer and supplier rates are saved with composite IDs (personId_productId_effectiveDate)
tests: Rate creation tests, same-day rate overwrite test, and security rules tests for rates
commits: feat(prices): implement BuyerRate and SupplierRate models and repositories (T-16); feat(prices): build rate management UI on product and person detail screens (T-16); test(prices): add rate repository, overwrite logic, and security rules tests (T-16)

## T-17 Retail price history | Phase 2
branch: feature/T-17-retail-prices
depends: T-12
stories: S6
goal: Record and manage retail price history entries with effective dates.
read: docs/DATABASE.md (Collections - retailPrices); wholesale_project.md (S6, Prices)
touch: lib/features/prices/**, test/features/prices/**, firestore.rules, rules_test/**
done-when: Retail prices are stored with composite ID (productId_effectiveDate) and queried by date
tests: Retail price creation tests and same-day replacement test
commits: feat(prices): implement RetailPrice model and repository (T-17); feat(prices): build retail price history screen (T-17); test(prices): add retail price repository and date resolution unit tests (T-17)

## T-18 Price resolution rule | Phase 2
branch: feature/T-18-price-rule
depends: T-16, T-17
stories: S7
goal: Resolve effective price for a buyer, supplier, or retail on date D in pure Dart.
read: wholesale_project.md (S7, Prices); docs/ARCHITECTURE.md (Rules)
touch: lib/features/prices/**, test/features/prices/**
done-when: Price lookup returns latest rate with effectiveDate <= D or falls back to product default
tests: Price resolution rules tests for buyer, supplier, and retail prices across edge date cases
commits: feat(prices): implement price resolution pure rule logic (T-18); feat(prices): build price resolution Riverpod provider (T-18); test(prices): add comprehensive unit tests for price resolution rules (T-18)

## T-19 Record buyer demand & items | Phase 3
branch: feature/T-19-record-demand
depends: T-10, T-12
stories: S12
goal: Record buyer demands with products and demanded quantities.
read: docs/DATABASE.md (Collections - demands, demandItems); wholesale_project.md (S12); docs/UI_PLAN.md (/demands)
touch: lib/features/demands/**, test/features/demands/**, firestore.rules, rules_test/**
done-when: Demand and demand items are created in Firestore and displayed on Demands list
tests: DemandRepository CRUD tests, demand item insertion test, and security rules tests
commits: feat(demands): implement Demand and DemandItem models and repository (T-19); feat(demands): build DemandsListScreen and NewDemandScreen (T-19); test(demands): add demand repository, UI, and security rules tests (T-19)

## T-20 Edit demand items | Phase 3
branch: feature/T-20-edit-demand
depends: T-19
stories: S14
goal: Add, modify, or remove demand items before they are processed.
read: wholesale_project.md (S14, Demand lifecycle); docs/UI_PLAN.md (/demands/:id)
touch: lib/features/demands/**, test/features/demands/**
done-when: Demand items can be added, updated in quantity, or deleted when un-linked
tests: Unit test for demand item modification/deletion constraints and widget tests for demand editor
commits: feat(demands): implement demand item add/edit/delete service methods (T-20); feat(demands): build demand item editor controls on DemandDetailScreen (T-20); test(demands): add demand item editing and removal unit/widget tests (T-20)

## T-21 Create purchase lists | Phase 3
branch: feature/T-21-purchase-lists
depends: T-10
stories: S15
goal: Create purchase lists (summaries) for specific suppliers.
read: docs/DATABASE.md (Collections - summaries); wholesale_project.md (S15); docs/UI_PLAN.md (/demands)
touch: lib/features/purchase_lists/**, test/features/purchase_lists/**, firestore.rules, rules_test/**
done-when: Supplier purchase list is created with 'open' status and listed in Buying Lists tab
tests: SummaryRepository creation test, status default test, and security rules tests
commits: feat(purchase_lists): implement Summary model and SummaryRepository (T-21); feat(purchase_lists): build BuyingListsScreen and NewListScreen (T-21); test(purchase_lists): add summary repository, UI, and security rules tests (T-21)

## T-22 Send demand item to purchase list | Phase 3
branch: feature/T-22-send-to-list
depends: T-19, T-21
stories: S16
goal: Send a demand item to a purchase list in a batch that creates/updates summaryItem and links summaryItemId.
read: docs/DATABASE.md (Atomic operations - Send demand item); wholesale_project.md (S16)
touch: lib/features/purchase_lists/**, test/features/purchase_lists/**, firestore.rules, rules_test/**
done-when: Demand item links to summary item and summary item quantity matches or updates
tests: Batch transaction test for sending demand item to list and security rules tests
commits: feat(purchase_lists): implement batch service for sending demand item to purchase list (T-22); feat(purchase_lists): build Send to buying list bottom sheet UI (T-22); test(purchase_lists): add batch execution, provider, and rules tests (T-22)

## T-23 Share demand items on summary item | Phase 3
branch: feature/T-23-share-summary-item
depends: T-22
stories: S17
goal: Link multiple buyers' demand items to one summary item and accumulate quantity.
read: wholesale_project.md (S17, Demand items); docs/DATABASE.md (Collections - summaryItems)
touch: lib/features/purchase_lists/**, test/features/purchase_lists/**
done-when: Adding second demand item for same product updates single summaryItem (summaryId_productId)
tests: Unit test verifying summaryItem quantity accumulation and multiple demand item links
commits: feat(purchase_lists): implement demand item linking logic to existing summaryItem (T-23); feat(purchase_lists): display linked demand items breakdown on summary item UI (T-23); test(purchase_lists): add summary item sharing unit and widget tests (T-23)

## T-24 Direct summary items | Phase 3
branch: feature/T-24-direct-summary-items
depends: T-12, T-21
stories: S18
goal: Add or remove summary items directly on a purchase list without linked demand items.
read: wholesale_project.md (S18); docs/DATABASE.md (Atomic operations - Delete summary item)
touch: lib/features/purchase_lists/**, test/features/purchase_lists/**, firestore.rules, rules_test/**
done-when: Direct summary items can be added, edited, or deleted (unlinking demand items in batch)
tests: Direct summary item creation test and batch delete unlinking test
commits: feat(purchase_lists): implement direct summary item management and batch deletion (T-24); feat(purchase_lists): add direct item add/remove buttons on PurchaseListScreen (T-24); test(purchase_lists): add direct item unit, widget, and rules tests (T-24)

## T-25 Purchase list rate paid & mark purchased | Phase 3
branch: feature/T-25-mark-purchased
depends: T-18, T-24
stories: S19
goal: Record rate paid and notes on summary items, and mark purchase list as 'purchased'.
read: wholesale_project.md (S19, Statuses); docs/UI_PLAN.md (/lists/:id)
touch: lib/features/purchase_lists/**, test/features/purchase_lists/**
done-when: Purchase list rate paid is auto-filled/editable and list status updates to purchased
tests: Unit test for purchase list completion and summary item rate recording
commits: feat(purchase_lists): implement rate paid recording and status transition logic (T-25); feat(purchase_lists): add Mark Purchased action and rate editor to PurchaseListScreen (T-25); test(purchase_lists): add mark purchased unit and widget tests (T-25)

## T-26 Draft bill & editor shell | Phase 4
branch: feature/T-26-draft-bill
depends: T-18
stories: S23
goal: Create draft bills on first item addition and provide bill editor UI shell with autosave.
read: docs/UI_PLAN.md (Bill editor); docs/DATABASE.md (Collections - bills, billItems); wholesale_project.md (S23)
touch: lib/features/bills/**, test/features/bills/**, firestore.rules, rules_test/**
done-when: Draft bill is auto-created with first item and debounced 500ms autosave executes
tests: Draft bill creation test, autosave debounce test, and draft security rules tests
commits: feat(bills): implement Bill and BillItem models and BillRepository (T-26); feat(bills): build BillEditorScreen shell with debounced autosave (T-26); test(bills): add draft bill repository, autosave, and security rules tests (T-26)

## T-27 Override bill item price | Phase 4
branch: feature/T-27-override-price
depends: T-26
stories: S8
goal: Allow manual override of unit price on draft bill items.
read: wholesale_project.md (S8, Draft bill); docs/UI_PLAN.md (Bill editor)
touch: lib/features/bills/**, test/features/bills/**
done-when: Tapping price on draft bill item allows editing unit price via number pad
tests: Price override unit test on draft bill item and price validation test
commits: feat(bills): implement unit price override logic on draft bill items (T-27); feat(bills): add unit price edit dialog to BillEditorScreen (T-27); test(bills): add price override unit and widget tests (T-27)

## T-28 Direct bill items | Phase 4
branch: feature/T-28-direct-bill-items
depends: T-26
stories: S22
goal: Add or remove bill items directly on a draft bill without a demand item.
read: docs/DATABASE.md (Atomic operations - Add bill item); wholesale_project.md (S22)
touch: lib/features/bills/**, test/features/bills/**, firestore.rules, rules_test/**
done-when: Direct bill items can be added/removed on draft bills with auto-filled prices
tests: Direct bill item creation unit test and security rules tests for draft bill items
commits: feat(bills): implement direct bill item add and remove batch methods (T-28); feat(bills): add product picker and direct item controls to BillEditorScreen (T-28); test(bills): add direct bill item repository, UI, and rules tests (T-28)

## T-29 Send demand item to bill | Phase 4
branch: feature/T-29-send-demand-to-bill
depends: T-19, T-26
stories: S20
goal: Send demand item straight to a draft bill item and update demand item billedQuantity in batch.
read: docs/DATABASE.md (Atomic operations - Add bill item); wholesale_project.md (S20, billedQuantity)
touch: lib/features/bills/**, test/features/bills/**, firestore.rules, rules_test/**
done-when: Demand item creates bill item and increments demandItem.billedQuantity in single batch
tests: Batch operation unit test updating billedQuantity and security rules tests
commits: feat(bills): implement batch service for converting demand item to bill item (T-29); feat(bills): add Add to bill button on DemandDetailScreen (T-29); test(bills): add demand-to-bill batch unit test and rules tests (T-29)

## T-30 Edit billed quantity & warning | Phase 4
branch: feature/T-30-billed-quantity
depends: T-29
stories: S21
goal: Edit quantity on demand-linked bill items and warn when billedQuantity exceeds demand.
read: wholesale_project.md (S21, billedQuantity); docs/UI_PLAN.md (Bill editor)
touch: lib/features/bills/**, test/features/bills/**
done-when: Bill item quantity change updates billedQuantity by delta and shows warning if exceeded
tests: Billed quantity delta calculation test and over-billing warning dialog test
commits: feat(bills): implement bill item quantity edit with billedQuantity delta sync (T-30); feat(bills): add over-billing confirmation warning to BillEditorScreen (T-30); test(bills): add quantity edit delta unit tests and warning dialog tests (T-30)

## T-31 Demand item status view | Phase 4
branch: feature/T-31-demand-item-status
depends: T-22, T-29
stories: S13
goal: Calculate and display demand item status (open, in_summary, billed) and overall demand status.
read: wholesale_project.md (S13, Statuses); docs/UI_PLAN.md (/demands/:id)
touch: lib/features/demands/**, test/features/demands/**
done-when: Demand item displays correct derived status and demand shows open/done chip
tests: Pure logic unit test for derived demand item status and overall demand status calculation
commits: feat(demands): implement derived demand item status rules logic (T-31); feat(demands): display item status chips and links on DemandDetailScreen (T-31); test(demands): add derived status unit and widget tests (T-31)

## T-32 Issue bill & invoice counter | Phase 5
branch: feature/T-32-issue-bill
depends: T-06, T-26
stories: S24
goal: Issue a draft bill, assign invoice number (INV-A-0001), update device counter, and freeze items.
read: docs/DATABASE.md (Atomic operations - Issue bill); wholesale_project.md (S24, Invoice numbers)
touch: lib/features/bills/**, test/features/bills/**, firestore.rules, rules_test/**
done-when: Issuing bill assigns invoice number, updates device lastNumber, and freezes edit controls
tests: Invoice counter formatting unit test, offline issue batch test, and rules test for issued bill freeze
commits: feat(bills): implement bill issue batch service with device counter update (T-32); feat(bills): add Finish bill confirmation flow and read-only view (T-32); test(bills): add invoice counter, bill issue, and security rules tests (T-32)

## T-33 Mark bill cleared | Phase 5
branch: feature/T-33-cleared-bill
depends: T-32
stories: S25
goal: Mark an issued bill as 'cleared' (paid on the spot).
read: wholesale_project.md (S25, Bill lifecycle); docs/UI_PLAN.md (Bill editor)
touch: lib/features/bills/**, test/features/bills/**, firestore.rules, rules_test/**
done-when: Marking bill cleared updates status to 'cleared' and disables further transitions
tests: Status transition unit test to cleared and security rules test enforcing final state
commits: feat(bills): implement mark bill cleared service method (T-33); feat(bills): add Paid confirmation button to issued bill view (T-33); test(bills): add mark cleared unit, widget, and security rules tests (T-33)

## T-34 Bill notes | Phase 5
branch: feature/T-34-bill-notes
depends: T-26
stories: S27
goal: Add or edit notes on draft and issued bills.
read: wholesale_project.md (S27, Bill lifecycle); firestore.rules (notes update)
touch: lib/features/bills/**, test/features/bills/**, firestore.rules, rules_test/**
done-when: Bill notes can be updated on both draft and issued bills
tests: Bill notes update unit test and security rules test for issued bill notes modification
commits: feat(bills): implement bill notes update repository method (T-34); feat(bills): add notes text field to draft and issued bill views (T-34); test(bills): add bill notes update unit, widget, and rules tests (T-34)

## T-35 Buyer ledger & calculated balance | Phase 5
branch: feature/T-35-buyer-ledger
depends: T-10
stories: S28
goal: Display buyer's ledger entries and calculate balance in pure Dart.
read: docs/DATABASE.md (Collections - ledgerEntries); wholesale_project.md (S28, Ledger); docs/UI_PLAN.md (/buyers/:id/account)
touch: lib/features/ledger/**, test/features/ledger/**, firestore.rules, rules_test/**
done-when: Buyer ledger displays entries newest first and calculates correct sum balance
tests: Balance sum calculation unit test, empty ledger test, and security rules read tests
commits: feat(ledger): implement LedgerEntry model and LedgerRepository (T-35); feat(ledger): build BuyerAccountScreen with calculated balance (T-35); test(ledger): add ledger repository, balance calculation, and security rules tests (T-35)

## T-36 Move issued bill to ledger | Phase 5
branch: feature/T-36-move-to-ledger
depends: T-32, T-35
stories: S26
goal: Move issued bill to buyer's ledger in atomic batch (bill status 'ledger', create bill_billId entry).
read: docs/DATABASE.md (Atomic operations - Move to ledger); wholesale_project.md (S26)
touch: lib/features/ledger/**, test/features/ledger/**, firestore.rules, rules_test/**
done-when: Move to ledger creates ledger entry bill_billId (+grandTotal) and sets bill status to ledger
tests: Move to ledger batch test, duplicate prevention test, and security rules test for bill entry
commits: feat(ledger): implement move bill to ledger batch service (T-36); feat(ledger): add Put on account button to issued bill view (T-36); test(ledger): add move to ledger unit, widget, and security rules tests (T-36)

## T-37 Cash, bank transfer, opening balance entries | Phase 5
branch: feature/T-37-payment-entries
depends: T-11, T-35
stories: S29
goal: Record cash (-), bank transfer (-), and opening balance (+/-) ledger entries.
read: wholesale_project.md (S29, Ledger sign); docs/UI_PLAN.md (Add entry)
touch: lib/features/ledger/**, test/features/ledger/**, firestore.rules, rules_test/**
done-when: Payment entries apply correct sign convention and validate bankAccountId on transfer
tests: Entry sign validation tests, required bankAccountId test, and security rules sign tests
commits: feat(ledger): implement cash, bank transfer, and opening balance entry service methods (T-37); feat(ledger): build Add Entry bottom sheet form (T-37); test(ledger): add payment entry validation, UI, and rules tests (T-37)

## T-38 Ledger return entries | Phase 5
branch: feature/T-38-return-entries
depends: T-37
stories: S30
goal: Record product return as a negative ledger entry with returned items detailed in notes.
read: wholesale_project.md (S30, Ledger); docs/UI_PLAN.md (Add entry)
touch: lib/features/ledger/**, test/features/ledger/**
done-when: Return entry is saved as negative amount with item breakdown in notes field
tests: Return entry sign test and notes requirement validation test
commits: feat(ledger): implement return entry creation service method (T-38); feat(ledger): add Return entry option and item description fields to Add Entry sheet (T-38); test(ledger): add return entry unit and widget tests (T-38)

## T-39 Ledger correction entries | Phase 5
branch: feature/T-39-correction-entries
depends: T-37
stories: S31
goal: Add positive or negative correction ledger entries with mandatory explanation note.
read: wholesale_project.md (S31, Ledger); docs/UI_PLAN.md (Add entry)
touch: lib/features/ledger/**, test/features/ledger/**, firestore.rules, rules_test/**
done-when: Correction entry is created with non-zero amount and required explanation note
tests: Correction entry unit test, non-zero amount validation, and security rules tests
commits: feat(ledger): implement correction entry creation service method (T-39); feat(ledger): add Correction option to Add Entry sheet (T-39); test(ledger): add correction entry unit, widget, and security rules tests (T-39)

## T-40 Text-size setting pass at scale 1.8 | Phase 6
branch: feature/T-40-text-scale-pass
depends: T-39
stories: none
goal: Implement text-size setting screen and verify all app screens render cleanly at font scale 1.8.
read: docs/DESIGN_SYSTEM.md (Text styles, Responsive); docs/UI_PLAN.md (/more/text-size)
touch: lib/features/settings/**, test/features/settings/**, test/flows/**
done-when: Text-size setting adjusts font scale and zero render overflow errors occur at scale 1.8
tests: Widget test pass for all screens at 360x640 resolution with font scale 1.8
commits: feat(settings): build TextSizeSettingScreen with live scale preview (T-40); test(ui): execute font scale 1.8 overflow audit across all feature screens (T-40)

## T-41 Smoke tests, README & manual verification | Phase 6
branch: chore/T-41-verification
depends: T-40
stories: none
goal: Implement end-to-end flow tests, complete manual checklist, and finalize README documentation.
read: docs/TESTING.md (Flow tests, Manual check); README.md
touch: test/flows/**, README.md, integration_test/**
done-when: All flow tests pass in CI, integration smoke test passes, and README is complete
tests: Flow test 1 (demand -> list -> bill -> ledger), Flow test 2 (stock to bill), Flow test 3 (barcode scan bill), Flow test 4 (unsynced logout)
commits: test(flows): implement complete end-to-end integration flow tests (T-41); docs(readme): update project documentation and setup guide (T-41)

## T-42 Release build & APK packaging | Phase 6
branch: chore/T-42-release-build
depends: T-41
stories: none
goal: Perform release build, set version, document release checklist, and tag milestone v1.0.0.
read: docs/GIT_WORKFLOW.md (Releases)
touch: pubspec.yaml, CHANGELOG.md
done-when: `flutter build apk --release` succeeds cleanly and CHANGELOG is updated for v1.0.0
tests: Release APK build verification and firestore.rules deployment check
commits: chore(release): set version 1.0.0+1 and finalize CHANGELOG (T-42); docs(release): tag milestone release v1.0.0 (T-42)
