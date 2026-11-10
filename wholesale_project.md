# Wholesale App: Project Doc

Diagram: `wholesale_erd_v9.mermaid`. Link reads: `wholesale_relationships.md`.

## 1. Brief

**Purpose.** Track buyer demands, supplier purchases, bills and buyer balances for a wholesale business in one app.

**User.** One role: the owner, one email and password account.

**Platform.** Flutter Android app on Cloud Firestore and Firebase Auth. The whole business is cached on the device and works offline.

**In scope**
- Products with optional barcode (SKU), tags, default prices, archiving
- Buyer-specific and supplier-specific rates, retail price history
- Demands, purchase lists, bills with invoice numbers
- One ledger per buyer
- Bank accounts (own, buyers', suppliers')
- Business profile
- Login, device setup, sync status, logout
- Offline use: bills made without signal upload when the phone is online

**Out of scope**
- Inventory tracking. Stock is small and checked by hand.
- Supplier ledger. What is owed to suppliers is not tracked.
- Editing from two devices at once. One device at a time; last write wins, no conflict code.
- Sign-up screen, backup and restore (sync replaces them).

**Core workflow**
1. A buyer raises a demand (products and quantities).
2. The owner checks shelf stock by hand.
3. Stock covers an item: send the demand item straight to a bill item.
4. Stock does not cover it: send the demand item to a summary item (a line on a supplier's purchase list). Quantity starts at the demanded amount and is editable. If another buyer wants the same product before purchase, link their demand item to the same summary item and raise the quantity.
5. After purchase, send each demand item to a bill item on its buyer's bill. Quantity is editable.
6. Issue the bill, then either mark it cleared (paid on the spot) or move it to the buyer's ledger.

Demand items are never removed. Summary items and bill items can also be added directly, without a demand item.

## 2. User stories

Each story starts with "As the owner, I can".

**Products**
- S1. Add a product with name, optional barcode, default supplier/buyer/retail prices and notes.
- S2. Find a product by scanning its barcode.
- S3. Tag products and filter by tag.
- S4. Archive a product.

**Prices**
- S5. Set buyer-specific and supplier-specific rates with an effective date.
- S6. Set a retail price with an effective date.
- S7. Get the correct price filled in automatically when I add an item.
- S8. Override the price on a draft bill item.

**People and accounts**
- S9. Manage buyers and suppliers (contact, address, notes) and archive them.
- S10. Save bank accounts for buyers, suppliers and my own business.
- S11. Edit my business profile (name, address, two phone numbers).

**Demands**
- S12. Record a buyer's demand with products and quantities.
- S13. See each demand item's status, summary item and bill items.
- S14. Add or remove demand items before they are moved.

**Purchase lists**
- S15. Create a purchase list per supplier.
- S16. Send a demand item to a purchase list and edit the quantity.
- S17. Link several buyers' demand items to one summary item and raise its quantity.
- S18. Add or remove summary items without a demand item.
- S19. Record the rate paid and notes on a summary item, and mark a purchase list purchased.

**Billing**
- S20. Send a demand item straight to a bill.
- S21. Send demand items to a buyer's bill after purchase and edit the quantity.
- S22. Add or remove bill items without a demand item.
- S23. Create a draft bill and edit its items, quantities and prices.
- S24. Issue a bill and get its invoice number (INV-A-0001).
- S25. Mark an issued bill cleared.
- S26. Move an issued bill to the buyer's ledger.
- S27. Add notes to a bill.

**Ledger**
- S28. See a buyer's ledger with all entries and the balance.
- S29. Record cash, bank transfers and opening balances.
- S30. Record a return as a negative entry, with the products in notes.
- S31. Add a correction entry.

**Login, device and sync**
- S32. Log in with email and password and stay logged in.
- S33. Set up a new device at first login: it gets its invoice letter and downloads all data.
- S34. See at all times whether my data is Synced or Not synced yet.
- S35. Log out, with a warning if data is not synced yet.

## 3. Data rules

### Ids and dates
- Ids are strings. Generated unless a rule below says otherwise. Dates are `yyyy-MM-dd` strings, datetimes are timestamps.

### Demand, summary and bill items
- A demand item links to at most one summary item (`DEMAND_ITEM.summaryItemId`). A summary item can be shared by many demand items. One demand item cannot be split across suppliers.
- One summary item per product per summary (id `summaryId_productId`). Raise its quantity instead of adding a second line.
- Summary quantity is entered by hand and need not equal the linked demand quantities.
- Deleting a summary item: one batch that deletes it and clears `summaryItemId` on its demand items.
- A bill item links to at most one demand item (`BILL_ITEM.demandItemId`), empty when added directly. A demand item can have many bill items (partial delivery).
- Summary items are never linked to bill items. The purchase cost of a sale is reachable only through bill item, demand item, summary item, and only when that chain exists.
- Warn when `billedQuantity` of a demand item exceeds its quantity.
- `DEMAND_ITEM.billedQuantity` is the only denormalised field. Every bill item add, edit or remove changes it by the difference in the same batch. Only the bill item repository writes it. Buyer names and product names are never copied; read them from the cache.
- Transferred and remaining quantities are calculated, never stored.

### Statuses
- Derived, never stored, except `SUMMARY.status`.
- Demand item: `billed` if billedQuantity >= quantity; else `in_summary` if summaryItemId is set; else `open`.
- Demand: `open` if it has no items or any item is not `billed`; else `done`.
- Summary: stored, `open` or `purchased`, set by the owner. Summary items have no status.

### Bill lifecycle
- Statuses: `draft`, `issued`, `cleared`, `ledger`. Moves are one way: draft, issued, then cleared or ledger. `cleared` and `ledger` are final.
- `draft`: freely editable, autosaved, no invoice number, no ledger entry. `billDate` is set when the draft is created. Item prices are looked up when the item is added and stay editable.
- `issued`: one batch sets status, `grandTotal`, `invoiceNumber`, `issuedAt` and `DEVICE.lastNumber`. After that items, prices, total, buyer, billDate and invoice number are frozen. Only notes can change.
- `cleared`: paid on the spot, no ledger entry. Sales reports read from bills, not the ledger.
- `ledger`: allowed only once. One batch (no offline transactions): the app checks the cached status is `issued`, sets `ledger`, creates the ledger entry (type `bill`, amount +grandTotal, id `bill_` + billId). A repeat is rejected by the security rules.
- Returns and corrections are manual ledger entries, not bill statuses.

### Invoice numbers
- Format `INV-<letter>-<0000>`, e.g. `INV-A-0001`. Digits grow past 9999, no wrap.
- Device letter: at first login (internet required) a transaction on `DEVICE_REGISTRY/main` reads `nextIndex`, creates `DEVICE/<letter>` and increments `nextIndex`. Letters follow spreadsheet columns: A..Z, AA, AB... A reinstall is a new device; letters are never reused.
- Counter: stored on the device and in `DEVICE.lastNumber`. At issue, number = counter + 1, written in the issue batch. Works offline. If the two differ, use the larger.
- Uniqueness comes from the letter plus the counter, not from the bill id (a draft needs an id before it has a number).

### Ledger
- No LEDGER table. Entries carry `buyerId`. A buyer's ledger is their entries.
- The balance is never stored. balance = sum of the buyer's cached entry amounts, calculated in Dart.
- Sign: positive = buyer owes more, negative = buyer owes less. Never 0.
- Types: `bill`, `cash`, `bank_transfer`, `return`, `opening_balance`, `correction`.
- Expected sign: `bill` positive. `cash`, `bank_transfer`, `return` negative. `opening_balance`, `correction` either.
- Return: amount calculated by hand, products listed in notes, no bill link.
- `billId` is set only on `bill` entries.
- `bankAccountId` is required for `bank_transfer` and must be an own account (`profileId` set); the sender goes in notes. Empty for every other type.
- Entries are append-only. Never edit or delete; add a correction.

### Prices
- Price of a product on date D (D = billDate for bills, summaryDate for purchase lists):
  - Buyer: latest `BUYER_RATE` with `effectiveDate <= D`, else `PRODUCT.defaultBuyerRate`.
  - Supplier: latest `SUPPLIER_RATE` with `effectiveDate <= D`, else `PRODUCT.defaultSupplierRate`.
  - Retail: latest `RETAIL_PRICE` with `effectiveDate <= D`, else `PRODUCT.defaultRetailPrice`.
- Latest = highest `effectiveDate`.

### Uniqueness (by document id)
- `SUPPLIER_RATE`: `supplierId_productId_effectiveDate`. `BUYER_RATE`: `buyerId_productId_effectiveDate`. `RETAIL_PRICE`: `productId_effectiveDate`. Saving the same day again replaces the rate.
- `PRODUCT_TAG`: `productId_tagId`. `TAG`: lowercase name. `SUMMARY_ITEM`: `summaryId_productId`.
- `PRODUCT.sku`: lookup document `PRODUCT_SKU/<sku>`, created and deleted in the same batch as the product change. Archived products keep their barcode.
- Ledger bill entry: id `bill_` + billId.

### Archiving
- `archivedAt` empty = active. Applies to products, buyers, suppliers and bank accounts. Archived rows stay in history and are hidden from pickers.
- Never hard-delete anything referenced by bills or the ledger.
- Archiving a buyer: warn if the ledger balance is not 0, or there are draft or issued bills or open demands. Require confirmation.
- Archiving a supplier: warn if there are open purchase lists. Require confirmation.

### Bank accounts and profile
- Exactly one of `profileId`, `buyerId`, `supplierId` is set on a bank account. `profileId` means your own account. The diagram can't enforce this; the app and the security rules must.
- `PROFILE` has one document with the fixed ID `main`: business name, address, contact numbers 1 and 2. Linked only to `BANK_ACCOUNT`.

### Login, offline and sync
- One owner account. No sign-up. Login persists. First login and device setup need internet.
- Firestore persistence on, cache size unlimited. After each login a full sync reads every collection so the whole business is available offline.
- Sync state: Synced or Not synced yet, from pending-writes metadata. Warn before logout when not synced. Wait for Synced before switching device.
- Multi-document changes use batched writes: issue bill, move to ledger, send demand item to a purchase list, bill item add/edit/remove, delete summary item, change SKU. The device letter claim is the only transaction.
- No offline sum queries: sums are calculated in Dart from cached documents.
- Last write wins.

### Security rules (full text in `docs/DATABASE.md`)
- Only the owner account can read or write.
- Ledger entries: create only.
- Bills not in `draft`: only `notes` can change, plus the moves draft to issued and issued to cleared or ledger. Their bill items cannot change.
- `PRODUCT_SKU`: create and delete only. `DEVICE.lastNumber` can only increase.
- Field types and allowed values are validated (statuses, entry types, entry signs, amount not 0, exactly one bank account owner).
