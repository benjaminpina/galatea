import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import 'formula_variables.dart';
import 'formula_validator.dart';

/// Opens the formula editor dialog and returns the edited formula string,
/// or null if cancelled.
Future<String?> showFormulaEditor(
  BuildContext context, {
  required String initialFormula,
  String title = 'Formula Editor',
}) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) =>
        _FormulaEditorDialog(initialFormula: initialFormula, title: title),
  );
}

class _FormulaEditorDialog extends ConsumerStatefulWidget {
  const _FormulaEditorDialog({
    required this.initialFormula,
    required this.title,
  });

  final String initialFormula;
  final String title;

  @override
  ConsumerState<_FormulaEditorDialog> createState() =>
      _FormulaEditorDialogState();
}

class _FormulaEditorDialogState extends ConsumerState<_FormulaEditorDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _formulaCtrl;
  final FocusNode _formulaFocus = FocusNode();
  final LayerLink _layerLink = LayerLink();
  TabController? _tabCtrl;
  List<VariableCategory> _categories = [];
  FormulaValidator _validator = FormulaValidator(
    knownVariables: {},
    knownFunctions: {},
  );
  ValidationResult _validation = const ValidationResult.valid();
  List<CustomFunction> _customFunctions = [];
  bool _loaded = false;

  // Autocomplete state.
  List<_AutocompleteEntry> _allSymbols = [];
  List<_AutocompleteEntry> _suggestions = [];
  OverlayEntry? _overlayEntry;
  int _selectedSuggestion = 0;

  @override
  void initState() {
    super.initState();
    _formulaCtrl = TextEditingController(text: widget.initialFormula);
    _formulaCtrl.addListener(_onFormulaChanged);
    _formulaFocus.addListener(_onFocusChanged);
    _loadData();
  }

  @override
  void dispose() {
    _hideOverlay();
    _formulaCtrl.removeListener(_onFormulaChanged);
    _formulaCtrl.dispose();
    _formulaFocus.dispose();
    _tabCtrl?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final nutrients = ref.read(nutrientsProvider).valueOrNull ?? [];
    final loci = ref.read(lociProvider).valueOrNull ?? [];
    final substrates = ref.read(substratesProvider).valueOrNull ?? [];
    final stages = ref.read(stagesProvider).valueOrNull ?? [];
    final prototypes = ref.read(prototypesProvider).valueOrNull ?? [];

    // Load custom functions from DB.
    final db = ref.read(databaseProvider);
    if (db != null) {
      _customFunctions = await db.select(db.customFunctions).get();
    }

    _categories = buildFormulaVariables(
      nutrients: nutrients,
      loci: loci,
      characters: ref.read(charactersProvider).valueOrNull ?? [],
      substrates: substrates,
      stages: stages,
      prototypes: prototypes,
      customFunctions: _customFunctions,
    );

    // Build validator known sets.
    final knownVars = <String>{};
    for (final cat in _categories) {
      for (final v in cat.variables) {
        knownVars.add(v.name);
      }
    }
    final knownFuncs = <String>{};
    for (final f in builtInFunctions) {
      knownFuncs.add(f.name);
    }
    for (final cf in _customFunctions) {
      knownFuncs.add(cf.name);
    }

    _validator = FormulaValidator(
      knownVariables: knownVars,
      knownFunctions: knownFuncs,
    );

    // Build autocomplete symbols list.
    _allSymbols = [
      for (final cat in _categories)
        for (final v in cat.variables)
          if (v.name != '—')
            _AutocompleteEntry(
              name: v.name,
              detail: v.description,
              isFunction: false,
            ),
      for (final f in builtInFunctions)
        _AutocompleteEntry(
          name: f.name,
          detail: f.description,
          isFunction: true,
          insertText: '${f.name}(',
        ),
      for (final cf in _customFunctions)
        _AutocompleteEntry(
          name: cf.name,
          detail: cf.description.isEmpty ? cf.body : cf.description,
          isFunction: true,
          insertText: '${cf.name}(',
        ),
    ];

    if (!mounted) return;
    _tabCtrl = TabController(length: _categories.length + 1, vsync: this);
    _loaded = true;
    _onFormulaChanged();
    setState(() {});
  }

  void _onFormulaChanged() {
    setState(() {
      _validation = _validator.validate(_formulaCtrl.text);
    });
    _updateAutocomplete();
  }

  void _onFocusChanged() {
    if (!_formulaFocus.hasFocus) {
      _hideOverlay();
    }
  }

  /// Extract the identifier prefix being typed at the cursor position.
  String _currentPrefix() {
    final text = _formulaCtrl.text;
    final cursor = _formulaCtrl.selection.baseOffset.clamp(0, text.length);
    // Walk backward from cursor to find start of identifier.
    int start = cursor;
    while (start > 0) {
      final ch = text[start - 1];
      if (_isIdentChar(ch)) {
        start--;
      } else {
        break;
      }
    }
    if (start == cursor) return '';
    return text.substring(start, cursor);
  }

  bool _isIdentChar(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || // A-Z
        (c >= 97 && c <= 122) || // a-z
        (c >= 48 && c <= 57) || // 0-9
        c == 95; // _
  }

  void _updateAutocomplete() {
    final prefix = _currentPrefix();
    if (prefix.length < 2) {
      _hideOverlay();
      return;
    }

    final lower = prefix.toLowerCase();
    final matches = _allSymbols
        .where((s) => s.name.toLowerCase().startsWith(lower))
        .take(8)
        .toList();

    if (matches.isEmpty) {
      _hideOverlay();
      return;
    }

    _suggestions = matches;
    _selectedSuggestion = 0;
    _showOverlay();
  }

  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _AutocompletePopup(
          link: _layerLink,
          suggestions: _suggestions,
          selectedIndex: _selectedSuggestion,
          onSelect: _acceptSuggestion,
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _acceptSuggestion(_AutocompleteEntry entry) {
    final prefix = _currentPrefix();
    final text = _formulaCtrl.text;
    final cursor = _formulaCtrl.selection.baseOffset.clamp(0, text.length);
    final start = cursor - prefix.length;
    final insertText = entry.insertText ?? entry.name;
    final newText =
        text.substring(0, start) + insertText + text.substring(cursor);
    _formulaCtrl.text = newText;
    _formulaCtrl.selection = TextSelection.collapsed(
      offset: start + insertText.length,
    );
    _hideOverlay();
  }

  void _insertText(String text) {
    final sel = _formulaCtrl.selection;
    final current = _formulaCtrl.text;
    final before = current.substring(
      0,
      sel.baseOffset.clamp(0, current.length),
    );
    final after = current.substring(sel.extentOffset.clamp(0, current.length));
    final newText = before + text + after;
    _formulaCtrl.text = newText;
    _formulaCtrl.selection = TextSelection.collapsed(
      offset: before.length + text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 550),
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
              child: Row(
                children: [
                  Icon(Icons.functions, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // --- Formula field ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  controller: _formulaCtrl,
                  focusNode: _formulaFocus,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixIcon: _validation.isValid
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        : const Icon(
                            Icons.error,
                            color: Colors.orange,
                            size: 20,
                          ),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
            ),

            // Validation message.
            if (!_validation.isValid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _validation.error!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade300,
                    ),
                  ),
                ),
              ),

            // --- Operator buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: formulaOperators
                    .map(
                      (op) => _OpButton(
                        label: op.symbol,
                        tooltip: op.label,
                        onTap: () => _insertText(' ${op.symbol} '),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(height: 1),

            // --- Tabs: variable categories + Functions ---
            if (_loaded && _tabCtrl != null)
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(fontSize: 11),
                tabs: [
                  ..._categories.map((c) => Tab(text: c.label)),
                  const Tab(text: 'Functions'),
                ],
              ),

            // --- Tab content ---
            Expanded(
              child: !_loaded
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabCtrl,
                      children: [
                        ..._categories.map((cat) => _buildVariableList(cat)),
                        _buildFunctionList(),
                      ],
                    ),
            ),

            // --- Action buttons ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => _formulaCtrl.clear(),
                    child: const Text('Clear'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _formulaCtrl.text),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableList(VariableCategory cat) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: cat.variables.length,
      itemBuilder: (context, index) {
        final v = cat.variables[index];
        return _VariableTile(
          name: v.name,
          description: v.description,
          onTap: () => _insertText(v.name),
        );
      },
    );
  }

  Widget _buildFunctionList() {
    final allFuncs = [
      ...builtInFunctions.map(
        (f) => (f.name, f.signature, f.description, false),
      ),
      ..._customFunctions.map((cf) {
        final sig = '${cf.name}(${cf.params})';
        return (
          cf.name,
          sig,
          cf.description.isEmpty ? cf.body : cf.description,
          true,
        );
      }),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: allFuncs.length,
      itemBuilder: (context, index) {
        final (name, sig, desc, isCustom) = allFuncs[index];
        return _FunctionTile(
          signature: sig,
          description: desc,
          isCustom: isCustom,
          onTap: () => _insertText('$name('),
        );
      },
    );
  }
}

// --- Widgets ---

class _OpButton extends StatelessWidget {
  const _OpButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}

class _VariableTile extends StatelessWidget {
  const _VariableTile({
    required this.name,
    required this.description,
    required this.onTap,
  });
  final String name;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile({
    required this.signature,
    required this.description,
    required this.isCustom,
    required this.onTap,
  });
  final String signature;
  final String description;
  final bool isCustom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            if (isCustom)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.person,
                  size: 12,
                  color: Colors.amber.shade300,
                ),
              ),
            Expanded(
              flex: 2,
              child: Text(
                signature,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Autocomplete ---

class _AutocompleteEntry {
  const _AutocompleteEntry({
    required this.name,
    required this.detail,
    required this.isFunction,
    this.insertText,
  });

  final String name;
  final String detail;
  final bool isFunction;

  /// If provided, this text is inserted instead of [name].
  final String? insertText;
}

class _AutocompletePopup extends StatelessWidget {
  const _AutocompletePopup({
    required this.link,
    required this.suggestions,
    required this.selectedIndex,
    required this.onSelect,
  });

  final LayerLink link;
  final List<_AutocompleteEntry> suggestions;
  final int selectedIndex;
  final ValueChanged<_AutocompleteEntry> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned(
      width: 320,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0, 48),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: scheme.surfaceContainer,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final entry = suggestions[index];
                final selected = index == selectedIndex;
                return InkWell(
                  onTap: () => onSelect(entry),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: selected
                        ? scheme.primaryContainer.withValues(alpha: 0.3)
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          entry.isFunction
                              ? Icons.functions
                              : Icons.data_object,
                          size: 14,
                          color: entry.isFunction
                              ? Colors.amber.shade400
                              : scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (entry.detail.isNotEmpty)
                                Text(
                                  entry.detail,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
