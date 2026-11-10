# Architecture

Rules: `../wholesale_project.md`. Packages: `TECH_STACK.md`. Firestore details: `DATABASE.md`. Tests: `TESTING.md`. Colors, sizes, strings: `DESIGN_SYSTEM.md`.

## Layers
Flow: UI -> provider -> logic -> repository. Feature-first. No Clean Architecture, no interfaces except the scanner and the clock.

| Layer | Folder | Can | Cannot |
|---|---|---|---|
| UI | `ui/` | Watch providers, call notifier methods, use theme and shared widgets | Import repositories, services or Firebase; hold rules; hardcode colors, sizes, strings |
| Provider | `providers/` | Hold UI state, watch repository streams, call services, derive values with rules | Import widgets; hold rules inline; write to Firestore |
| Rules | `logic/` | Pure functions on models: prices, balance, statuses, totals, invoice number | Import Flutter, Firebase or Riverpod; do IO; call `DateTime.now()` |
| Services | `logic/` | Orchestrate repository calls, validate, throw `AppException` | Import Flutter, Riverpod or Firebase types; add pass-through methods |
| Repository | `data/` | Only layer touching Firestore, Auth, SharedPreferences; map documents to models; build batches; keep `billedQuantity` in sync | Hold rules beyond data integrity; import UI, providers or services |
| Models | `models/` | Immutable data, `copyWith`, `==` | Hold logic; use Firebase types (the repository converts `Timestamp`) |

A feature may import another feature's `models/`, `logic/` and `providers/`. Never its `data/` or `ui/`.

## Folders
```
lib/
  main.dart               init Firebase, run app
  app/                    app.dart, router.dart, shell with 4 tabs
  core/
    theme/                see DESIGN_SYSTEM.md
    widgets/              shared widgets
    errors/               app_exception.dart, error_message.dart
    data/                 firebase_providers.dart, paths, batch helper
    format/               money, dates, quantities
    strings.dart          every user-visible string
    clock.dart            injected time
  features/
    <feature>/{ui,providers,logic,data,models}/
test/                     mirrors lib/
integration_test/
rules_test/               security-rules tests (Node)
firestore.rules
```
Features: `auth_sync`, `products`, `prices`, `people` (buyers, suppliers, bank accounts, profile), `demands`, `purchase_lists`, `bills`, `ledger`, `settings`.

## State pattern
- Riverpod, no codegen. Firebase instances, SharedPreferences and the clock come from providers so tests override them.
- Lists: `StreamProvider` over a repository `watch` stream. Products, buyers and suppliers stay alive (pickers are instant). Per-document and per-parent streams use `autoDispose` with `family`.
- Screen state and commands: `Notifier` or `AsyncNotifier`. A command method calls a service and throws `AppException`; the UI runs it through one `runAction` helper that shows the message.
- Derived values (balance, statuses, prices, totals) are plain `Provider`s calling rules on watched data. Use `select` to limit rebuilds.
- Joins happen in Dart: build an id-to-model map once in a provider, never query per row.
- Never create providers inside `build`. Never `ref.read` in `build`.

## Writes and offline
- Never `await` a Firestore write on the UI path: its future completes only when the server confirms, which can be hours offline.
- Repository write methods return when the local cache has the change. They start the commit and attach an error handler that reports to the sync-state provider (`DATABASE.md`).
- Multi-document changes are one batch built in the repository. The device-letter claim is the only transaction: online only, with a timeout, failing as `UnavailableException`.

## Error handling
One sealed class, in `core/errors/app_exception.dart`:
```dart
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);
  final String message; // key into strings.dart, never raw text
  final Object? cause;
}
final class ValidationException extends AppException {}  // input breaks a rule
final class NotFoundException extends AppException {}
final class ConflictException extends AppException {}    // e.g. bill no longer issued
final class PermissionException extends AppException {}  // rules denied, not logged in
final class UnavailableException extends AppException {} // internet needed
final class UnknownException extends AppException {}     // wraps anything unexpected
```
- Rules and services throw `ValidationException` or `ConflictException`. Repositories convert `FirebaseException` to the matching type and wrap the rest in `UnknownException`.
- `error_message.dart` is the only place mapping an exception to plain words, via `strings.dart`. The UI never shows `toString()`.
- No empty `catch`. Catch only to convert or rethrow. Switch over `AppException` without `default`.

## Performance
- `ListView.builder`, `const` widgets, stable keys. No work or listeners in `build`.
- Read from the cache; never `Source.server`. No per-row queries, no sum queries.
- The first frame does not wait for sync. The full sync runs once per login (`DATABASE.md`).
- Autosave is debounced (500 ms) and writes only the changed item.
- Dispose controllers and subscriptions. Optimise only what a profile-mode run on a low-end phone shows slow.

## Security
- Security rules are the real protection (`DATABASE.md`). App checks exist for clear messages.
- Logout clears the Firestore cache and keeps only the device letter and invoice counter (`wholesale_project.md`, Invoice numbers).
- Android: `allowBackup="false"`. Restrict the Firebase API key to the app package and SHA-1 in the console.
- No secrets in the repo. No logs of names, amounts or ids in release builds: use `debugPrint` inside `kDebugMode`, never `print`.
- Validate every input in rules or services before a write: ints only, ranges, allowed values.

## Code conventions
- `analysis_options.yaml`: `flutter_lints`, `strict-casts`, `strict-inference`, `strict-raw-types`, `avoid_print`, `prefer_const_constructors`. `flutter analyze` must report nothing.
- Files `snake_case`: `*_screen.dart`, `*_provider.dart`, `*_service.dart`, `*_rules.dart`, `*_repository.dart`. One public class per file. Package imports only.
- Files under 300 lines, functions under 40. No `dynamic`. No `!` unless a test covers it.
- Money and quantities are `int`. Dates go through `core/format`; time comes from `clock.dart`.
- Doc comment (`///`) on every public class and function: what it does and why, then the rule and story it implements:
```dart
/// Price of [productId] for [buyerId] on [date]: latest rate on or before it,
/// else the product default.
/// Rule: wholesale_project.md > Prices. Story: S7.
int buyerPrice(...)
```
- `//` comments only for a non-obvious why. Comments are plain English, short.
- Immutable models: `final` fields, `const` constructors.
- Commits, branches, PRs: `GIT_WORKFLOW.md`.
