// Ported from androidx.constraintlayout.core.widgets.Helper

import 'constraint_widget.dart';
import 'constraint_widget_container.dart';

/// Interface to virtual objects (helpers) such as Barrier.
abstract class Helper {
  void updateConstraints(ConstraintWidgetContainer container);
  void add(ConstraintWidget widget);
  void removeAllIds();
}
