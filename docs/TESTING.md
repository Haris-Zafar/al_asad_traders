# Testing

Rules under test: `../wholesale_project.md`. Layers: `ARCHITECTURE.md`. Rules text: `DATABASE.md`. Packages: `TECH_STACK.md`. CI workflow file: `GIT_WORKFLOW.md`.

## Rules
- Tests are written in the same task and branch as the feature. A task is not done without them.
- Test the real code path. Repositories run on `fake_cloud_firestore`, services on those repositories. No mocks of our own classes. Fakes only for plugins: scanner, auth, SharedPreferences, clock.
- A fake does not run security rules or real offline behaviour: those are covered by `rules_test/` and the manual check.
- One behavior per test, named as a sentence: `issue sets INV-A-0001 and freezes the bill`. Put the rule in a `group` name or `// Rule:` comment.
- Arrange, act, assert. No logic or loops that hide failures; use table-driven cases. Fixed clock, no `Future.delayed`, no network.
- A bug gets a failing test first, then the fix.
- Do not test the framework, theme constants or trivial getters. No coverage percentage: the checklist below is the bar.
- A flaky test is fixed or deleted the same day.

## Types and folders
| Type | Folder | Tool |
|---|---|---|
| Rules (pure) | `test/features/*/logic/` | `test` |
| Repository, service | `test/features/*/data/`, `logic/` | fake Firestore |
| Provider | `test/features/*/providers/` | `ProviderContainer` with overrides |
| Widget | `test/features/*/ui/`, `test/core/` | `flutter_test` |
| Flow (whole app) | `test/flows/` | fakes, runs in CI |
| Security rules | `rules_test/` | Firebase emulator, `@firebase/rules-unit-testing` |
| Smoke | `integration_test/` | device plus emulator, local only |

## Helpers (`test/helpers/`)
- `TestEnv`: fake Firestore, signed-in `MockFirebaseAuth`, mock SharedPreferences, `FixedClock`, `FakeScanner`; builds a `ProviderContainer`.
- `pumpApp(tester, {size, textScale})`: defaults to 360x640, scale 1.0. Widget tests also run at 1.8 and fail on overflow.
- Builders with overridable defaults: `aProduct()`, `aBuyer()`, `aDemandItem()`, `aBill()`, `anIssuedBill()`, `aLedgerEntry()`.
- `FakeScanner`: returns queued barcodes. `FixedClock`: moves only when told.
- `SyncTracker` is tested with `Completer` futures that stay pending.

## Must-have tests
| Area | Cases |
|---|---|
| Prices (S5-S7) | Latest rate on or before the date, else default, for buyer, supplier, retail. Same-day save replaces. |
| Items (S12-S21) | Demand item status (open, in_summary, billed) and demand open/done. `billedQuantity` changes in the same batch on bill item add, edit, remove. Warning when billed exceeds demanded. One summary item per product; a second demand raises the quantity; deleting it unlinks demand items. |
| Bills (S23-S27) | Draft created on first item. Finish blocked at total 0. Issue sets number, total, date and freezes items. Only notes change after issue. Paid and On account are final. Move to account runs once, entry id `bill_`+id, amount = total. |
| Invoice numbers (S24, S33) | Letters 0=A, 25=Z, 26=AA, 51=AZ, 52=BA. Format and growth past 9999. Counter saved before the batch and works offline. Claim increments the registry; offline claim fails as `UnavailableException`. |
| Ledger (S28-S31) | Balance is the sum. Sign by type. Amount never 0. Bank transfer needs an own account, others none. Corrections instead of edits. |
| People and products (S1-S4, S9-S11) | Archive warnings for buyer and supplier. Hidden items leave pickers. Barcode unique through the lookup; changing it is one batch. Scan found and not found. |
| Login and sync (S32-S35) | Login persists. Sync state flips with pending writes. Logout warns when Not synced yet, then clears the cache and keeps letter and counter. |
| Security rules | Each rule in `DATABASE.md` has an allow and a deny test: non-owner denied; draft editable; issued bill changes beyond notes denied; `ledger` status without entry denied; entry update and delete denied; wrong sign and amount mismatch denied; bill items of non-draft bills denied; barcode overwrite denied; `lastNumber` decrease denied; extra keys denied. |
| UI | Every shared widget at 360x640 with scales 1.0 and 1.8 with no overflow. Tap targets at least 56. Empty, loading and error states shown. |

## Flow tests (`test/flows/`)
1. Demand, buying list, bill, finish, Put on account, balance shows.
2. Stock covers: demand item straight to a bill, finish, Paid.
3. Add a product with a barcode, scan it into a bill.
4. Logout with unsynced data shows the warning.

## Smoke test (`integration_test/`)
One test on a device against the Firebase emulator (`--dart-define=EMULATOR=true`): login, add a product, make and finish a bill. Run before each release, not in CI.

## Manual check before each release (release build, low-end phone)
1. Fresh install: login, setup gives a letter, full sync completes.
2. Airplane mode: make and finish a bill. It shows Not synced yet. Close and reopen offline: data is still there.
3. Reconnect: it becomes Synced. The console shows the bill, its items and the new `lastNumber`.
4. Reinstall: a new letter, same balances.
5. Scan a real barcode in poor light.
6. Extra large text with the phone font scale raised: nothing cut off, every button reachable.
7. Logout warning when not synced. Wrong password and no-internet messages are plain words.
8. Screen stays portrait. Back button follows `UI_PLAN.md`.

## CI commands
`flutter pub get`, `flutter analyze`, `flutter test`, then in `rules_test/`: `npm ci` and `firebase emulators:exec --only firestore "npm test"`. Locally, run only the touched feature's folder while working and the full suite before a PR.
