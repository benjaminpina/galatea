import 'package:flutter/material.dart';

import 'editor_state.dart';

/// CustomPainter that renders the full environment:
/// substrate grid (background), nutrient sources, oviposition sites, agents,
/// selection highlight, and hover cursor.
class EnvironmentCanvasPainter extends CustomPainter {
  EnvironmentCanvasPainter({
    required this.grid,
    required this.width,
    required this.height,
    required this.cellSize,
    required this.offset,
    required this.substrateColorMap,
    required this.nutrientColorMap,
    required this.sources,
    required this.oviSites,
    required this.agents,
    required this.selectedElement,
    required this.hoverX,
    required this.hoverY,
    required this.currentTool,
  });

  final List<List<int>> grid;
  final int width;
  final int height;
  final double cellSize;
  final Offset offset;
  final Map<int, Color> substrateColorMap;
  final Map<int, Color> nutrientColorMap;
  final List<PlacedSource> sources;
  final List<PlacedOvipositionSite> oviSites;
  final List<PlacedAgent> agents;
  final PlacedElement? selectedElement;
  final int hoverX;
  final int hoverY;
  final EditorTool currentTool;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSubstrateGrid(canvas, size);
    _paintSources(canvas, size);
    _paintOvipositionSites(canvas, size);
    _paintAgents(canvas, size);
    _paintSelection(canvas);
    _paintHoverCursor(canvas, size);
  }

  void _paintSubstrateGrid(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white10
      ..strokeWidth = 0.5;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final rect = _cellRect(x, y);

        // Cull off-screen cells.
        if (rect.right < 0 ||
            rect.left > size.width ||
            rect.bottom < 0 ||
            rect.top > size.height) {
          continue;
        }

        final subId = grid[y][x];
        paint.color = substrateColorMap[subId] ?? Colors.black;
        canvas.drawRect(rect, paint);

        if (cellSize >= 6) {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }
  }

  void _paintSources(Canvas canvas, Size size) {
    for (final source in sources) {
      final rect = _cellRect(source.posX, source.posY);
      if (!_isVisible(rect, size)) continue;

      final color = nutrientColorMap[source.nutrientId] ?? Colors.cyan;
      final center = rect.center;
      final radius = cellSize * 0.35;

      // Filled circle with border.
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = color;
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, fill);
      canvas.drawCircle(center, radius, stroke);

      // Small "S" label if cell large enough.
      if (cellSize >= 14) {
        _drawLabel(canvas, center, 'S', Colors.white, cellSize * 0.28);
      }
    }
  }

  void _paintOvipositionSites(Canvas canvas, Size size) {
    for (final site in oviSites) {
      final rect = _cellRect(site.posX, site.posY);
      if (!_isVisible(rect, size)) continue;

      final center = rect.center;
      final radius = cellSize * 0.3;

      // Diamond shape for oviposition.
      final path = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius, center.dy)
        ..close();

      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.amber;
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 1.5;

      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);

      if (cellSize >= 14) {
        _drawLabel(canvas, center, 'O', Colors.black87, cellSize * 0.24);
      }
    }
  }

  void _paintAgents(Canvas canvas, Size size) {
    for (final agent in agents) {
      final rect = _cellRect(agent.posX, agent.posY);
      if (!_isVisible(rect, size)) continue;

      final center = rect.center;
      final radius = cellSize * 0.35;

      // Triangle pointing up for agents.
      final isMale = agent.sex == 'M';
      final color = isMale ? Colors.blue : Colors.pinkAccent;

      if (isMale) {
        // Upward triangle.
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius * 0.7)
          ..lineTo(center.dx - radius, center.dy + radius * 0.7)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      } else {
        // Downward triangle.
        final path = Path()
          ..moveTo(center.dx, center.dy + radius)
          ..lineTo(center.dx + radius, center.dy - radius * 0.7)
          ..lineTo(center.dx - radius, center.dy - radius * 0.7)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _paintSelection(Canvas canvas) {
    final sel = selectedElement;
    if (sel == null) return;

    final rect = _cellRect(sel.posX, sel.posY).inflate(2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.yellowAccent
      ..strokeWidth = 2.5;
    canvas.drawRect(rect, paint);
  }

  void _paintHoverCursor(Canvas canvas, Size size) {
    if (hoverX < 0 || hoverX >= width || hoverY < 0 || hoverY >= height) {
      return;
    }

    final rect = _cellRect(hoverX, hoverY);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawRect(rect, paint);
  }

  // --- Helpers ---

  Rect _cellRect(int x, int y) {
    return Rect.fromLTWH(
      offset.dx + x * cellSize,
      offset.dy + y * cellSize,
      cellSize,
      cellSize,
    );
  }

  bool _isVisible(Rect rect, Size size) {
    return rect.right >= 0 &&
        rect.left <= size.width &&
        rect.bottom >= 0 &&
        rect.top <= size.height;
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    double fontSize,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant EnvironmentCanvasPainter old) => true;
}
