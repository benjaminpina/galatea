/// Result of formula validation.
class ValidationResult {
  const ValidationResult.valid() : error = null, position = -1;
  const ValidationResult.error(this.error, [this.position = -1]);

  final String? error;
  final int position;

  bool get isValid => error == null;
}

/// Basic formula syntax validator.
/// Checks: balanced parentheses, valid tokens, known variables/functions.
class FormulaValidator {
  FormulaValidator({
    required this.knownVariables,
    required this.knownFunctions,
  });

  final Set<String> knownVariables;
  final Set<String> knownFunctions;

  /// Validate a formula string. Returns a ValidationResult.
  ValidationResult validate(String formula) {
    if (formula.trim().isEmpty) {
      return const ValidationResult.valid(); // Empty is OK (defaults to 0).
    }

    // Check balanced parentheses.
    int depth = 0;
    for (int i = 0; i < formula.length; i++) {
      if (formula[i] == '(') depth++;
      if (formula[i] == ')') depth--;
      if (depth < 0) {
        return ValidationResult.error('Unmatched closing parenthesis', i);
      }
    }
    if (depth > 0) {
      return ValidationResult.error('Unclosed parenthesis ($depth open)');
    }

    // Tokenize and check identifiers.
    final tokens = _tokenize(formula);
    final unknowns = <String>[];

    for (final token in tokens) {
      if (token.type == _TokenType.identifier) {
        final name = token.value;
        // Check if it's a known variable, function, or boolean literal.
        if (!knownVariables.contains(name) &&
            !knownFunctions.contains(name) &&
            name != 'true' && name != 'false' && name != 'nil') {
          unknowns.add(name);
        }
      }
    }

    if (unknowns.isNotEmpty) {
      return ValidationResult.error(
        'Unknown identifier${unknowns.length > 1 ? 's' : ''}: ${unknowns.join(', ')}',
      );
    }

    return const ValidationResult.valid();
  }

  /// Tokenize a formula into identifiers, numbers, operators, etc.
  List<_Token> _tokenize(String formula) {
    final tokens = <_Token>[];
    int i = 0;

    while (i < formula.length) {
      final ch = formula[i];

      // Skip whitespace.
      if (ch == ' ' || ch == '\t' || ch == '\n') {
        i++;
        continue;
      }

      // Number (integer or float).
      if (_isDigit(ch) || (ch == '.' && i + 1 < formula.length && _isDigit(formula[i + 1]))) {
        final start = i;
        while (i < formula.length && (_isDigit(formula[i]) || formula[i] == '.')) {
          i++;
        }
        tokens.add(_Token(_TokenType.number, formula.substring(start, i)));
        continue;
      }

      // Identifier (variable or function name).
      if (_isAlpha(ch) || ch == '_') {
        final start = i;
        while (i < formula.length && (_isAlphaNum(formula[i]) || formula[i] == '_')) {
          i++;
        }
        tokens.add(_Token(_TokenType.identifier, formula.substring(start, i)));
        continue;
      }

      // Operators and punctuation.
      tokens.add(_Token(_TokenType.operator, ch));
      i++;
    }

    return tokens;
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isAlpha(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95;
  }
  bool _isAlphaNum(String ch) => _isDigit(ch) || _isAlpha(ch);
}

enum _TokenType { identifier, number, operator }

class _Token {
  _Token(this.type, this.value);
  final _TokenType type;
  final String value;
}
