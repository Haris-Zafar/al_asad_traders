# UI Plan

User: a 48-year-old non-technical owner on a small phone, English. Stories: `../wholesale_project.md`. Order of build: `../STORY_DEPENDENCIES.md`. Colors, sizes, widgets, text scale: `DESIGN_SYSTEM.md`. All text lives in `strings.dart`.

## Plain words
| In the docs | On screen |
|---|---|
| Summary, summary item | Buying list, item |
| Demand, demand item | Demand, item |
| Draft / issued / cleared / ledger | Draft / Finished / Paid / On account |
| Issue a bill | Finish bill |
| Invoice number | Bill number |
| Move to ledger | Put on account |
| Ledger, ledger entry, balance | Account, entry, "Owes you" / "You owe" |
| Opening balance | Starting balance |
| Archive | Hide |
| SKU | Barcode |
| Buyer rate / supplier rate / retail price | Price for this buyer / Buying price / Shop price |
| Default price, effective date | Usual price, From date |
| Synced / pending writes | Synced / Not synced yet |

Amounts: whole numbers, thousands separators, one currency label constant. Never show ids, statuses in code form or technical errors.

## Navigation
```
Login -> First setup (new device) -> Shell
Shell (bottom bar, 4 tabs)
  Bills (home) -> New bill -> Bill editor | Bill view
  Demands [Demands | Buying lists] -> Demand | Buying list
  Buyers -> Buyer -> Account
  More -> Products, Suppliers, My business, Text size, Sync, Log out
```
Tabs keep their own back stack. Android back goes up one level; on a tab root it goes to Bills, then exits.

## Screens
| Route | Purpose | Stories |
|---|---|---|
| `/login` | Email and password, stay logged in | S32 |
| `/setup` | First login: get bill letter, download all data, progress | S33 |
| `/bills` | Home. Bills newest first, filter Draft/Finished/Paid/On account, search buyer, big New bill button, sync chip | S23, S34 |
| `/bills/new` | Pick buyer, then open the editor | S23 |
| `/bills/:id` | Bill editor (Draft) or read-only bill view. Finish, Paid, Put on account, notes | S8, S20-S27 |
| `/bills/:id/add` | Add item: scan, search by name or tag, or from this buyer's demands | S2, S3, S7, S20-S22 |
| `/demands` | Toggle Demands / Buying lists. New demand or New buying list | S12, S15 |
| `/demands/new` | Pick buyer, add products and quantities | S12, S14 |
| `/demands/:id` | Items with status, buying list and bills. Per item: Send to buying list, Add to bill | S13, S14, S16, S20, S21 |
| `/lists/:id` | Buying list for one supplier: items, quantities, price paid, notes, shared demands, Mark purchased | S16-S19 |
| `/buyers` | Buyers, search, add | S9 |
| `/buyers/:id` | Contact, balance, bank accounts, Hide | S9, S10 |
| `/buyers/:id/account` | Entries newest first, balance on top, Add entry (cash, bank transfer, starting balance, return, correction) | S28-S31 |
| `/products` | Search, scan, filter by tag, add | S2, S3 |
| `/products/:id` | Name, barcode, usual prices, notes, tags, Hide | S1, S3, S4 |
| `/products/:id/prices` | Shop prices, prices per buyer, buying prices, each with From date | S5, S6 |
| `/suppliers`, `/suppliers/:id` | Same as buyers, without account | S9, S10 |
| `/more/business` | Business name, address, two phones, own bank accounts | S10, S11 |
| `/more/text-size` | Normal / Large / Extra large, live preview | - |
| `/more/sync` | Synced or Not synced yet, last full sync | S34 |
| Log out (dialog) | Warns when Not synced yet | S35 |

Small tasks use bottom sheets, not routes: add entry, send to buying list (pick list or start a new one for a supplier), add to bill (pick this buyer's draft or start one).

## Bill editor (360x640)
```
+--------------------------------+
| <  Bill            Saved       |  back, status chip, save state
| Ali Traders         12 Nov     |  buyer, date
|--------------------------------|
| Rice bag 5kg      (from demand)|
|  3  x  1,200          3,600    |  tap quantity or price to edit
|                    [ Remove ]  |
| Sugar 1kg                      |
|  10 x  150            1,500    |
|                    [ Remove ]  |
| Notes: ______________________  |
|--------------------------------|
| Total                    5,100 |  sticky footer
| [ + Add item ]   [ Finish bill ]|
+--------------------------------+
```
- A draft is created when the first item is added, so there are no empty drafts. Date is today.
- Autosave: every change saves after 500 ms and shows "Saving..." then "Saved". Leaving never asks to save. This is local saving; the sync chip is separate.
- Add item: scan or search. The price is filled by the price rule (S7); quantity starts at 1. Tap quantity or price to type it on a number pad (S8).
- An item from a demand shows "from demand". If total billed for that demand item passes the demanded quantity, ask: "You ordered 5 and are billing 7. Keep 7?"
- Remove asks "Remove this item?".
- Finish bill needs at least one item and a total above 0 (a ledger amount is never 0). The dialog shows the total and says items can no longer change.
- After Finish: show the bill number and read-only items; only Notes can change. Buttons: Paid, Put on account. Each asks to confirm and says it cannot be undone.
- Bill view of Draft is the editor. Finished, Paid and On account show no edit controls.

## Interaction rules
- One main action per screen, a wide button at the bottom. Every icon has a text label.
- No swipe, long-press or hidden gestures. Everything is a visible button.
- Confirm only what cannot be undone: Finish, Paid, Put on account, Hide, Log out, removing an item. Buttons say what happens ("Yes, finish", "Not yet").
- Hide shows the warnings from the project doc (balance, open bills, open demands, open lists) before confirming.
- Pickers (buyer, product, supplier) are searchable lists of big rows. Hidden items do not appear.
- Scan: full-screen camera, Cancel button. Barcode not found: "No product with this barcode" and an Add product button.
- Number fields use a number pad and accept whole numbers only.
- Forms (people, products, entries, prices) use a Save button and show errors under the field. The bill and demand editors autosave.
- The sync chip (icon and words) shows on Bills and More. Not synced yet means changes wait for internet. Do not switch device then.
- Logout when Not synced yet: "Some changes are not synced yet. If you log out now, they are lost." Buttons: Wait / Log out anyway. Otherwise: "Log out?".
- Portrait only. Screens scroll vertically; nothing has a fixed height. Must work at text scale 1.8.

## Loading, empty and error states
- Loading: data is local, so lists open at once. Only login, first setup and a full sync show a progress screen with words ("Downloading your data, 5 of 19").
- Empty: icon, one sentence and the main button, on every list. Example Bills: "No bills yet" and New bill. Buyers: "No buyers yet" and Add buyer.
- Failed action (Finish, Paid, save): dialog with a plain sentence and OK; add Try again only if trying again can work.
- Failed list: panel "Could not load this" with Try again.
- Needs internet (login, setup): "Internet is needed for this" and Try again. Working offline is never an error.
- Permission denied or logged out: "Please log in again" and go to `/login`.
- Item gone: "This is no longer available" and go back.
- Mapping from `AppException` to words: `ARCHITECTURE.md`.
