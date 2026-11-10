# Database: Cloud Firestore

Fields and links: `../wholesale_erd_v9.mermaid`, `../wholesale_relationships.md`. Business rules, id patterns, sign rules: `../wholesale_project.md`. Layering: `ARCHITECTURE.md`. Rule and emulator tests: `TESTING.md`.

## Collections
Flat, top level, one per ERD entity, names in camelCase. Ids are built only in `core/data/paths.dart`.

| Collection | Doc id | Notes |
|---|---|---|
| products | auto | Barcode reserved in `productSkus` |
| productSkus | the barcode | create and delete only |
| tags | lowercase name | |
| productTags | `productId_tagId` | |
| suppliers, buyers | auto | |
| profile | `main` | single document |
| bankAccounts | auto | exactly one owner id set |
| supplierRates, buyerRates, retailPrices | composite, see project doc | saving again replaces |
| demands, demandItems | auto | `billedQuantity` on the item |
| summaries | auto | `status` open or purchased |
| summaryItems | `summaryId_productId` | |
| bills, billItems | auto | `invoiceNumber` null until issued |
| ledgerEntries | `bill_` + billId for bill entries, else auto | |
| devices | the letter | |
| deviceRegistry | `main` | single document |

## Field conventions
- Document keys equal the ERD fields exactly. Empty optional fields are stored as `null`, not omitted, so rules can check the key set.
- Dates are `yyyy-MM-dd` strings. `createdAt`, `issuedAt`, `archivedAt` are `Timestamp` from `clock.dart` (not server time: it stays valid offline).
- Money and quantities are `int`. Money and rates are >= 0; quantities >= 1; `billedQuantity` >= 0; ledger `amount` is not 0.
- `billedQuantity` has no rule that can verify it. Debug builds assert it equals the sum of the item's bill items.

## Indexes
- Only automatic single-field indexes. Every query is equality-only (one or two fields); sorting, filtering and sums happen in Dart. No `firestore.indexes.json`. Adding one needs a `DECISIONS.md` entry.

## Key queries
All read from the local cache.

| Need | Query |
|---|---|
| Scan barcode (S2) | get `productSkus/{code}`, then `products/{productId}` |
| Product, buyer, supplier, tag lists | whole collection, kept alive |
| Price on a date (S7) | rates where `buyerId` (or `supplierId`) == x and `productId` == y; pick latest `effectiveDate` <= date in Dart |
| Buyer balance (S28) | `ledgerEntries` where `buyerId` == x; sum in Dart |
| Items of a parent | `demandItems` by `demandId` or `summaryItemId`; `summaryItems` by `summaryId`; `billItems` by `billId` or `demandItemId` |
| Bills of a buyer | `bills` where `buyerId` == x |

## Atomic operations
Batched writes, built in repositories. Each batch is a few documents (limit 500). No offline transactions.

| Operation | Batch contents |
|---|---|
| Add, change or remove barcode | product update + `productSkus` create/delete |
| Add bill item (S20-S22) | create `billItems` + if `demandItemId`: `billedQuantity` +quantity |
| Edit or remove bill item | update/delete + `billedQuantity` by the difference or -quantity |
| Send demand item to list (S16) | create `summaryItems` with the demand quantity, or increase the existing one; set `summaryItemId` |
| Delete summary item | delete it + `summaryItemId` = null on each linked demand item |
| Issue bill (S24) | bill status, `grandTotal`, `invoiceNumber`, `issuedAt` + `devices/{letter}.lastNumber` |
| Move to ledger (S26) | bill status `ledger` + create `ledgerEntries/bill_{billId}` |
| Claim device letter (S33) | the only transaction, online: read `deviceRegistry/main`, create `devices/{letter}`, `nextIndex` + 1 |

- Issue: write the new counter to SharedPreferences before the batch. A crash leaves a gap in numbers, never a duplicate.
- Single-document writes (clear a bill, manual ledger entry, archive, notes, rates) need no batch.

## Offline settings
Set once in `main`, before any other Firestore call:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## Sync
- Full sync: after each fresh login (not on every app open), read every collection once from the server, listed in one `allCollections` constant. First login blocks on a progress screen and needs internet. Later logins sync in the background. Cost is one read per document; the Spark limit is 50,000 reads a day.
- State: any repository write sets Not synced yet, then `waitForPendingWrites()` sets Synced when no other write is in flight. At start-up the state is Not synced yet until `waitForPendingWrites()` returns. Rows with `metadata.hasPendingWrites` show a small "not uploaded" mark on bill lists.
- A write the server rejects is rolled back. The error handler shows one message and the state returns to Synced.
- Logout: sign out, `terminate()`, `clearPersistence()`. The UI warns first when Not synced yet (`UI_PLAN.md`). Switching device is the same: wait for Synced, then log in on the other device.
- Last write wins. No in-app backup or restore. Point-in-time recovery needs a paid plan: revisit in `DECISIONS.md`.
- Migrations: no framework. A new field is optional with a default in the mapper. A rename or removal is a one-off script run by a task.

## Security rules
File `firestore.rules`. Owner = one UID, put in after the account is created. Also turn off sign-up in Authentication settings if offered.
```
// inside: service cloud.firestore { match /databases/{db}/documents { ... } }
function owner() { return request.auth != null && request.auth.uid == 'OWNER_UID'; }
function d() { return request.resource.data; }
function only(k) { return d().diff(resource.data).affectedKeys().hasOnly(k); }
function bill(id) { return get(/databases/$(db)/documents/bills/$(id)).data; }

match /bills/{id} {
  allow read: if owner();
  allow create: if owner() && validBill(d()) && d().status == 'draft';
  allow update: if owner() && (
    (resource.data.status == 'draft' && validBill(d()) && d().status in ['draft','issued'])
    || (resource.data.status == 'issued' && d().status in ['cleared','ledger'] && only(['status','notes'])
        && (d().status != 'ledger' || existsAfter(/databases/$(db)/documents/ledgerEntries/$('bill_' + id))))
    || (resource.data.status != 'draft' && only(['notes'])));
}
match /billItems/{id} {
  allow read: if owner();
  allow create, update: if owner() && validBillItem(d()) && bill(d().billId).status == 'draft';
  allow delete: if owner() && bill(resource.data.billId).status == 'draft';
}
match /ledgerEntries/{id} {
  allow read: if owner();
  allow create: if owner() && validEntry(d()) && (d().entryType != 'bill'
    || (id == 'bill_' + d().billId && d().buyerId == bill(d().billId).buyerId
        && d().amount == bill(d().billId).grandTotal
        && getAfter(/databases/$(db)/documents/bills/$(d().billId)).data.status == 'ledger'));
  allow update, delete: if false;
}
```
- `productSkus`: create and delete only, `sku` equals the id. `devices`: create with `lastNumber` 0; update only raises `lastNumber`. `deviceRegistry/main`: create with `nextIndex` 1; update adds exactly 1.
- Every other collection has its own `match`: owner read, create and update through `validX`, no delete unless listed: `productTags`, `productSkus`, `summaryItems`, `billItems` (draft only), `demandItems` with no `summaryItemId` and `billedQuantity` 0.
- `validX` checks: exact key set, field types, `int` ranges, allowed `status` and `entryType`, entry sign by type, `amount` != 0, `bankAccountId` set only on `bank_transfer` and pointing to an account with `profileId`, exactly one owner id on a bank account, `invoiceNumber` and `grandTotal` null exactly while `draft`. Ids, `buyerId`, `productId` and `billId` cannot change on update.
- Deploy with `firebase deploy --only firestore:rules`. Every rule above has a test in `rules_test/`.
