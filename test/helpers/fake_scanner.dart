/// Fake barcode scanner returning queued barcodes in FIFO order.
/// Rule: docs/TESTING.md > Helpers. Story: none.
class FakeScanner {
  final List<String> _queuedBarcodes = <String>[];

  /// Queues a barcode string for upcoming scan requests.
  void queueBarcode(String barcode) {
    _queuedBarcodes.add(barcode);
  }

  /// Consumes and returns the next queued barcode, or null if empty.
  String? scanNext() {
    if (_queuedBarcodes.isEmpty) {
      return null;
    }
    return _queuedBarcodes.removeAt(0);
  }

  /// Removes all remaining queued barcodes.
  void clear() {
    _queuedBarcodes.clear();
  }
}
