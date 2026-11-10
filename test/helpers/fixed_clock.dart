/// Deterministic clock for unit and widget testing that moves only when told.
/// Rule: docs/TESTING.md > Helpers. Story: none.
class FixedClock {
  /// Creates a [FixedClock] initialized to [initialTime] or 2026-11-10 10:00:00.
  FixedClock([DateTime? initialTime])
    : _now = initialTime ?? DateTime(2026, 11, 10, 10);

  DateTime _now;

  /// Current test timestamp.
  DateTime now() => _now;

  /// Advances the clock forward by [duration].
  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  /// Sets the clock to an exact [time].
  void set(DateTime time) {
    _now = time;
  }
}
