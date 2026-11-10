# Decisions

Only big decisions. Details live in the file that owns them. Add an entry for a new big decision or a change; never edit an old entry, add a new one marked "Supersedes D-xx". "Owner" = decided by the owner; "Proposed" = proposed here, owner accepted by approving the docs.

### D-01 Backend and login (2026-11-07, owner)
Options: local SQLite only; own server or Supabase; Cloud Firestore + Firebase Auth. **Choice: Firestore + Auth.**
Why: offline cache, sync between phones and no server code, on a free plan. Revisit if: reads pass the free daily limit, or reports need joins and sums Firestore cannot do from the cache.

### D-02 Offline and one device at a time (2026-11-07, owner)
Options: online only; offline with conflict handling; offline, one device at a time, last write wins. **Choice: the last.**
Why: the owner works on one phone and loses signal in the store; conflict code is not worth it. Revisit if: a second person or two phones are used at once.

### D-03 Invoice numbers: device letter plus counter (2026-11-07, owner)
Options: highest number plus one (duplicates offline); counter document in a transaction (needs internet); random ids; letter per device plus local counter. **Choice: letter plus counter**, stored as `invoiceNumber`, not as the bill id, because drafts have no number yet.
Why: works offline and cannot clash. Gaps can appear after a crash. Revisit if: the law or the accountant requires gap-free numbers.

### D-04 Buyer balance is calculated, not stored (2026-11-07, Proposed)
Options: stored balance changed with `increment`; sum in Dart from cached entries. **Choice: sum in Dart.**
Why: one source of truth, no sum queries offline, entries are append-only. Revisit if: a buyer passes about 5,000 entries or the account screen is slow.

### D-05 One denormalised field (2026-11-07, Proposed)
Options: copy names and statuses onto bills and items; store statuses; only `DEMAND_ITEM.billedQuantity`. **Choice: only `billedQuantity`.**
Why: everything is cached so names are joined in Dart; every copy needs sync code. Revisit if: the debug assertion on `billedQuantity` ever fires, or a list screen is slow.

### D-06 Writes are not awaited; sync state from pending writes (2026-11-07, Proposed)
Options: await every commit (UI hangs offline); track pending writes and show Synced / Not synced yet. **Choice: the second.**
Why: a commit future only completes with server confirmation. Revisit if: the server rejects writes in real use (add a visible failure state).

### D-07 Security rules enforce the bill lifecycle (2026-11-07, Proposed)
Options: app checks only; rules with cross-document checks (`get`, `getAfter`). **Choice: rules.**
Why: the owner asked that issued bills and ledger entries cannot change; app checks alone can be bypassed or buggy. Revisit if: rule `get` reads add noticeable cost or the rules become hard to test.

### D-08 Full sync after login, unlimited cache, cache cleared at logout (2026-11-07, Proposed)
Options: load on demand; full sync and keep the cache forever; full sync and clear at logout. **Choice: the last.**
Why: the whole business must work offline; a handed-over phone must not hold data. Revisit if: re-sync after login is slow or past about 20,000 documents.

### D-09 No in-app backup (2026-11-07, Proposed)
Options: nothing; manual export; scheduled export (paid plan). **Choice: nothing in v1.**
Why: backup screens were removed on purpose; Firestore keeps the data but has no point-in-time recovery on the free plan. Revisit if: before `v1.0.0`, or after any data scare. A monthly manual export is the first option.

### D-10 State management: Riverpod without codegen (2026-11-07, owner)
Options: Provider; Bloc; Riverpod with generators; Riverpod plain. **Choice: plain Riverpod.**
Why: less tooling and fewer generated files for a small team and free AI agents. Revisit if: the hand-written boilerplate becomes the main source of bugs.

### D-11 Plain layers, no Clean Architecture (2026-11-07, owner)
Options: Clean Architecture with use cases and interfaces; UI, provider, logic, repository. **Choice: four layers**, interfaces only for the scanner and clock.
Why: enough structure to test rules without ceremony. Revisit if: a second backend appears or services start duplicating each other.

### D-12 Tests: fake Firestore plus rules tests (2026-11-07, Proposed)
Options: mock repositories; emulator for every test; `fake_cloud_firestore` for logic and the emulator only for rules. **Choice: the last.**
Why: fast tests in CI with real code paths, and the rules still tested for real. This replaces "real database in tests". Revisit if: a bug slips through because the fake differs from Firestore.

### D-13 Whole-number money and quantities (2026-11-07, owner)
Options: decimals; whole numbers. **Choice: whole numbers.**
Why: simple and exact. Revisit if: goods are sold by fractions, such as half a kilo.

### D-14 Android only, portrait, one light theme (2026-11-07, owner)
Options: also iOS and dark mode; Android only with a text-size setting. **Choice: Android only.**
Why: one phone type, one user, big text matters more than themes. Revisit if: an iPhone user or a tablet appears.

### D-15 Git: protected main, task branches, merge commits (2026-11-07, owner)
Options: squash merges; direct commits; merge commits with clean small commits. **Choice: merge commits.**
Why: shows the real, tidy history for a portfolio. Revisit if: history becomes noisy.
