import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/database_provider.dart';

/// Visual grid editor for painting substrates onto the environment map.
class MapEditorScreen extends ConsumerStatefulWidget {
  const MapEditorScreen({super.key, required this.environmentId});

  final int environmentId;

  @override
  ConsumerState<MapEditorScreen> createState() => _MapEditorScreenState();
}

class _MapEditorScreenState extends ConsumerState<MapEditorScreen> {
  List<List<int>> _grid = [];
  int _width = 0;
  int _height = 0;
  int _selectedSubstrateId = 1;
  bool _painting = false;
  double _cellSize = 10;
  Offset _offset = Offset.zero;

  // For panning.
  Offset _panStart = Offset.zero;
  Offset _offsetStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    final env = await (db.select(db.environments)
          ..where((t) => t.id.equals(widget.environmentId)))
        .getSingleOrNull();
    if (env == null) return;

    _width = env.width;
    _height = env.height;

    // Initialize grid.
    _grid = List.generate(_height, (_) => List.filled(_width, 0));

    // Load existing map rows.
    final rows = await (db.select(db.substrateMapRows)
          ..where((t) => t.environmentId.equals(widget.environmentId))
          ..orderBy([(t) => OrderingTerm.asc(t.yCoord)]))
        .get();

    for (final row in rows) {
      final y = row.yCoord;
      if (y >= 0 && y < _height) {
        final parts = row.mapData.split(',');
        for (var x = 0; x < parts.length && x < _width; x++) {
          _grid[y][x] = int.tryParse(parts[x].trim()) ?? 0;
        }
      }
    }

    // Calculate cell size to fit.
    _cellSize = 800 / _width.toDouble();
    if (_cellSize < 4) _cellSize = 4;
    if (_cellSize > 20) _cellSize = 20;

    setState(() {});
  }

  Future<void> _saveMap() async {
    final db = ref.read(databaseProvider);
    if (db == null) return;

    await db.batch((batch) {
      // Delete existing rows.
      batch.deleteWhere(
        db.substrateMapRows,
        (t) => t.environmentId.equals(widget.environmentId),
      );

      // Insert new rows.
      for (var y = 0; y < _height; y++) {
        final rowData = _grid[y].join(',');
        batch.insert(
          db.substrateMapRows,
          SubstrateMapRowsCompanion.insert(
            environmentId: widget.environmentId,
            yCoord: y,
            mapData: rowData,
          ),
        );
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map saved'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _paintCell(Offset localPosition) {
    final x = ((localPosition.dx - _offset.dx) / _cellSize).floor();
    final y = ((localPosition.dy - _offset.dy) / _cellSize).floor();

    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      if (_grid[y][x] != _selectedSubstrateId) {
        setState(() {
          _grid[y][x] = _selectedSubstrateId;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final substrates = ref.watch(substratesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Editor (${_width}x$_height)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save map',
            onPressed: _saveMap,
          ),
        ],
      ),
      body: Row(
        children: [
          // Substrate palette sidebar.
          SizedBox(
            width: 180,
            child: substrates.when(
              data: (list) => _buildPalette(list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          const VerticalDivider(width: 1),
          // Map canvas.
          Expanded(child: _buildCanvas()),
        ],
      ),
    );
  }

  Widget _buildPalette(List<Substrate> list) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Brush', style: Theme.of(context).textTheme.titleSmall),
        ),
        // "Eraser" (substrate 0).
        _PaletteItem(
          name: '(None / Erase)',
          color: Colors.black,
          selected: _selectedSubstrateId == 0,
          onTap: () => setState(() => _selectedSubstrateId = 0),
        ),
        ...list.map((sub) => _PaletteItem(
              name: sub.name,
              color: Color(sub.color),
              selected: _selectedSubstrateId == sub.id,
              onTap: () => setState(() => _selectedSubstrateId = sub.id),
            )),
        const Divider(height: 32),
        Text('Zoom', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          min: 4,
          max: 24,
          value: _cellSize,
          onChanged: (v) => setState(() => _cellSize = v),
        ),
      ],
    );
  }

  Widget _buildCanvas() {
    if (_width == 0 || _height == 0) {
      return const Center(child: Text('Loading map...'));
    }

    final substrates = ref.read(substratesProvider).valueOrNull ?? [];
    final colorMap = <int, Color>{0: Colors.black};
    for (final sub in substrates) {
      colorMap[sub.id] = Color(sub.color);
    }

    return GestureDetector(
      onPanStart: (details) {
        if (_isPanMode(details)) {
          _panStart = details.localPosition;
          _offsetStart = _offset;
        } else {
          _painting = true;
          _paintCell(details.localPosition);
        }
      },
      onPanUpdate: (details) {
        if (!_painting) {
          setState(() {
            _offset = _offsetStart + (details.localPosition - _panStart);
          });
        } else {
          _paintCell(details.localPosition);
        }
      },
      onPanEnd: (_) => _painting = false,
      child: ClipRect(
        child: CustomPaint(
          size: Size.infinite,
          painter: _MapPainter(
            grid: _grid,
            width: _width,
            height: _height,
            cellSize: _cellSize,
            offset: _offset,
            colorMap: colorMap,
          ),
        ),
      ),
    );
  }

  bool _isPanMode(DragStartDetails details) {
    // Right-click or middle-click for pan (on desktop, use secondary button).
    // Since GestureDetector doesn't easily differentiate, use Shift key.
    // For simplicity: always paint with left drag. Pan with scroll offset.
    return false;
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
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        dense: true,
        leading: Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
        ),
        title: Text(name, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.grid,
    required this.width,
    required this.height,
    required this.cellSize,
    required this.offset,
    required this.colorMap,
  });

  final List<List<int>> grid;
  final int width;
  final int height;
  final double cellSize;
  final Offset offset;
  final Map<int, Color> colorMap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white10
      ..strokeWidth = 0.5;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final rect = Rect.fromLTWH(
          offset.dx + x * cellSize,
          offset.dy + y * cellSize,
          cellSize,
          cellSize,
        );

        // Skip off-screen cells.
        if (rect.right < 0 || rect.left > size.width ||
            rect.bottom < 0 || rect.top > size.height) {
          continue;
        }

        final subId = grid[y][x];
        paint.color = colorMap[subId] ?? Colors.black;
        canvas.drawRect(rect, paint);

        if (cellSize >= 6) {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
