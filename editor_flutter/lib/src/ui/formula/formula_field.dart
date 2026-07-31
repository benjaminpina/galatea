import 'package:flutter/material.dart';

import 'formula_editor_dialog.dart';

/// A text field specialized for formula input. Tapping it opens the
/// full formula editor dialog. Shows the current formula value and a
/// small icon indicating it's formula-editable.
class FormulaField extends StatelessWidget {
  const FormulaField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.title,
  });

  /// Current formula string.
  final String value;

  /// Called when the formula is changed via the editor dialog.
  final ValueChanged<String> onChanged;

  /// Optional label shown above the field.
  final String? label;

  /// Title shown in the formula editor dialog.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _openEditor(context),
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
          suffixIcon: Icon(Icons.functions, size: 16, color: scheme.primary),
        ),
        child: Text(
          value.isEmpty ? '0' : value,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: scheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final result = await showFormulaEditor(
      context,
      initialFormula: value,
      title: title ?? label ?? 'Formula Editor',
    );
    if (result != null) {
      onChanged(result);
    }
  }
}
