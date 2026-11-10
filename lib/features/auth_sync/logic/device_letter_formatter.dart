/// Converts a 0-based index to a device invoice letter (A, B, ..., Z, AA, AB, ...).
/// Rule: wholesale_project.md > Invoice numbers. Story: S33.
String indexToLetter(int index) {
  if (index < 0) {
    throw ArgumentError.value(index, 'index', 'Index must be non-negative');
  }
  var n = index;
  String result = '';
  while (true) {
    final int remainder = n % 26;
    result = String.fromCharCode(65 + remainder) + result;
    n = n ~/ 26 - 1;
    if (n < 0) {
      break;
    }
  }
  return result;
}
