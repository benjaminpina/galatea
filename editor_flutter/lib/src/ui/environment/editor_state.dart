/// Tool modes for the environment editor.
enum EditorTool {
  pointer,
  substrateBrush,
  sourcePlace,
  ovipositionPlace,
  agentPlace,
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
  });

  @override
  final int id;
  @override
  final int posX;
  @override
  final int posY;
  final String name;
  final String sex;
  final int? prototypeId;
  final int? stageId;
  final int age;
}
