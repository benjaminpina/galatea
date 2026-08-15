/// Tool modes for the environment editor.
enum EditorTool {
  pointer,
  substrateBrush,
  sourcePlace,
  ovipositionPlace,
  agentPlace,
}

/// Brush shapes for the substrate terrain tool.
enum BrushShape { square, circle, diamondShape, hLine, vLine }

/// Returns the list of (dx, dy) offsets for cells affected by a brush stroke
/// centered at (0,0) with the given [shape] and [radius].
List<(int, int)> brushFootprint(BrushShape shape, int radius) {
  final cells = <(int, int)>[];
  final r = radius - 1; // radius=1 means single cell

  switch (shape) {
    case BrushShape.square:
      for (var dy = -r; dy <= r; dy++) {
        for (var dx = -r; dx <= r; dx++) {
          cells.add((dx, dy));
        }
      }
    case BrushShape.circle:
      final rSq = (r + 0.5) * (r + 0.5);
      for (var dy = -r; dy <= r; dy++) {
        for (var dx = -r; dx <= r; dx++) {
          if (dx * dx + dy * dy <= rSq) {
            cells.add((dx, dy));
          }
        }
      }
    case BrushShape.diamondShape:
      for (var dy = -r; dy <= r; dy++) {
        for (var dx = -r; dx <= r; dx++) {
          if (dx.abs() + dy.abs() <= r) {
            cells.add((dx, dy));
          }
        }
      }
    case BrushShape.hLine:
      for (var dx = -r; dx <= r; dx++) {
        cells.add((dx, 0));
      }
    case BrushShape.vLine:
      for (var dy = -r; dy <= r; dy++) {
        cells.add((0, dy));
      }
  }

  return cells;
}

/// A placed element on the canvas that can be selected.
sealed class PlacedElement {
  const PlacedElement();
  int get posX;
  int get posY;
  int get id;
}

class PlacedSource extends PlacedElement {
  const PlacedSource({
    required this.id,
    required this.posX,
    required this.posY,
    required this.nutrientId,
    required this.name,
    required this.quality,
    required this.level,
    required this.maxLevel,
    required this.regenRate,
  });

  @override
  final int id;
  @override
  final int posX;
  @override
  final int posY;
  final int nutrientId;
  final String name;
  final int quality;
  final int level;
  final int maxLevel;
  final double regenRate;
}

class PlacedOvipositionSite extends PlacedElement {
  const PlacedOvipositionSite({
    required this.id,
    required this.posX,
    required this.posY,
    required this.name,
    required this.quality,
    required this.capacity,
  });

  @override
  final int id;
  @override
  final int posX;
  @override
  final int posY;
  final String name;
  final int quality;
  final int capacity;
}

class PlacedAgent extends PlacedElement {
  const PlacedAgent({
    required this.id,
    required this.posX,
    required this.posY,
    required this.name,
    required this.sex,
    required this.prototypeId,
    required this.stageId,
    required this.age,
    this.orientation = 1,
    this.cyclesInStage = 0,
    this.gametes = 0,
    this.fertilizedEggs = 0,
    this.storedSpermPacks = 0,
    this.virgin = true,
  });

  @override
  final int id;
  @override
  final int posX;
  @override
  final int posY;
  final String name;
  final String sex;
  final int prototypeId;
  final int? stageId;
  final int age;
  final int orientation; // 1..8
  final int cyclesInStage;
  final int gametes;
  final int fertilizedEggs;
  final int storedSpermPacks;
  final bool virgin;
}
