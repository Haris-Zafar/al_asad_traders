import 'package:al_asad_traders/core/errors/app_exception.dart';
import 'package:al_asad_traders/core/strings.dart';
import 'package:al_asad_traders/features/auth_sync/logic/device_letter_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for [DeviceSetupRepository].
/// Rule: docs/ARCHITECTURE.md > State pattern. Story: S33.
final Provider<DeviceSetupRepository> deviceSetupRepositoryProvider =
    Provider<DeviceSetupRepository>((ref) {
      return DeviceSetupRepository(FirebaseFirestore.instance);
    });

/// Repository handling device letter claim transaction and initial full sync.
/// Rule: wholesale_project.md > S33. Story: S33.
class DeviceSetupRepository {
  /// Creates a [DeviceSetupRepository] with [firestore] and optional [prefs] override.
  DeviceSetupRepository(this._firestore, {SharedPreferences? prefs})
    : _prefsOverride = prefs;

  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefsOverride;

  static const String _prefSetupCompleted = 'device_setup_completed';
  static const String _prefDeviceLetter = 'device_letter';
  static const String _prefDeviceLastNumber = 'device_last_number';

  /// All database collections required for full sync at first login.
  /// Rule: docs/DATABASE.md > Sync. Story: S33.
  static const List<String> allCollections = <String>[
    'products',
    'productSkus',
    'tags',
    'productTags',
    'suppliers',
    'buyers',
    'profile',
    'bankAccounts',
    'supplierRates',
    'buyerRates',
    'retailPrices',
    'demands',
    'demandItems',
    'summaries',
    'summaryItems',
    'bills',
    'billItems',
    'ledgerEntries',
    'devices',
    'deviceRegistry',
  ];

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  /// Checks whether device setup has been completed locally.
  /// Rule: wholesale_project.md > S33. Story: S33.
  Future<bool> isDeviceSetupCompleted() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_prefSetupCompleted) ?? false;
  }

  /// Gets the claimed device invoice letter, or null if not set.
  /// Rule: wholesale_project.md > Invoice numbers. Story: S33.
  Future<String?> getClaimedLetter() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_prefDeviceLetter);
  }

  /// Executes transaction to claim next available invoice letter from [deviceRegistry/main].
  /// Rule: docs/DATABASE.md > Atomic operations. Story: S33.
  Future<String> claimDeviceLetter() async {
    try {
      final DocumentReference<Map<String, dynamic>> registryRef = _firestore
          .collection('deviceRegistry')
          .doc('main');

      final String claimedLetter = await _firestore.runTransaction((
        Transaction transaction,
      ) async {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(registryRef);

        int nextIndex = 0;
        if (snapshot.exists && snapshot.data() != null) {
          nextIndex = (snapshot.data()!['nextIndex'] as num?)?.toInt() ?? 0;
        }

        final String letter = indexToLetter(nextIndex);

        if (snapshot.exists) {
          transaction.update(registryRef, <String, dynamic>{
            'nextIndex': nextIndex + 1,
          });
        } else {
          transaction.set(registryRef, <String, dynamic>{
            'nextIndex': nextIndex + 1,
          });
        }

        final DocumentReference<Map<String, dynamic>> deviceRef = _firestore
            .collection('devices')
            .doc(letter);

        transaction.set(deviceRef, <String, dynamic>{
          'lastNumber': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return letter;
      });

      final SharedPreferences prefs = await _prefs;
      await prefs.setString(_prefDeviceLetter, claimedLetter);
      await prefs.setInt(_prefDeviceLastNumber, 0);

      return claimedLetter;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw const UnavailableException(AppStrings.errorInternetNeeded);
      }
      throw UnknownException(AppStrings.errorGeneric, e);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Performs full sync by reading every collection once from the server.
  /// Rule: docs/DATABASE.md > Sync. Story: S33.
  Future<void> performFullSync() async {
    try {
      for (final String collection in allCollections) {
        await _firestore
            .collection(collection)
            .get(const GetOptions(source: Source.server));
      }

      final SharedPreferences prefs = await _prefs;
      await prefs.setBool(_prefSetupCompleted, true);
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw const UnavailableException(AppStrings.errorInternetNeeded);
      }
      throw UnknownException(AppStrings.errorGeneric, e);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw UnknownException(AppStrings.errorGeneric, e);
    }
  }

  /// Executes first-time device setup: claims letter and performs full sync.
  /// Rule: wholesale_project.md > S33. Story: S33.
  Future<void> executeFirstSetup() async {
    if (await isDeviceSetupCompleted()) {
      return;
    }
    await claimDeviceLetter();
    await performFullSync();
  }
}
