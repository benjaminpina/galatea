import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';
import 'editor_state.dart';

/// Full-screen dialog for editing all properties of a placed agent.
/// Includes: identity, physiology, reproduction, orientation, and memory.
class AgentEditDialog extends ConsumerStatefulWidget {
  const AgentEditDialog({super.key, required this.agent});
  final PlacedAgent agent;

  @override
  ConsumerState<AgentEditDialog> createState() => _AgentEditDialogState();
}

class _AgentEditDialogState extends ConsumerState<AgentEditDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _cyclesInStageCtrl;
  late TextEditingController _gametesCtrl;
  late TextEditingController _fertilizedEggsCtrl;
  late TextEditingController _storedPacksCtrl;
  late String _sex;
  late int _orientation;
  late bool _virgin;
  int? _prototypeId;
  int? _stageId;

  // Reserves
  final Map<int, double> _reserves = {};
  // Memory
  final Map<String, double> _memory = {};
  final _newMemKeyCtrl = TextEditingController();
  final _newMemValCtrl = TextEditingController();

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final a = widget.agent;
    _nameCtrl = TextEditingController(text: a.name);
    _ageCtrl = TextEditingController(text: '${a.age}');
    _cyclesInStageCtrl = TextEditingController(text: '${a.cyclesInStage}');
    _gametesCtrl = TextEditingController(text: '${a.gametes}');
    _fertilizedEggsCtrl = TextEditingController(text: '${a.fertilizedEggs}');
    _storedPacksCtrl = TextEditingController(text: '${a.storedSpermPacks}');
    _sex = a.sex;
    _orientation = a.orientation;
    _virgin = a.virgin;
    _prototypeId = a.prototypeId;
    _stageId = a.stageId;
    _loadExtras();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _cyclesInStageCtrl.dispose();
    _gametesCtrl.dispose();
    _fertilizedEggsCtrl.dispose();
    _storedPacksCtrl.dispose();
    _newMemKeyCtrl.dispose();
    _newMemValCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExtras() async {
    final db = ref.read(databaseProvider);
    if (db == null) {
      setState(() => _loaded = true);
      return;
    }
    // Load reserves
    final reserveRows = await (db.select(
      db.environmentAgentReserves,
    )..where((t) => t.agentId.equals(widget.agent.id))).get();
    for (final r in reserveRows) {
      _reserves[r.nutrientId] = r.initialLevel;
    }
    // Load memory
    final memRows = await (db.select(
      db.environmentAgentMemory,
    )..where((t) => t.agentId.equals(widget.agent.id))).get();
    for (final m in memRows) {
      _memory[m.memoryKey] = m.value;
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    // Save main agent fields
    await (db.update(
      db.environmentAgents,
    )..where((t) => t.id.equals(widget.agent.id))).write(
      EnvironmentAgentsCompanion(
        name: Value(_nameCtrl.text.trim()),
        age: Value(int.tryParse(_ageCtrl.text.trim()) ?? 0),
        sex: Value(_sex),
        orientation: Value(_orientation),
        cyclesInStage: Value(int.tryParse(_cyclesInStageCtrl.text.trim()) ?? 0),
        gametes: Value(int.tryParse(_gametesCtrl.text.trim()) ?? 0),
        fertilizedEggs: Value(
          int.tryParse(_fertilizedEggsCtrl.text.trim()) ?? 0,
        ),
        storedSpermPacks: Value(
          int.tryParse(_storedPacksCtrl.text.trim()) ?? 0,
        ),
        virgin: Value(_virgin),
        prototypeId: Value(_prototypeId),
        stageId: Value(_stageId),
      ),
    );

    // Save reserves (upsert each)
    for (final entry in _reserves.entries) {
      final existing =
          await (db.select(db.environmentAgentReserves)..where(
                (t) =>
                    t.agentId.equals(widget.agent.id) &
                    t.nutrientId.equals(entry.key),
              ))
              .getSingleOrNull();
      if (existing == null) {
        await db
            .into(db.environmentAgentReserves)
            .insert(
              EnvironmentAgentReservesCompanion.insert(
                agentId: widget.agent.id,
                nutrientId: entry.key,
                initialLevel: Value(entry.value),
              ),
            );
      } else {
        await (db.update(
          db.environmentAgentReserves,
        )..where((t) => t.id.equals(existing.id))).write(
          EnvironmentAgentReservesCompanion(initialLevel: Value(entry.value)),
        );
      }
    }

    // Save memory (delete all + re-insert)
    await (db.delete(
      db.environmentAgentMemory,
    )..where((t) => t.agentId.equals(widget.agent.id))).go();
    for (final entry in _memory.entries) {
      await db
          .into(db.environmentAgentMemory)
          .insert(
            EnvironmentAgentMemoryCompanion.insert(
              agentId: widget.agent.id,
              memoryKey: entry.key,
              value: Value(entry.value),
            ),
          );
    }

    if (mounted) Navigator.pop(context, true);
  }

  static const _dirLabels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

  @override
  Widget build(BuildContext context) {
    final nutrients = ref.watch(nutrientsProvider).valueOrNull ?? [];
    final prototypes = ref.watch(prototypesProvider).valueOrNull ?? [];
    final stages = ref.watch(stagesProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Agent: ${widget.agent.name}'),
        actions: [
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // === Identity ===
                _sectionTitle('Identity'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Sex:'),
                    const SizedBox(width: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'M', label: Text('Male')),
                        ButtonSegment(value: 'F', label: Text('Female')),
                      ],
                      selected: {_sex},
                      onSelectionChanged: (s) => setState(() => _sex = s.first),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue:
                            prototypes.any((p) => p.id == _prototypeId)
                            ? _prototypeId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Prototype',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('None'),
                          ),
                          ...prototypes.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} (${p.sex})'),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _prototypeId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: stages.any((s) => s.id == _stageId)
                            ? _stageId
                            : null,
                        decoration: const InputDecoration(labelText: 'Stage'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('None'),
                          ),
                          ...stages.map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _stageId = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // === Time / Age ===
                _sectionTitle('Time'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age (ticks)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _cyclesInStageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cycles in current stage',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // === Orientation ===
                _sectionTitle('Orientation'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(8, (i) {
                    final dir = i + 1;
                    return ChoiceChip(
                      label: Text(_dirLabels[i]),
                      selected: _orientation == dir,
                      onSelected: (_) => setState(() => _orientation = dir),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // === Reproduction ===
                _sectionTitle('Reproduction'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gametesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Gametes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _fertilizedEggsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fertilized eggs',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _storedPacksCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stored sperm packs',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Virgin'),
                  subtitle: const Text('Has never mated'),
                  value: _virgin,
                  onChanged: (v) => setState(() => _virgin = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // === Reserves ===
                _sectionTitle('Nutrient Reserves'),
                const SizedBox(height: 8),
                if (nutrients.isEmpty)
                  const Text(
                    'No nutrients defined.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...nutrients.map((n) {
                    final level = _reserves[n.id] ?? 50.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(n.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              n.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: level,
                              onChanged: (v) =>
                                  setState(() => _reserves[n.id] = v),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              level.round().toString(),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 16),

                // === Memory ===
                _sectionTitle('Memory'),
                const SizedBox(height: 8),
                if (_memory.isEmpty)
                  const Text(
                    'No memory entries.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                else
                  ..._memory.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: TextEditingController(
                                text: e.value.toString(),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (v) {
                                final val = double.tryParse(v) ?? 0;
                                setState(() => _memory[e.key] = val);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () =>
                                setState(() => _memory.remove(e.key)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Add memory entry
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newMemKeyCtrl,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Key (e.g. lastPerGrass)',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _newMemValCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: '0',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addMemoryEntry,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void _addMemoryEntry() {
    final key = _newMemKeyCtrl.text.trim();
    if (key.isEmpty) return;
    final val = double.tryParse(_newMemValCtrl.text.trim()) ?? 0;
    setState(() {
      _memory[key] = val;
      _newMemKeyCtrl.clear();
      _newMemValCtrl.clear();
    });
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}
