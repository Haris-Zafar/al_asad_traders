# Tech Stack

Business rules: `wholesale_project.md`. Layers: `ARCHITECTURE.md`.

## Platform
- Flutter stable with its bundled Dart. Android only: minSdk 26, portrait lock, compileSdk and targetSdk = Flutter defaults.
- Firebase free Spark plan: Cloud Firestore and Auth (email and password). The owner account is created by hand in the console; no sign-up screen.
- Tools: Android Studio, Firebase CLI, FlutterFire CLI, Node (security-rules tests only).
- T-01 writes the major version it resolves into the table. Exact versions live in the committed `pubspec.lock`.
- Commit `firebase_options.dart` and `google-services.json` (client config is not secret; rules and login protect the data). Never commit service keys, passwords or `.env`.

## Packages
| Package | Version | Why |
|---|---|---|
| flutter_riverpod | ^3 | State and injection. Notifier API, no codegen. |
| go_router | T-01 | Routing, `StatefulShellRoute` for the 4 tabs. |
| mobile_scanner | T-01 | Barcode scan (S2). Asks for the camera itself. |
| firebase_core, firebase_auth, cloud_firestore | T-01 | Startup, persistent login (S32), database with offline cache, batches, pending-writes metadata. |
| shared_preferences | T-01 | Local invoice counter, device letter, text-size setting. |
| intl | T-01 | Date and thousands-separator formatting. |
| flutter_lints (dev) | T-01 | Lint base for `analysis_options.yaml`. |
| fake_cloud_firestore (dev) | T-01 | In-memory Firestore for repository and logic tests. Replaces "real database": a fake does not run security rules or offline behaviour. |
| firebase_auth_mocks (dev) | T-01 | Fake Auth for tests. |
| @firebase/rules-unit-testing (npm, dev) | T-01 | Runs `firestore.rules` tests on the Firebase emulator. |

`flutter_test` and `integration_test` come from the SDK. Hand-written fakes for the scanner; no mocking package.

## Deliberately not used
- build_runner, freezed, json_serializable, riverpod_generator: no codegen; models and `copyWith` by hand.
- provider, bloc, get_it: Riverpod covers state and injection.
- hive, sqflite, drift, isar: Firestore's cache is the local store.
- dio, http: only Firebase SDKs talk to the network.
- connectivity_plus: sync state comes from pending-writes metadata.
- permission_handler: the scanner asks for the camera, nothing else is needed.
- uuid: Firestore makes ids. google_fonts: downloads fonts at runtime; use the system font.
- flutter_screenutil, easy_localization: plain `MediaQuery`, English only, strings in one constants file.
- firebase_storage, crashlytics, messaging, analytics, app_check, pdf, printing: out of scope.
- mocktail, mockito, equatable: not needed.

## Android permissions
- `INTERNET`, `ACCESS_NETWORK_STATE`: Firebase.
- `CAMERA`: barcode scan, asked at first scan; `android.hardware.camera` declared `required="false"`.
- No storage, location, contacts or notifications.

## Adding a package
1. The agent asks first, stating the need, why the SDK or a listed package cannot do it, and the cost.
2. It must support Android, have a verified publisher or wide use, and a release in the last 12 months.
3. After approval: `flutter pub add`, caret version, no git or path dependencies.
4. Update this file in the same commit; log big choices in `DECISIONS.md`.
