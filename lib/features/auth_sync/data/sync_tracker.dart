// ignore_for_file: prefer_initializing_formals

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Tracks Cloud Firestore pending writes to provide real-time Synced / Not synced yet status.
/// Rule: docs/DATABASE.md > Sync. Story: S34.
class SyncTracker {
  /// Creates a [SyncTracker] with optional [FirebaseFirestore] and custom wait function.
  SyncTracker({
    FirebaseFirestore? firestore,
    Future<void> Function()? waitForPendingWritesFn,
  }) : _firestore = firestore,
       _waitForPendingWritesFn = waitForPendingWritesFn {
    _init();
  }

  final FirebaseFirestore? _firestore;
  final Future<void> Function()? _waitForPendingWritesFn;

  FirebaseFirestore get _resolvedFirestore =>
      _firestore ?? FirebaseFirestore.instance;

  final ValueNotifier<bool> _isSyncedNotifier = ValueNotifier<bool>(false);

  /// ValueListenable emitting current sync state (true = synced, false = not synced yet).
  ValueListenable<bool> get isSyncedListenable => _isSyncedNotifier;

  /// Current sync state.
  bool get isSynced => _isSyncedNotifier.value;

  int _pendingWrites = 0;

  Future<void> _init() async {
    await checkPendingWrites();
  }

  /// Marks state as pending (not synced yet) when a write occurs.
  void markPending() {
    _pendingWrites++;
    _isSyncedNotifier.value = false;
  }

  /// Waits for pending writes to complete and updates sync state.
  Future<void> checkPendingWrites() async {
    markPending();
    try {
      if (_waitForPendingWritesFn != null) {
        await _waitForPendingWritesFn();
      } else {
        await _resolvedFirestore.waitForPendingWrites();
      }
      _pendingWrites = (_pendingWrites > 0) ? _pendingWrites - 1 : 0;
      if (_pendingWrites == 0) {
        _isSyncedNotifier.value = true;
      }
    } catch (_) {
      _pendingWrites = (_pendingWrites > 0) ? _pendingWrites - 1 : 0;
      if (_pendingWrites == 0) {
        _isSyncedNotifier.value = true;
      }
    }
  }

  /// Disposes internal notifiers.
  void dispose() {
    _isSyncedNotifier.dispose();
  }
}
