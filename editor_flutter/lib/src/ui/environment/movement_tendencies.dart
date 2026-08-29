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
    required this.shortLabel,
    required this.arrow,
    required this.defaultWeight,
    required this.gridRow,
    required this.gridCol,
  });

  /// Index stored in the DB (0..7), ordered by turn angle.
  final int turnIndex;

  /// Human-readable label describing the relative turn.
  final String label;

  /// Compact label for the spatial grid layout.
  final String shortLabel;

  /// Arrow glyph hinting the turn direction relative to "up = forward".
  final String arrow;

  /// Legacy-derived default probability weight.
  final String defaultWeight;

  /// Position in the 3×3 spatial grid (agent occupies the center, row 1 col 1).
  /// The agent faces "up" (row 0 = forward, row 2 = backward).
  final int gridRow;
  final int gridCol;
}

/// The 8 relative-turn slots in presentation order (left → right).
/// Default weights mirror the legacy defaults: strong forward bias,
/// gentle turns common, hard turns rare, reverse almost never.
///
/// gridRow/gridCol lay the slots out spatially around a centered agent
/// (which faces upward = forward):
///
///   [Slight-L] [Straight] [Slight-R]   row 0 (front)
///   [Hard-L  ] [ AGENT  ] [Hard-R  ]   row 1 (sides)
///   [Back-L  ] [Reverse ] [Back-R  ]   row 2 (rear)
const List<TurnSlot> turnSlots = [
  TurnSlot(
    turnIndex: 0,
    label: 'Reverse (180°)',
    shortLabel: 'Reverse',
    arrow: '↓',
    defaultWeight: '1',
    gridRow: 2,
    gridCol: 1,
  ),
  TurnSlot(
    turnIndex: 1,
    label: 'Back-left (135°)',
    shortLabel: 'Back-L',
    arrow: '↙',
    defaultWeight: '1',
    gridRow: 2,
    gridCol: 0,
  ),
  TurnSlot(
    turnIndex: 2,
    label: 'Hard left (90°)',
    shortLabel: 'Hard-L',
    arrow: '←',
    defaultWeight: '10',
    gridRow: 1,
    gridCol: 0,
  ),
  TurnSlot(
    turnIndex: 3,
    label: 'Slight left (45°)',
    shortLabel: 'Slight-L',
    arrow: '↖',
    defaultWeight: '25',
    gridRow: 0,
    gridCol: 0,
  ),
  TurnSlot(
    turnIndex: 4,
    label: 'Straight (0°)',
    shortLabel: 'Straight',
    arrow: '↑',
    defaultWeight: '50',
    gridRow: 0,
    gridCol: 1,
  ),
  TurnSlot(
    turnIndex: 5,
    label: 'Slight right (45°)',
    shortLabel: 'Slight-R',
    arrow: '↗',
    defaultWeight: '25',
    gridRow: 0,
    gridCol: 2,
  ),
  TurnSlot(
    turnIndex: 6,
    label: 'Hard right (90°)',
    shortLabel: 'Hard-R',
    arrow: '→',
    defaultWeight: '10',
    gridRow: 1,
    gridCol: 2,
  ),
  TurnSlot(
    turnIndex: 7,
    label: 'Back-right (135°)',
    shortLabel: 'Back-R',
    arrow: '↘',
    defaultWeight: '1',
    gridRow: 2,
    gridCol: 2,
  ),
];

/// Returns the turn slot occupying the given grid cell, or null for the center
/// (which holds the agent icon).
TurnSlot? turnSlotAt(int row, int col) {
  for (final s in turnSlots) {
    if (s.gridRow == row && s.gridCol == col) return s;
  }
  return null;
}
