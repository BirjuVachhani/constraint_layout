// Ported from androidx.constraintlayout.core.GoalRow (upstream pinned in
// UPSTREAM.md).

import 'array_row.dart';
import 'solver_variable.dart';

class GoalRow extends ArrayRow {
  GoalRow(super.cache);

  @override
  void addError(SolverVariable error) {
    super.addError(error);
    // error variables in the goal shouldn't be tracked (we only care if they
    // are in the system rows)
    error.usageInRowCount--;
  }
}
