/// Shared definitions for relative movement tendencies.
///
/// Tendencies are RELATIVE to the agent's current heading, not absolute
/// compass directions. A high "Straight" weight means the agent tends to
/// keep going the way it faces; "Reverse" means it turns around.
///
/// The `turnIndex` (0..7) stored in the DB is ordered left-to-right by turn
/// angle so the editor reads like a steering wheel:
///   0 = Reverse (180°), 1 = Back-left (135°), 2 = Hard left (90°),
///   3 = Slight left (45°), 4 = Straight (0°), 5 = Slight right (45°),
///   6 = Hard right (90°), 7 = Back-right (135°).
library;

/// A relative-turn tendency slot, in editor presentation order (turnIndex 0..7).
class TurnSlot {
  const TurnSlot({
    required this.turnIndex,
    required this.label,
    required this.arrow,
    required this.defaultWeight,
  });

  /// Index stored in the DB (0..7), ordered by turn angle.
  final int turnIndex;

  /// Human-readable label describing the relative turn.
  final String label;

  /// Arrow glyph hinting the turn direction relative to "up = forward".
  final String arrow;

  /// Legacy-derived default probability weight.
  final String defaultWeight;
}

/// The 8 relative-turn slots in presentation order (left → right).
/// Default weights mirror the legacy defaults: strong forward bias,
/// gentle turns common, hard turns rare, reverse almost never.
const List<TurnSlot> turnSlots = [
  TurnSlot(turnIndex: 0, label: 'Reverse (180°)', arrow: '⬇', defaultWeight: '1'),
  TurnSlot(turnIndex: 1, label: 'Back-left (135°)', arrow: '↙', defaultWeight: '1'),
  TurnSlot(turnIndex: 2, label: 'Hard left (90°)', arrow: '⬅', defaultWeight: '10'),
  TurnSlot(turnIndex: 3, label: 'Slight left (45°)', arrow: '↖', defaultWeight: '25'),
  TurnSlot(turnIndex: 4, label: 'Straight (0°)', arrow: '⬆', defaultWeight: '50'),
  TurnSlot(turnIndex: 5, label: 'Slight right (45°)', arrow: '↗', defaultWeight: '25'),
  TurnSlot(turnIndex: 6, label: 'Hard right (90°)', arrow: '➡', defaultWeight: '10'),
  TurnSlot(turnIndex: 7, label: 'Back-right (135°)', arrow: '↘', defaultWeight: '1'),
];
