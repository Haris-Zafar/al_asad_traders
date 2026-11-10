# Relationships

Source: `wholesale_erd_v9.mermaid`. "Optional" = the FK may be empty.

| Link | FK stored on | Forward reading | Backward reading |
|---|---|---|---|
| PRODUCT – PRODUCT_TAG | PRODUCT_TAG.productId | A product has many tag links | A tag link belongs to one product |
| TAG – PRODUCT_TAG | PRODUCT_TAG.tagId | A tag has many product links | A product link belongs to one tag |
| PRODUCT – PRODUCT_SKU | PRODUCT_SKU.productId | A product has at most one barcode lookup | A lookup belongs to one product |
| PRODUCT – SUPPLIER_RATE | SUPPLIER_RATE.productId | A product has many supplier rates | A rate is for one product |
| SUPPLIER – SUPPLIER_RATE | SUPPLIER_RATE.supplierId | A supplier quotes many rates | A rate is from one supplier |
| PRODUCT – BUYER_RATE | BUYER_RATE.productId | A product has many buyer rates | A rate is for one product |
| BUYER – BUYER_RATE | BUYER_RATE.buyerId | A buyer has many rates | A rate is for one buyer |
| PRODUCT – RETAIL_PRICE | RETAIL_PRICE.productId | A product has many retail prices | A price is for one product |
| BUYER – DEMAND | DEMAND.buyerId | A buyer raises many demands | A demand belongs to one buyer |
| DEMAND – DEMAND_ITEM | DEMAND_ITEM.demandId | A demand has many items | An item belongs to one demand |
| PRODUCT – DEMAND_ITEM | DEMAND_ITEM.productId | A product is in many demand items | A demand item is for one product |
| SUPPLIER – SUMMARY | SUMMARY.supplierId | A supplier has many purchase lists | A list is for one supplier |
| SUMMARY – SUMMARY_ITEM | SUMMARY_ITEM.summaryId | A list has many items | An item is on one list |
| PRODUCT – SUMMARY_ITEM | SUMMARY_ITEM.productId | A product is on many list items | A list item is for one product |
| SUMMARY_ITEM – DEMAND_ITEM | DEMAND_ITEM.summaryItemId (optional) | A summary item is shared by many demand items | A demand item links to at most one summary item |
| BUYER – BILL | BILL.buyerId | A buyer has many bills | A bill belongs to one buyer |
| BILL – BILL_ITEM | BILL_ITEM.billId | A bill has many items | An item is on one bill |
| PRODUCT – BILL_ITEM | BILL_ITEM.productId | A product is on many bill items | A bill item is for one product |
| DEMAND_ITEM – BILL_ITEM | BILL_ITEM.demandItemId (optional) | A demand item can be billed many times (partial delivery) | A bill item comes from at most one demand item |
| BUYER – LEDGER_ENTRY | LEDGER_ENTRY.buyerId | A buyer has many ledger entries | An entry belongs to one buyer |
| BILL – LEDGER_ENTRY | LEDGER_ENTRY.billId (optional, unique) | A bill becomes at most one entry | An entry has at most one bill (only `bill` entries) |
| PROFILE – BANK_ACCOUNT | BANK_ACCOUNT.profileId (optional) | The business has many own accounts | An account is the business's or has another owner |
| BUYER – BANK_ACCOUNT | BANK_ACCOUNT.buyerId (optional) | A buyer has many accounts | An account is a buyer's or has another owner |
| SUPPLIER – BANK_ACCOUNT | BANK_ACCOUNT.supplierId (optional) | A supplier has many accounts | An account is a supplier's or has another owner |
| BANK_ACCOUNT – LEDGER_ENTRY | LEDGER_ENTRY.bankAccountId (optional) | An own account receives many transfers | A transfer entry points to one own account |

## Notes
- Exactly one of BANK_ACCOUNT.profileId, buyerId, supplierId is set. Not enforceable in the diagram: the app and the security rules enforce it.
- No link: DEVICE, DEVICE_REGISTRY (invoice letters; the letter is inside BILL.invoiceNumber) and TAG (reached through PRODUCT_TAG).
- Summary items are never linked to bill items. Cost of a sale: bill item, demand item, summary item, only when the chain exists.
- No LEDGER entity: a buyer's ledger is the set of LEDGER_ENTRY rows with that buyerId.
- Composite ids give uniqueness: rates, PRODUCT_TAG, SUMMARY_ITEM, PRODUCT_SKU, bill ledger entries. See `wholesale_project.md`.
