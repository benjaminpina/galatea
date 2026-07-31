import '../../database/database.dart';

/// A single variable available in formulas.
class FormulaVariable {
  const FormulaVariable(this.name, this.description);
  final String name;
  final String description;
}

/// A category of variables shown as a tab in the formula editor.
class VariableCategory {
  const VariableCategory(this.label, this.icon, this.variables);
  final String label;
  final String icon; // icon name for reference
  final List<FormulaVariable> variables;
}

/// Checks if a locus/character has genetic parameters configured
/// (i.e., it's not purely a morphological constant).
bool _hasGenetics(LociData l) {
  return l.dominantValue != 0 ||
      l.recessiveValue != 0 ||
      l.mutationRateDom != 0 ||
      l.mutationRateRec != 0;
}

/// Builds the complete list of available formula variables from the current
/// project data. Organized by category matching the legacy editor's tabs.
List<VariableCategory> buildFormulaVariables({
  required List<Nutrient> nutrients,
  required List<LociData> loci,
  required List<Substrate> substrates,
  required List<Stage> stages,
  required List<Prototype> prototypes,
  required List<CustomFunction> customFunctions,
}) {
  final males = prototypes.where((p) => p.sex == 'M').toList();
  final females = prototypes.where((p) => p.sex == 'F').toList();

  return [
    // --- Time ---
    VariableCategory('Time', 'schedule', [
      const FormulaVariable('Cycles', 'Total simulation ticks elapsed'),
      const FormulaVariable('Age', 'Agent age in ticks'),
      const FormulaVariable(
        'CyclesInCurrentLifeStage',
        'Ticks in current stage',
      ),
      const FormulaVariable('CyclesOnSubstrate', 'Ticks on current substrate'),
      const FormulaVariable(
        'CyclesInCurrentInteraction',
        'Ticks in current interaction',
      ),
      const FormulaVariable(
        'NumLifeStage',
        'Current life stage number (1-based)',
      ),
      const FormulaVariable('IsAdult', 'True if agent is adult'),
      const FormulaVariable('IsMale', 'True if agent is male'),
      const FormulaVariable('IsFemale', 'True if agent is female'),
    ]),

    // --- Physiology (reserves) ---
    VariableCategory('Physiology', 'monitor_heart', [
      ...nutrients.map(
        (n) => FormulaVariable(
          'Reserve${n.name}',
          'Current ${n.name} reserve level',
        ),
      ),
    ]),

    // --- Genetics (only for characters with genetic parameters configured) ---
    VariableCategory('Genetics', 'biotech', [
      ...loci
          .where((l) => l.isContinuous && _hasGenetics(l))
          .map(
            (l) => FormulaVariable(
              'CL_${l.name}',
              'Expressed continuous locus: ${l.name}',
            ),
          ),
      ...loci
          .where((l) => !l.isContinuous && _hasGenetics(l))
          .map(
            (l) => FormulaVariable(
              'DL_${l.name}',
              'Expressed discrete locus: ${l.name}',
            ),
          ),
      if (loci.every((l) => !_hasGenetics(l)))
        const FormulaVariable(
          '—',
          'No characters have genetic parameters configured',
        ),
    ]),

    // --- Morphology (all characters, as fixed adult traits) ---
    VariableCategory('Morphology', 'straighten', [
      ...loci.map(
        (l) => FormulaVariable(l.name, 'Morphological value: ${l.name}'),
      ),
    ]),

    // --- Reproduction ---
    const VariableCategory('Reproduction', 'child_care', [
      FormulaVariable('QuantityGametes', 'Available gametes'),
      FormulaVariable('QuantityFertilizedEggs', 'Fertilized eggs count'),
      FormulaVariable('QuantitySpermPacksStored', 'Stored sperm packs'),
      FormulaVariable('QuantityCarriedEggs', 'Eggs being carried'),
      FormulaVariable('Virginity', 'True if never mated (female)'),
    ]),

    // --- Memory ---
    VariableCategory('Memory', 'psychology', [
      // Substrate memory
      ...substrates.map(
        (s) => FormulaVariable(
          'MemoryLastPer${s.name}',
          'Last tick perceived ${s.name}',
        ),
      ),
      ...substrates.map(
        (s) => FormulaVariable(
          'MemoryNumPer${s.name}',
          'Times perceived ${s.name}',
        ),
      ),
      // Source memory
      ...nutrients.map(
        (n) => FormulaVariable(
          'MemoryLastPerSource${n.name}',
          'Last tick perceived ${n.name} source',
        ),
      ),
      ...nutrients.map(
        (n) => FormulaVariable(
          'MemoryNumPerSource${n.name}',
          'Times perceived ${n.name} source',
        ),
      ),
      // Agent memory (stages + prototypes)
      ...stages.map(
        (s) => FormulaVariable(
          'MemoryLastPer${s.name}',
          'Last tick perceived ${s.name}',
        ),
      ),
      ...males.map(
        (p) => FormulaVariable(
          'MemoryLastPer${p.name}',
          'Last tick perceived ${p.name}',
        ),
      ),
      ...females.map(
        (p) => FormulaVariable(
          'MemoryLastPer${p.name}',
          'Last tick perceived ${p.name}',
        ),
      ),
      // Behavior memory
      const FormulaVariable('MemoryLastMove', 'Last tick moved'),
      const FormulaVariable('MemoryLastRest', 'Last tick rested'),
      const FormulaVariable('MemoryNumMove', 'Times moved'),
      const FormulaVariable('MemoryNumRest', 'Times rested'),
    ]),

    // --- Contender ---
    VariableCategory('Contender', 'groups', [
      const FormulaVariable('ContenderAge', 'Opponent age'),
      const FormulaVariable('ContenderIsMale', 'Opponent is male'),
      const FormulaVariable('ContenderIsFemale', 'Opponent is female'),
      ...loci.map(
        (l) => FormulaVariable(
          'Contender_${l.name}',
          'Opponent morphology: ${l.name}',
        ),
      ),
      ...loci
          .where((l) => l.isContinuous && _hasGenetics(l))
          .map(
            (l) => FormulaVariable(
              'ContenderCL_${l.name}',
              'Opponent genetic expression: ${l.name}',
            ),
          ),
    ]),

    // --- Dynamic Element ---
    const VariableCategory('Resource', 'water_drop', [
      FormulaVariable('DynamicElementLevel', 'Current resource level'),
      FormulaVariable('DynamicElementQuality', 'Resource quality'),
    ]),
  ];
}

/// Built-in functions available in the formula engine.
class BuiltInFunction {
  const BuiltInFunction(this.name, this.signature, this.description);
  final String name;
  final String signature;
  final String description;
}

const builtInFunctions = [
  // Random / Stochastic
  BuiltInFunction('Random', 'Random()', 'Uniform random [0, 1)'),
  BuiltInFunction('RandG', 'RandG(mean, stddev)', 'Gaussian random'),
  BuiltInFunction('Dice', 'Dice(faces)', 'Random integer 1..faces'),
  BuiltInFunction('RandInt', 'RandInt(min, max)', 'Random integer [min, max]'),
  BuiltInFunction('Bernoulli', 'Bernoulli(p)', '1 with probability p, else 0'),
  // Math
  BuiltInFunction('Max', 'Max(a, b)', 'Larger of two values'),
  BuiltInFunction('Min', 'Min(a, b)', 'Smaller of two values'),
  BuiltInFunction('Abs', 'Abs(x)', 'Absolute value'),
  BuiltInFunction('Sqrt', 'Sqrt(x)', 'Square root'),
  BuiltInFunction('Pow', 'Pow(base, exp)', 'Power'),
  BuiltInFunction('Log', 'Log(x)', 'Natural logarithm'),
  BuiltInFunction('Log10', 'Log10(x)', 'Base-10 logarithm'),
  BuiltInFunction('Round', 'Round(x)', 'Round to nearest integer'),
  BuiltInFunction('Floor', 'Floor(x)', 'Largest integer <= x'),
  BuiltInFunction('Ceil', 'Ceil(x)', 'Smallest integer >= x'),
  // Clamping / Interpolation
  BuiltInFunction('Clamp', 'Clamp(x, min, max)', 'Constrain to range'),
  BuiltInFunction(
    'Lerp',
    'Lerp(a, b, t)',
    'Linear interpolation (t: 0→a, 1→b)',
  ),
  // Activation / Threshold
  BuiltInFunction('Sigmoid', 'Sigmoid(x, k, x0)', 'Logistic sigmoid curve'),
  BuiltInFunction('Step', 'Step(x, threshold)', '0 if x<threshold, else 1'),
  // Conditional
  BuiltInFunction('If', 'If(cond, trueVal, falseVal)', 'Conditional value'),
];

/// Operators available for quick insertion.
class FormulaOperator {
  const FormulaOperator(this.symbol, this.label);
  final String symbol;
  final String label;
}

const formulaOperators = [
  FormulaOperator('+', 'Add'),
  FormulaOperator('-', 'Subtract'),
  FormulaOperator('*', 'Multiply'),
  FormulaOperator('/', 'Divide'),
  FormulaOperator('%', 'Modulo'),
  FormulaOperator('**', 'Power'),
  FormulaOperator('(', '('),
  FormulaOperator(')', ')'),
  FormulaOperator('==', 'Equal'),
  FormulaOperator('!=', 'Not equal'),
  FormulaOperator('>', 'Greater'),
  FormulaOperator('<', 'Less'),
  FormulaOperator('>=', '>='),
  FormulaOperator('<=', '<='),
  FormulaOperator('&&', 'AND'),
  FormulaOperator('||', 'OR'),
  FormulaOperator('!', 'NOT'),
  FormulaOperator('? :', 'Ternary'),
];
