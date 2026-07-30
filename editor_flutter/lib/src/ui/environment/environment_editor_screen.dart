import 'package:drift/drift.dart' hide Column;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import 'editor_state.dart';
import 'environment_canvas.dart';
import 'left_sidebar.dart';
import '../nutrients/nutrient_list_screen.dart';
import '../substrates/substrate_list_screen.dart';
import '../genetics/loci_list_screen.dart';
import '../ontogeny/stage_list_screen.dart';
import '../prototypes/prototype_list_screen.dart';

/// Which configuration section is open in the right panel.
enum ConfigSection { nutrients, substrates, genetics, stages, prototypes }

/// Unified environment editor — the main working screen.
///
/// Layout:
/// - Top: compact toolbar with project config section buttons + save/close
/// - Left (200px): drawing tools + tool-specific options (always visible)
/// - Center: canvas
/// - Right (300px, togglable): project config editor for the selected section
/// - Bottom: status bar
class EnvironmentEditorScreen extends ConsumerStatefulWidget {
  const EnvironmentEditorScreen({super.key, required this.environmentId});

  final int environmentId;

  @override
  ConsumerState<EnvironmentEditorScreen> createState() =>
      _EnvironmentEditorScreenState();
}

class _EnvironmentEditorScreenState
    extends ConsumerState<EnvironmentEditorScreen> {
  // --- Canvas state ---
  List<List<int>> _grid = [];
  int _envWidth = 0;
  int _envHeight = 0;
  double _cellSize = 12;
  Offset _offset = Offset.zero;
  String _envName = '';

  // --- Tool state ---
  EditorTool _currentTool = EditorTool.substrateBrush;
  int _selectedSubstrateId = 1;
  int _selectedNutrientId = 0;
  int? _selectedPrototypeId;
  String _selectedSex = 'M';

  // --- Placed elements ---
  List<PlacedSource> _sources = [];
  List<PlacedOvipositionSite> _oviSites = [];
  List<PlacedAgent> _agents = [];

  // --- Selection ---
  PlacedElement? _selectedElement;

  // --- Painting ---
  bool _painting = false;
  Offset _panStart = Offset.zero;
  Offset _offsetStart = Offset.zero;
  bool _panning = false;

  // --- Hover ---
  int _hoverX = -1;
  int _hoverY = -1;

  // --- Right config panel ---
  ConfigSection? _openSection;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    final env = await (db.select(
      db.environments,
    )..where((t) => t.id.equals(widget.environmentId))).getSingleOrNull();
    if (env == null) return;

    _envWidth = env.width;
    _envHeight = env.height;
    _envName = env.name;

    _grid = List.generate(_envHeight, (_) => List.filled(_envWidth, 0));
    final rows =
        await (db.select(db.substrateMapRows)
              ..where((t) => t.environmentId.equals(widget.environmentId))
              ..orderBy([(t) => OrderingTerm.asc(t.yCoord)]))
            .get();
    for (final row in rows) {
      final y = row.yCoord;
      if (y >= 0 && y < _envHeight) {
        final parts = row.mapData.split(',');
        for (var x = 0; x < parts.length && x < _envWidth; x++) {
          _grid[y][x] = int.tryParse(parts[x].trim()) ?? 0;
        }
      }
    }

    final envDao = ref.read(environmentDaoProvider)!;
    final sources = await envDao.getSources(widget.environmentId);
    final oviSites = await envDao.getOvipositionSites(widget.environmentId);
    final agents = await envDao.getAgents(widget.environmentId);

    _sources = sources
        .map(
          (s) => PlacedSource(
            id: s.id,
            posX: s.posX,
            posY: s.posY,
            nutrientId: s.nutrientId,
            name: s.name,
            quality: s.quality,
            level: s.level,
            maxLevel: s.maxLevel,
            regenRate: s.regenRate,
          ),
        )
        .toList();
    _oviSites = oviSites
        .map(
          (o) => PlacedOvipositionSite(
            id: o.id,
            posX: o.posX,
            posY: o.posY,
            name: o.name,
            quality: o.quality,
            capacity: o.capacity,
          ),
        )
        .toList();
    _agents = agents
        .map(
          (a) => PlacedAgent(
            id: a.id,
            posX: a.posX,
            posY: a.posY,
            name: a.name,
            sex: a.sex,
            prototypeId: a.prototypeId,
            stageId: a.stageId,
            age: a.age,
          ),
        )
        .toList();

    final nutrients = ref.read(nutrientsProvider).valueOrNull;
    if (nutrients != null && nutrients.isNotEmpty) {
      _selectedNutrientId = nutrients.first.id;
    }
    setState(() {});
  }

  // --- Persistence ---

  Future<void> _saveAll() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;
    await db.batch((batch) {
      batch.deleteWhere(
        db.substrateMapRows,
        (t) => t.environmentId.equals(widget.environmentId),
      );
      for (var y = 0; y < _envHeight; y++) {
        batch.insert(
          db.substrateMapRows,
          SubstrateMapRowsCompanion.insert(
            environmentId: widget.environmentId,
            yCoord: y,
            mapData: _grid[y].join(','),
          ),
        );
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved'), duration: Duration(seconds: 1)),
      );
    }
  }

  // --- Tool actions ---

  void _onCellTap(int x, int y) {
    if (x < 0 || x >= _envWidth || y < 0 || y >= _envHeight) return;
    switch (_currentTool) {
      case EditorTool.pointer:
        _selectElementAt(x, y);
      case EditorTool.substrateBrush:
        _paintSubstrate(x, y);
      case EditorTool.sourcePlace:
        _placeSource(x, y);
      case EditorTool.ovipositionPlace:
        _placeOvipositionSite(x, y);
      case EditorTool.agentPlace:
        _placeAgent(x, y);
    }
  }

  void _onCellDrag(int x, int y) {
    if (x < 0 || x >= _envWidth || y < 0 || y >= _envHeight) return;
    if (_currentTool == EditorTool.substrateBrush) {
      _paintSubstrate(x, y);
    }
  }

  void _paintSubstrate(int x, int y) {
    if (_grid[y][x] != _selectedSubstrateId) {
      setState(() => _grid[y][x] = _selectedSubstrateId);
    }
  }

  Future<void> _placeSource(int x, int y) async {
    final envDao = ref.read(environmentDaoProvider);
    if (envDao == null || _selectedNutrientId == 0) return;
    final name = 'Source${_sources.length + 1}';
    final id = await envDao.placeSource(
      EnvironmentSourcesCompanion.insert(
        environmentId: widget.environmentId,
        nutrientId: _selectedNutrientId,
        name: name,
        posX: x,
        posY: y,
      ),
    );
    setState(() {
      _sources.add(
        PlacedSource(
          id: id,
          posX: x,
          posY: y,
          nutrientId: _selectedNutrientId,
          name: name,
          quality: 10,
          level: 50,
          maxLevel: 100,
          regenRate: 1.1,
        ),
      );
      _selectedElement = _sources.last;
    });
  }

  Future<void> _placeOvipositionSite(int x, int y) async {
    final envDao = ref.read(environmentDaoProvider);
    if (envDao == null) return;
    final name = 'OviSite${_oviSites.length + 1}';
    final id = await envDao.placeOvipositionSite(
      EnvironmentOvipositionSitesCompanion.insert(
        environmentId: widget.environmentId,
        name: name,
        posX: x,
        posY: y,
      ),
    );
    setState(() {
      _oviSites.add(
        PlacedOvipositionSite(
          id: id,
          posX: x,
          posY: y,
          name: name,
          quality: 10,
          capacity: 50,
        ),
      );
      _selectedElement = _oviSites.last;
    });
  }

  Future<void> _placeAgent(int x, int y) async {
    final envDao = ref.read(environmentDaoProvider);
    if (envDao == null) return;
    final name = 'Agent${_agents.length + 1}';
    final id = await envDao.placeAgent(
      EnvironmentAgentsCompanion.insert(
        environmentId: widget.environmentId,
        name: name,
        posX: x,
        posY: y,
        sex: _selectedSex,
        prototypeId: Value(_selectedPrototypeId),
      ),
    );
    setState(() {
      _agents.add(
        PlacedAgent(
          id: id,
          posX: x,
          posY: y,
          name: name,
          sex: _selectedSex,
          prototypeId: _selectedPrototypeId,
          stageId: null,
          age: 0,
        ),
      );
      _selectedElement = _agents.last;
    });
  }

  void _selectElementAt(int x, int y) {
    for (final a in _agents) {
      if (a.posX == x && a.posY == y) {
        setState(() => _selectedElement = a);
        return;
      }
    }
    for (final s in _sources) {
      if (s.posX == x && s.posY == y) {
        setState(() => _selectedElement = s);
        return;
      }
    }
    for (final o in _oviSites) {
      if (o.posX == x && o.posY == y) {
        setState(() => _selectedElement = o);
        return;
      }
    }
    setState(() => _selectedElement = null);
  }

  Future<void> _deleteSelectedElement() async {
    final el = _selectedElement;
    if (el == null) return;
    final db = ref.read(databaseProvider);
    if (db == null) return;
    switch (el) {
      case PlacedSource():
        await (db.delete(
          db.environmentSources,
        )..where((t) => t.id.equals(el.id))).go();
        setState(() {
          _sources.removeWhere((s) => s.id == el.id);
          _selectedElement = null;
        });
      case PlacedOvipositionSite():
        await (db.delete(
          db.environmentOvipositionSites,
        )..where((t) => t.id.equals(el.id))).go();
        setState(() {
          _oviSites.removeWhere((o) => o.id == el.id);
          _selectedElement = null;
        });
      case PlacedAgent():
        await (db.delete(
          db.environmentAgents,
        )..where((t) => t.id.equals(el.id))).go();
        setState(() {
          _agents.removeWhere((a) => a.id == el.id);
          _selectedElement = null;
        });
    }
  }

  // --- Gesture handling ---

  (int, int) _localToGrid(Offset local) {
    final x = ((local.dx - _offset.dx) / _cellSize).floor();
    final y = ((local.dy - _offset.dy) / _cellSize).floor();
    return (x, y);
  }

  void _handlePanStart(DragStartDetails d) {
    if (HardwareKeyboard.instance.logicalKeysPressed.contains(
      LogicalKeyboardKey.shiftLeft,
    )) {
      _panning = true;
      _panStart = d.localPosition;
      _offsetStart = _offset;
    } else {
      _panning = false;
      _painting = true;
      final (x, y) = _localToGrid(d.localPosition);
      _onCellTap(x, y);
    }
  }

  void _handlePanUpdate(DragUpdateDetails d) {
    if (_panning) {
      setState(() => _offset = _offsetStart + (d.localPosition - _panStart));
    } else if (_painting) {
      final (x, y) = _localToGrid(d.localPosition);
      _onCellDrag(x, y);
    }
  }

  void _handlePanEnd(DragEndDetails _) {
    _painting = false;
    _panning = false;
  }

  void _handleSecondaryTap(TapDownDetails d) {
    final (x, y) = _localToGrid(d.localPosition);
    if (x >= 0 && x < _envWidth && y >= 0 && y < _envHeight) {
      _selectElementAt(x, y);
    }
  }

  void _handleHover(PointerHoverEvent e) {
    final (x, y) = _localToGrid(e.localPosition);
    if (x != _hoverX || y != _hoverY) {
      setState(() {
        _hoverX = x;
        _hoverY = y;
      });
    }
  }

  void _handleScroll(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      setState(() {
        _cellSize = (_cellSize + (e.scrollDelta.dy > 0 ? -1.0 : 1.0)).clamp(
          4.0,
          40.0,
        );
      });
    }
  }

  // --- Config panel toggle ---

  void _toggleConfig(ConfigSection section) {
    setState(() {
      if (_openSection == section) {
        _openSection = null; // close
      } else {
        _openSection = section;
      }
    });
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final substrates = ref.watch(substratesProvider).valueOrNull ?? [];
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];

    final substrateColorMap = <int, Color>{0: Colors.black};
    for (final sub in substrates) {
      substrateColorMap[sub.id] = Color(sub.color);
    }
    final nutrientColorMap = <int, Color>{};
    for (final nut in nutrients) {
      nutrientColorMap[nut.id] = Color(nut.color);
    }

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // === TOP TOOLBAR (config sections + save/close) ===
          _buildTopBar(scheme),
          // === MAIN AREA ===
          Expanded(
            child: Row(
              children: [
                // --- Left panel: drawing tools + options ---
                SizedBox(
                  width: 200,
                  child: LeftSidebar(
                    currentTool: _currentTool,
                    onToolChanged: (tool) => setState(() {
                      _currentTool = tool;
                      if (tool != EditorTool.pointer) {
                        _selectedElement = null;
                      }
                    }),
                    substrates: substrates,
                    nutrients: nutrients,
                    prototypes: prototypes,
                    selectedSubstrateId: _selectedSubstrateId,
                    selectedNutrientId: _selectedNutrientId,
                    selectedPrototypeId: _selectedPrototypeId,
                    selectedSex: _selectedSex,
                    selectedElement: _selectedElement,
                    onSubstrateChanged: (id) =>
                        setState(() => _selectedSubstrateId = id),
                    onNutrientChanged: (id) =>
                        setState(() => _selectedNutrientId = id),
                    onPrototypeChanged: (id) =>
                        setState(() => _selectedPrototypeId = id),
                    onSexChanged: (sex) => setState(() => _selectedSex = sex),
                    onDeleteElement: _deleteSelectedElement,
                    cellSize: _cellSize,
                    onZoomIn: () => setState(
                      () => _cellSize = (_cellSize + 2).clamp(4, 40),
                    ),
                    onZoomOut: () => setState(
                      () => _cellSize = (_cellSize - 2).clamp(4, 40),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                // --- Center: canvas ---
                Expanded(
                  child: _buildCanvas(substrateColorMap, nutrientColorMap),
                ),
                // --- Right panel: config editor (togglable) ---
                if (_openSection != null) ...[
                  const VerticalDivider(width: 1),
                  SizedBox(width: 300, child: _buildConfigPanel()),
                ],
              ],
            ),
          ),
          // === STATUS BAR ===
          _buildStatusBar(scheme),
        ],
      ),
    );
  }

  /// Compact top toolbar with labeled config section buttons.
  Widget _buildTopBar(ColorScheme scheme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Save.
          _BarButton(icon: Icons.save, label: 'Save', onTap: _saveAll),
          const SizedBox(width: 12),
          // Separator.
          Container(width: 1, height: 20, color: scheme.outlineVariant),
          const SizedBox(width: 12),
          // Config section buttons (labeled, clearly distinct from drawing tools).
          _BarButton(
            icon: Icons.water_drop_outlined,
            label: 'Nutrients',
            active: _openSection == ConfigSection.nutrients,
            onTap: () => _toggleConfig(ConfigSection.nutrients),
          ),
          _BarButton(
            icon: Icons.terrain,
            label: 'Substrates',
            active: _openSection == ConfigSection.substrates,
            onTap: () => _toggleConfig(ConfigSection.substrates),
          ),
          _BarButton(
            icon: Icons.biotech,
            label: 'Genetics',
            active: _openSection == ConfigSection.genetics,
            onTap: () => _toggleConfig(ConfigSection.genetics),
          ),
          _BarButton(
            icon: Icons.timeline,
            label: 'Stages',
            active: _openSection == ConfigSection.stages,
            onTap: () => _toggleConfig(ConfigSection.stages),
          ),
          _BarButton(
            icon: Icons.person,
            label: 'Prototypes',
            active: _openSection == ConfigSection.prototypes,
            onTap: () => _toggleConfig(ConfigSection.prototypes),
          ),
          const Spacer(),
          // Environment name.
          Text(
            _envName,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          // Close project.
          _BarButton(
            icon: Icons.close,
            label: 'Close',
            onTap: () => ref.read(workspacePathProvider.notifier).state = null,
          ),
        ],
      ),
    );
  }

  /// Right panel content based on the selected config section.
  Widget _buildConfigPanel() {
    return switch (_openSection!) {
      ConfigSection.nutrients => const NutrientListScreen(embedded: true),
      ConfigSection.substrates => const SubstrateListScreen(embedded: true),
      ConfigSection.genetics => const LociListScreen(embedded: true),
      ConfigSection.stages => const StageListScreen(embedded: true),
      ConfigSection.prototypes => const PrototypeListScreen(embedded: true),
    };
  }

  Widget _buildCanvas(
    Map<int, Color> substrateColorMap,
    Map<int, Color> nutrientColorMap,
  ) {
    if (_envWidth == 0 || _envHeight == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    return Listener(
      onPointerSignal: _handleScroll,
      onPointerHover: _handleHover,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onSecondaryTapDown: _handleSecondaryTap,
        child: ClipRect(
          child: CustomPaint(
            size: Size.infinite,
            painter: EnvironmentCanvasPainter(
              grid: _grid,
              width: _envWidth,
              height: _envHeight,
              cellSize: _cellSize,
              offset: _offset,
              substrateColorMap: substrateColorMap,
              nutrientColorMap: nutrientColorMap,
              sources: _sources,
              oviSites: _oviSites,
              agents: _agents,
              selectedElement: _selectedElement,
              hoverX: _hoverX,
              hoverY: _hoverY,
              currentTool: _currentTool,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(ColorScheme scheme) {
    final coord =
        (_hoverX >= 0 &&
            _hoverX < _envWidth &&
            _hoverY >= 0 &&
            _hoverY < _envHeight)
        ? '($_hoverX, $_hoverY)'
        : '—';
    final tool = switch (_currentTool) {
      EditorTool.pointer => 'Pointer',
      EditorTool.substrateBrush => 'Terrain',
      EditorTool.sourcePlace => 'Source',
      EditorTool.ovipositionPlace => 'Oviposition',
      EditorTool.agentPlace => 'Agent',
    };
    final count = _sources.length + _oviSites.length + _agents.length;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            coord,
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Text(
            tool,
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Text(
            '$count elem.',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            'Shift+Drag: pan · Scroll: zoom',
            style: TextStyle(fontSize: 10, color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

// --- Toolbar button with icon + label ---

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: active ? scheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: active ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: active
                        ? scheme.onPrimaryContainer
                        : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
