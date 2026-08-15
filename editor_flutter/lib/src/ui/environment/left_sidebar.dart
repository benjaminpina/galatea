import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../database/database.dart';
import 'agent_edit_dialog.dart';
import 'editor_state.dart';

/// Left panel content when showing tool-specific options.
/// Displays contextual controls for the currently active drawing tool,
/// or properties of the selected element when using the pointer.
class LeftSidebar extends StatelessWidget {
  const LeftSidebar({
    super.key,
    required this.currentTool,
    required this.onToolChanged,
    required this.substrates,
    required this.nutrients,
    required this.prototypes,
    required this.selectedSubstrateId,
    required this.selectedNutrientId,
    required this.selectedPrototypeId,
    required this.selectedSex,
    required this.selectedElement,
    required this.onSubstrateChanged,
    required this.onNutrientChanged,
    required this.onPrototypeChanged,
    required this.onSexChanged,
    required this.onDeleteElement,
    required this.cellSize,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.brushShape,
    required this.brushRadius,
    required this.onBrushShapeChanged,
    required this.onBrushRadiusChanged,
    required this.defaultSubstrateId,
    required this.onDefaultSubstrateChanged,
    this.stages = const [],
    this.onElementUpdated,
    this.db,
  });

  final EditorTool currentTool;
  final ValueChanged<EditorTool> onToolChanged;
  final List<Substrate> substrates;
  final List<Nutrient> nutrients;
  final List<Prototype> prototypes;
  final int selectedSubstrateId;
  final int selectedNutrientId;
  final int? selectedPrototypeId;
  final String selectedSex;
  final PlacedElement? selectedElement;
  final ValueChanged<int> onSubstrateChanged;
  final ValueChanged<int> onNutrientChanged;
  final ValueChanged<int?> onPrototypeChanged;
  final ValueChanged<String> onSexChanged;
  final VoidCallback onDeleteElement;
  final double cellSize;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final BrushShape brushShape;
  final int brushRadius;
  final ValueChanged<BrushShape> onBrushShapeChanged;
  final ValueChanged<int> onBrushRadiusChanged;
  final int defaultSubstrateId;
  final ValueChanged<int> onDefaultSubstrateChanged;
  final List<Stage> stages;
  final VoidCallback? onElementUpdated;
  final AppDatabase? db;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerLow,
      child: Column(
        children: [
          // --- Tool selection buttons ---
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _ToolChip(
                  icon: Icons.near_me,
                  label: 'Pointer',
                  active: currentTool == EditorTool.pointer,
                  onTap: () => onToolChanged(EditorTool.pointer),
                ),
                _ToolChip(
                  icon: Icons.brush,
                  label: 'Terrain',
                  active: currentTool == EditorTool.substrateBrush,
                  onTap: () => onToolChanged(EditorTool.substrateBrush),
                ),
                _ToolChip(
                  icon: Icons.water_drop,
                  label: 'Source',
                  active: currentTool == EditorTool.sourcePlace,
                  onTap: () => onToolChanged(EditorTool.sourcePlace),
                ),
                _ToolChip(
                  icon: Icons.egg,
                  label: 'Ovipos.',
                  active: currentTool == EditorTool.ovipositionPlace,
                  onTap: () => onToolChanged(EditorTool.ovipositionPlace),
                ),
                _ToolChip(
                  icon: Icons.pest_control,
                  label: 'Agent',
                  active: currentTool == EditorTool.agentPlace,
                  onTap: () => onToolChanged(EditorTool.agentPlace),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // --- Tool-specific options ---
          Expanded(child: _buildToolOptions(context)),
          // --- Zoom controls ---
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, size: 18),
                  onPressed: onZoomOut,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Zoom out',
                ),
                Expanded(
                  child: Text(
                    '${cellSize.round()}px',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, size: 18),
                  onPressed: onZoomIn,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Zoom in',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolOptions(BuildContext context) {
    // If pointer tool has a selection, show element properties.
    if (currentTool == EditorTool.pointer && selectedElement != null) {
      return _buildSelectionProperties(context);
    }

    return switch (currentTool) {
      EditorTool.pointer => _buildPointerHint(context),
      EditorTool.substrateBrush => _buildSubstratePalette(context),
      EditorTool.sourcePlace => _buildNutrientSelector(context),
      EditorTool.ovipositionPlace => _buildOvipositionHint(context),
      EditorTool.agentPlace => _buildAgentConfig(context),
    };
  }

  Widget _buildPointerHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pointer', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Click an element to select it.\nRight-click for selection.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstratePalette(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Text(
            'Terrain Brush',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        // Brush shape selector.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _BrushShapeBtn(
                icon: Icons.square_outlined,
                tooltip: 'Square',
                active: brushShape == BrushShape.square,
                onTap: () => onBrushShapeChanged(BrushShape.square),
              ),
              _BrushShapeBtn(
                icon: Icons.circle_outlined,
                tooltip: 'Circle',
                active: brushShape == BrushShape.circle,
                onTap: () => onBrushShapeChanged(BrushShape.circle),
              ),
              _BrushShapeBtn(
                icon: Icons.diamond_outlined,
                tooltip: 'Diamond',
                active: brushShape == BrushShape.diamondShape,
                onTap: () => onBrushShapeChanged(BrushShape.diamondShape),
              ),
              _BrushShapeBtn(
                icon: Icons.horizontal_rule,
                tooltip: 'H-Line',
                active: brushShape == BrushShape.hLine,
                onTap: () => onBrushShapeChanged(BrushShape.hLine),
              ),
              _BrushShapeBtn(
                icon: Icons.more_vert,
                tooltip: 'V-Line',
                active: brushShape == BrushShape.vLine,
                onTap: () => onBrushShapeChanged(BrushShape.vLine),
              ),
            ],
          ),
        ),
        // Brush size slider.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text(
                'Size:',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
              Expanded(
                child: Slider(
                  min: 1,
                  max: 15,
                  divisions: 14,
                  value: brushRadius.toDouble(),
                  onChanged: (v) => onBrushRadiusChanged(v.round()),
                ),
              ),
              SizedBox(
                width: 20,
                child: Text(
                  '$brushRadius',
                  style: TextStyle(fontSize: 11, color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Default substrate selector + substrate palette.
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              // Default substrate (replaces "Erase").
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Default:',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: DropdownButton<int>(
                        value: substrates.any((s) => s.id == defaultSubstrateId)
                            ? defaultSubstrateId
                            : null,
                        isExpanded: true,
                        isDense: true,
                        hint: Text(
                          'Select',
                          style: TextStyle(fontSize: 11, color: scheme.outline),
                        ),
                        style: TextStyle(fontSize: 11, color: scheme.onSurface),
                        underline: const SizedBox.shrink(),
                        items: substrates
                            .map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Color(s.color),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        s.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) onDefaultSubstrateChanged(v);
                        },
                      ),
                    ),
                    // Paint with default button.
                    IconButton(
                      icon: Icon(
                        Icons.format_color_fill,
                        size: 16,
                        color: selectedSubstrateId == defaultSubstrateId
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      tooltip: 'Paint with default',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onSubstrateChanged(defaultSubstrateId),
                    ),
                  ],
                ),
              ),
              const Divider(height: 8),
              ...substrates.map(
                (sub) => _PaletteItem(
                  name: sub.name,
                  color: Color(sub.color),
                  selected: selectedSubstrateId == sub.id,
                  onTap: () => onSubstrateChanged(sub.id),
                ),
              ),
              if (substrates.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'No substrates yet.\nUse the Substrates button in the toolbar to create some.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Text(
            'Place Source',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Click map to place:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              ...nutrients.map(
                (nut) => _PaletteItem(
                  name: nut.name,
                  color: Color(nut.color),
                  selected: selectedNutrientId == nut.id,
                  onTap: () => onNutrientChanged(nut.id),
                ),
              ),
              if (nutrients.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'No nutrients yet.\nUse the Nutrients button in the toolbar to create some.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOvipositionHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place Oviposition',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Click on the map to place an oviposition site.\n\n'
            'Use the Pointer tool to select and inspect placed sites.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentConfig(BuildContext context) {
    final filtered = prototypes.where((p) => p.sex == selectedSex).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Text(
            'Place Agent',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'M', label: Text('M')),
              ButtonSegment(value: 'F', label: Text('F')),
            ],
            selected: {selectedSex},
            onSelectionChanged: (s) => onSexChanged(s.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'No ${selectedSex == 'M' ? 'male' : 'female'} prototypes.\nUse the Prototypes button to create some.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              else
                ...filtered.map(
                  (proto) => _PaletteItem(
                    name: proto.name,
                    color: Color(proto.color),
                    selected: selectedPrototypeId == proto.id,
                    onTap: () => onPrototypeChanged(proto.id),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionProperties(BuildContext context) {
    final el = selectedElement!;
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Selected',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Delete',
              onPressed: onDeleteElement,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        switch (el) {
          PlacedSource() => _sourceProps(context, el),
          PlacedOvipositionSite() => _oviProps(context, el),
          PlacedAgent() => _agentProps(context, el),
        },
      ],
    );
  }

  Widget _sourceProps(BuildContext context, PlacedSource s) {
    final nutName =
        nutrients
            .where((n) => n.id == s.nutrientId)
            .map((n) => n.name)
            .firstOrNull ??
        '?';
    return _PropTable(
      rows: [
        ('Type', 'Source'),
        ('Name', s.name),
        ('Pos', '(${s.posX}, ${s.posY})'),
        ('Nutrient', nutName),
        ('Quality', '${s.quality}'),
        ('Level', '${s.level}/${s.maxLevel}'),
        ('Regen', '${s.regenRate}'),
      ],
    );
  }

  Widget _oviProps(BuildContext context, PlacedOvipositionSite o) {
    return _PropTable(
      rows: [
        ('Type', 'Oviposition'),
        ('Name', o.name),
        ('Pos', '(${o.posX}, ${o.posY})'),
        ('Quality', '${o.quality}'),
        ('Capacity', '${o.capacity}'),
      ],
    );
  }

  Widget _agentProps(BuildContext context, PlacedAgent a) {
    if (db == null) {
      return const Text('No database', style: TextStyle(fontSize: 11));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AgentPropertiesEditor(
          key: ValueKey('agent_props_${a.id}'),
          agent: a,
          prototypes: prototypes,
          stages: stages,
          nutrients: nutrients,
          db: db!,
          onUpdated: onElementUpdated,
        ),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text(
              'Edit all details',
              style: TextStyle(fontSize: 11),
            ),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => AgentEditDialog(agent: a)),
              );
              if (result == true) onElementUpdated?.call();
            },
          ),
        ),
      ],
    );
  }
}

// --- Helper widgets ---

class _PropTable extends StatelessWidget {
  const _PropTable({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      r.$1,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(r.$2, style: const TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? scheme.onPrimaryContainer : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrushShapeBtn extends StatelessWidget {
  const _BrushShapeBtn({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: active ? scheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(4),
            border: active ? null : Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Editable properties panel for a placed agent.
/// Allows editing name, age, sex, stage, prototype, and per-nutrient reserves.
class _AgentPropertiesEditor extends StatefulWidget {
  const _AgentPropertiesEditor({
    super.key,
    required this.agent,
    required this.prototypes,
    required this.stages,
    required this.nutrients,
    required this.db,
    this.onUpdated,
  });

  final PlacedAgent agent;
  final List<Prototype> prototypes;
  final List<Stage> stages;
  final List<Nutrient> nutrients;
  final AppDatabase db;
  final VoidCallback? onUpdated;

  @override
  State<_AgentPropertiesEditor> createState() => _AgentPropertiesEditorState();
}

class _AgentPropertiesEditorState extends State<_AgentPropertiesEditor> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  Map<int, double> _reserves = {};
  Future<Map<int, double>>? _reservesFuture;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.agent.name);
    _ageCtrl = TextEditingController(text: '${widget.agent.age}');
    _reservesFuture = _fetchReserves();
  }

  @override
  void didUpdateWidget(covariant _AgentPropertiesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.agent.id != widget.agent.id) {
      _nameCtrl.text = widget.agent.name;
      _ageCtrl.text = '${widget.agent.age}';
      _reservesFuture = _fetchReserves();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<Map<int, double>> _fetchReserves() async {
    final rows = await (widget.db.select(
      widget.db.environmentAgentReserves,
    )..where((t) => t.agentId.equals(widget.agent.id))).get();
    final map = <int, double>{};
    for (final r in rows) {
      map[r.nutrientId] = r.initialLevel;
    }
    _reserves = map;
    return map;
  }

  Future<void> _saveName() async {
    final db = widget.db;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await (db.update(db.environmentAgents)
          ..where((t) => t.id.equals(widget.agent.id)))
        .write(EnvironmentAgentsCompanion(name: Value(name)));
    widget.onUpdated?.call();
  }

  Future<void> _saveAge() async {
    final db = widget.db;
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    await (db.update(db.environmentAgents)
          ..where((t) => t.id.equals(widget.agent.id)))
        .write(EnvironmentAgentsCompanion(age: Value(age)));
    widget.onUpdated?.call();
  }

  Future<void> _saveSex(String sex) async {
    final db = widget.db;
    await (db.update(db.environmentAgents)
          ..where((t) => t.id.equals(widget.agent.id)))
        .write(EnvironmentAgentsCompanion(sex: Value(sex)));
    widget.onUpdated?.call();
  }

  Future<void> _savePrototype(int? protoId) async {
    final db = widget.db;
    await (db.update(db.environmentAgents)
          ..where((t) => t.id.equals(widget.agent.id)))
        .write(EnvironmentAgentsCompanion(prototypeId: Value(protoId)));
    widget.onUpdated?.call();
  }

  Future<void> _saveStage(int? stageId) async {
    final db = widget.db;
    await (db.update(db.environmentAgents)
          ..where((t) => t.id.equals(widget.agent.id)))
        .write(EnvironmentAgentsCompanion(stageId: Value(stageId)));
    widget.onUpdated?.call();
  }

  Future<void> _saveReserve(int nutrientId, double level) async {
    final db = widget.db;
    final existing =
        await (db.select(db.environmentAgentReserves)..where(
              (t) =>
                  t.agentId.equals(widget.agent.id) &
                  t.nutrientId.equals(nutrientId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.environmentAgentReserves)
          .insert(
            EnvironmentAgentReservesCompanion.insert(
              agentId: widget.agent.id,
              nutrientId: nutrientId,
              initialLevel: Value(level),
            ),
          );
    } else {
      await (db.update(db.environmentAgentReserves)
            ..where((t) => t.id.equals(existing.id)))
          .write(EnvironmentAgentReservesCompanion(initialLevel: Value(level)));
    }
    setState(() => _reserves[nutrientId] = level);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = widget.agent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Position (read-only)
        _propRow('Pos', '(${a.posX}, ${a.posY})'),
        const SizedBox(height: 6),

        // Name
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(fontSize: 11),
          decoration: const InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(fontSize: 10),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _saveName(),
        ),
        const SizedBox(height: 6),

        // Age
        TextField(
          controller: _ageCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 11),
          decoration: const InputDecoration(
            labelText: 'Age (ticks)',
            labelStyle: TextStyle(fontSize: 10),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _saveAge(),
        ),
        const SizedBox(height: 6),

        // Sex
        Row(
          children: [
            const Text('Sex:', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'M', label: Text('M')),
                ButtonSegment(value: 'F', label: Text('F')),
              ],
              selected: {a.sex},
              onSelectionChanged: (s) => _saveSex(s.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Prototype
        DropdownButtonFormField<int?>(
          initialValue: widget.prototypes.any((p) => p.id == a.prototypeId)
              ? a.prototypeId
              : null,
          isDense: true,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Prototype',
            labelStyle: TextStyle(fontSize: 10),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(),
          ),
          style: TextStyle(fontSize: 11, color: scheme.onSurface),
          items: [
            const DropdownMenuItem(value: null, child: Text('None')),
            ...widget.prototypes.map(
              (p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.name} (${p.sex})'),
              ),
            ),
          ],
          onChanged: (v) => _savePrototype(v),
        ),
        const SizedBox(height: 6),

        // Stage
        DropdownButtonFormField<int?>(
          initialValue: widget.stages.any((s) => s.id == a.stageId)
              ? a.stageId
              : null,
          isDense: true,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Stage',
            labelStyle: TextStyle(fontSize: 10),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(),
          ),
          style: TextStyle(fontSize: 11, color: scheme.onSurface),
          items: [
            const DropdownMenuItem(value: null, child: Text('None')),
            ...widget.stages.map(
              (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
            ),
          ],
          onChanged: (v) => _saveStage(v),
        ),
        const SizedBox(height: 10),

        // Nutrient reserves
        if (widget.nutrients.isNotEmpty) ...[
          Text(
            'Initial Reserves',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<Map<int, double>>(
            future: _reservesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(),
                );
              }
              final reserves = snapshot.data ?? {};
              return Column(
                children: widget.nutrients.map((n) {
                  final level = reserves[n.id] ?? 50.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(n.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 45,
                          child: Text(
                            n.name,
                            style: const TextStyle(fontSize: 9),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: _ReserveSlider(
                            value: level,
                            onChanged: (v) => _saveReserve(n.id, v),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          child: Text(
                            level.round().toString(),
                            style: const TextStyle(fontSize: 9),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _propRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 10))),
      ],
    );
  }
}

/// Slider for nutrient reserve levels (0–100).
class _ReserveSlider extends StatefulWidget {
  const _ReserveSlider({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_ReserveSlider> createState() => _ReserveSliderState();
}

class _ReserveSliderState extends State<_ReserveSlider> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
  }

  @override
  void didUpdateWidget(covariant _ReserveSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _current = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
      ),
      child: Slider(
        min: 0,
        max: 100,
        value: _current,
        onChanged: (v) => setState(() => _current = v),
        onChangeEnd: widget.onChanged,
      ),
    );
  }
}
