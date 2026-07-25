// Ported from androidx.constraintlayout.core.Cache (upstream pinned in
// UPSTREAM.md).

import 'array_row.dart';
import 'pools.dart';
import 'solver_variable.dart';

/// Cache for common solver objects.
class Cache {
  final SimplePool<ArrayRow> mOptimizedArrayRowPool = SimplePool(256);
  final SimplePool<ArrayRow> mArrayRowPool = SimplePool(256);
  final SimplePool<SolverVariable> mSolverVariablePool = SimplePool(256);
  List<SolverVariable?> mIndexedVariables = List<SolverVariable?>.filled(32, null);
}
