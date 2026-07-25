# Test porting guide (Java JUnit -> Dart test)

Convert Android ConstraintLayout `core` tests to Dart tests for `constraint_engine`.
The engine resolves via the dependency graph only (no Cassowary yet), but the asserted
coordinates are engine-agnostic golden values, so they must match.

Source tests live at:
`/Users/birjuvachhani/Documents/Projects/constraint_layout/inspo/constraintlayout/constraintlayout/core/src/test/java/androidx/constraintlayout/core/`

Engine package under test: import `package:constraint_engine/constraint_engine.dart`.
Test framework: `package:test/test.dart`.

## Constructors (Dart has no overloading, use named constructors)
- `new ConstraintWidgetContainer(0,0,W,H)` -> `ConstraintWidgetContainer.rect(0,0,W,H)`
- `new ConstraintWidgetContainer(W,H)` -> `ConstraintWidgetContainer.size(W,H)`
- `new ConstraintWidgetContainer("name",W,H)` -> `ConstraintWidgetContainer.sizeNamed("name",W,H)`
- `new ConstraintWidget(W,H)` -> `ConstraintWidget.size(W,H)`
- `new ConstraintWidget(x,y,W,H)` -> `ConstraintWidget.rect(x,y,W,H)`
- `new ConstraintWidget("name",W,H)` -> `ConstraintWidget.sizeNamed("name",W,H)`
- `new ConstraintWidget("name")` -> `ConstraintWidget.named("name")`
- `new ConstraintWidget()` -> `ConstraintWidget()`
- `new Guideline()` -> `Guideline()`;  `new Barrier()` -> `Barrier()`

## Enums / constants
- `ConstraintAnchor.Type.LEFT|RIGHT|TOP|BOTTOM|BASELINE|CENTER|CENTER_X|CENTER_Y`
  -> `ConstraintAnchorType.left|right|top|bottom|baseline|center|centerX|centerY`
- `ConstraintWidget.DimensionBehaviour.FIXED|WRAP_CONTENT|MATCH_CONSTRAINT|MATCH_PARENT`
  -> `DimensionBehaviour.fixed|wrapContent|matchConstraint|matchParent`
- `ConstraintWidget.MATCH_CONSTRAINT_SPREAD|WRAP|PERCENT|RATIO` -> unchanged (`ConstraintWidget.MATCH_CONSTRAINT_SPREAD` ...)
- `ConstraintWidget.CHAIN_SPREAD|CHAIN_SPREAD_INSIDE|CHAIN_PACKED` -> unchanged
- `ConstraintWidget.GONE|VISIBLE|INVISIBLE|HORIZONTAL|VERTICAL|UNKNOWN` -> unchanged
- `ConstraintWidget.ANCHOR_LEFT` etc -> unchanged
- `Guideline.VERTICAL|HORIZONTAL` -> `Guideline.vertical|horizontal`
- `Barrier.LEFT|RIGHT|TOP|BOTTOM` -> `Barrier.left|right|top|bottom`
- `Optimizer.OPTIMIZATION_STANDARD|NONE|GRAPH` -> unchanged
- `BasicMeasure.EXACTLY|AT_MOST|UNSPECIFIED|WRAP_CONTENT|MATCH_PARENT|FIXED` -> unchanged
- `Measure.SELF_DIMENSIONS|TRY_GIVEN_DIMENSIONS|USE_GIVEN_DIMENSIONS` -> unchanged
- float literals: `0.5f` -> `0.5`, `1f` -> `1.0`, `0.2f` -> `0.2`

## Methods
- `widget.connect(Type.X, target, Type.Y, margin)` -> unchanged: `widget.connect(ConstraintAnchorType.x, target, ConstraintAnchorType.y, margin)`
- `widget.connect(fromAnchor, toAnchor, margin)` (anchor,anchor,margin overload) -> `widget.connectAnchors(fromAnchor, toAnchor, margin)`
- `widget.setDimensionRatio("H,16:9")` -> `widget.setDimensionRatioString("H,16:9")`
- `widget.setDimensionRatio(ratioFloat, side)` -> `widget.setDimensionRatio(ratioDouble, side)`
- `guideline.setGuidePercent(0.5f)` -> `guideline.setGuidePercent(0.5)`
- `guideline.setGuidePercent(intValue)` -> `guideline.setGuidePercentInt(intValue)`
- `root.add(a); root.add(b);` -> unchanged (or `root.addAll([a, b])`)
- `root.setMeasurer(sMeasurer)` -> unchanged
- `root.measure(opt, EXACTLY, w, EXACTLY, h, 0,0,0,0)` -> `root.measure(opt, BasicMeasure.EXACTLY, w, BasicMeasure.EXACTLY, h, 0, 0, 0, 0)`
- `root.updateHierarchy()` -> unchanged
- getters `getWidth/getHeight/getLeft/getTop/getRight/getBottom/getX/getY/getDebugName/getBaselineDistance` -> unchanged
- `getGuidelineAnchor()`/no-arg guideline `getAnchor()` -> `guideline.getGuidelineAnchor()`

## Measurer (anonymous class -> Dart class)
```java
static BasicMeasure.Measurer sMeasurer = new BasicMeasure.Measurer() {
  @Override public void measure(ConstraintWidget widget, BasicMeasure.Measure measure) { ... }
  @Override public void didMeasures() {}
};
```
becomes a top-level class:
```dart
class _Measurer implements Measurer {
  @override
  void measure(ConstraintWidget widget, Measure measure) {
    final horizontalBehavior = measure.horizontalBehavior;
    final verticalBehavior = measure.verticalBehavior;
    final horizontalDimension = measure.horizontalDimension;
    final verticalDimension = measure.verticalDimension;
    // ... same body, using DimensionBehaviour.fixed etc ...
    widget.setMeasureRequested(false);
  }
  @override
  void didMeasures() {}
}
final _Measurer sMeasurer = _Measurer();
```

## Assertions
- `assertEquals(actual, expected)` -> `expect(actual, expected)`  (note: Java arg order is (expected, actual) in the JUnit signature but these tests usually pass the COMPUTED value first; keep the SAME two values, order does not affect `expect` equality)
- `assertEquals(actual, expected, delta)` -> `expect(actual, closeTo(expected, delta))`
- `assertTrue(x)` -> `expect(x, isTrue)`
- `assertFalse(x)` -> `expect(x, isFalse)`

## Structure
- Each `@Test public void fooBar()` -> `test('fooBar', () { ... });`
- File -> `void main() { group('<FileName>', () { <tests> }); }`
- Delete all `System.out.println(...)`, `import` lines, `@Test`, class wrapper.

## Skip rules (solver-only / unsupported by the graph engine)
Mark a test `skip: '<reason>'` (do NOT delete) when it:
- Calls `getSystem()`, `addToSolver(...)`, `addToSolverWithPermutation`, `updateFromSolver`,
  `resetSolverVariables`, `getCache`, `minimize`, `setDebugSolverName`, `fillMetrics`,
  `new Metrics()` — these exercise the Cassowary solver directly.
- Uses circular/`connectCircularConstraint` positioning (needs Cassowary).
Example: `test('name', () { ... }, skip: 'requires Cassowary solver (phase 2)');`

If a test only differs by re-running with `OPTIMIZATION_NONE` vs `OPTIMIZATION_STANDARD`
and asserting the same coordinates, keep ONE run (through `layout()`/`measure()`), drop the
solver-only duplicate assertions if they reference solver APIs.

## Running
`dart test test/<file>_test.dart`
Report: total tests, passing, skipped, and any FAILING with the expected-vs-actual so the
engine owner can decide if it is an engine bug or a conversion error.
