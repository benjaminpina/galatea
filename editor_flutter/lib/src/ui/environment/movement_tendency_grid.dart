import 'package:flutter/material.dart';

import '../formula/formula_field.dart';
import 'movement_tendencies.dart';

/// A spatial 3×3 editor for movement tendencies. Each of the 8 relative-turn
/// weights is placed in the cell corresponding to its direction, with a
/// forward-facing agent icon in the center. This mirrors the legacy editor's
/// intuitive spatial layout.
///
/// [values] maps turnIndex → formula string. [onChanged] is called with the
/// turnIndex and new formula when a cell is edited. [titlePrefix] is used for
/// the formula editor dialog title.
class MovementTendencyGrid extends StatelessWidget {
  const MovementTendencyGrid({
    super.key,
    required this.values,
    required this.onChanged,
    this.titlePrefix = '',
  });

  final Map<int, String> values;
  final void Function(int turnIndex, String formula) onChanged;
  final String titlePrefix;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep the grid reasonably sized; cap the cell width.
        final maxWidth = constraints.maxWidth.clamp(0.0, 420.0);
        final cellW = maxWidth / 3;

        return Center(
          child: SizedBox(
            width: maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (row) {
                return Row(
                  children: List.generate(3, (col) {
                    return SizedBox(
                      width: cellW,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _buildCell(context, row, col),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    // Center cell (1,1) holds the agent icon.
    if (row == 1 && col == 1) {
      return _AgentIcon();
    }
    final slot = turnSlotAt(row, col);
    if (slot == null) return const SizedBox.shrink();

    final value = values[slot.turnIndex] ?? slot.defaultWeight;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${slot.arrow} ${slot.shortLabel}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FormulaField(
          value: value,
          title: titlePrefix.isEmpty
              ? slot.label
              : '$titlePrefix — ${slot.label}',
          onChanged: (v) => onChanged(slot.turnIndex, v),
        ),
      ],
    );
  }
}

/// Simple forward-facing agent glyph (two circles) drawn in the grid center,
/// matching the canvas rendering style. Points upward = "forward".
class _AgentIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: CustomPaint(
          size: const Size(44, 44),
          painter: _AgentIconPainter(
            scheme: Theme.of(context).colorScheme,
          ),
        ),
      ),
    );
  }
}

class _AgentIconPainter extends CustomPainter {
  _AgentIconPainter({required this.scheme});
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    // Facing up: head above center, body below.
    final bodyColor = scheme.primary;
    final headColor = scheme.tertiary;

    // Body (larger, lower).
    final bodyCenter = Offset(cx, cy + r * 0.2);
    canvas.drawCircle(bodyCenter, r * 0.55, Paint()..color = bodyColor);
    canvas.drawCircle(
      bodyCenter,
      r * 0.55,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Head (smaller, upper = forward).
    final headCenter = Offset(cx, cy - r * 0.4);
    canvas.drawCircle(headCenter, r * 0.38, Paint()..color = headColor);
    canvas.drawCircle(
      headCenter,
      r * 0.38,
      Paint()
        ..color = Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Eyes on the head (looking up).
    final eyeR = r * 0.09;
    final eyeSpread = r * 0.16;
    final eyeY = headCenter.dy - r * 0.12;
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx - eyeSpread, eyeY), eyeR, white);
    canvas.drawCircle(Offset(cx - eyeSpread, eyeY - eyeR * 0.2), eyeR * 0.55, pupil);
    canvas.drawCircle(Offset(cx + eyeSpread, eyeY), eyeR, white);
    canvas.drawCircle(Offset(cx + eyeSpread, eyeY - eyeR * 0.2), eyeR * 0.55, pupil);
  }

  @override
  bool shouldRepaint(covariant _AgentIconPainter oldDelegate) => false;
}
