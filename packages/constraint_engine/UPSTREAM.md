# Upstream provenance

This package is a Dart port of `androidx.constraintlayout.core` (the
platform-independent layout engine behind Android ConstraintLayout).

Pinned upstream revision the port represents:

- Repository: https://github.com/androidx/constraintlayout
- Commit: `9cd4b5a4079a14175f91dc897abd83270799364a` (main, 2023-10-24)
- Library versions at that commit (`constraintlayout/gradle.properties`):
  - `constraintlayout.core` **1.1.0-alpha04**
  - `constraintlayout` 2.2.0-alpha04
- Local mirror used for porting: `inspo/constraintlayout` at the repo root.

That commit is the final commit of the GitHub repository; ConstraintLayout
development moved to the AOSP androidx monorepo
(https://android.googlesource.com/platform/frameworks/support, under
`constraintlayout/`), which is where the 2.2.x / core 1.1.x releases ship
from.

Parity with released versions (verified 2026-07-24 against the AOSP
`androidx-constraintlayout-release` branch, versioned core 1.1.2-dev, which
includes everything in core 1.1.1 / constraintlayout 2.2.1): within the
ported scope (the solver classes, `widgets/`, `widgets/analyzer/`), the only
source change since the pinned commit is `LinearSystem.sPoolSize` becoming an
instance field (change I8952e, b/376718273, shipped in 2.2.1). That fix is
applied in this port (`_poolSize` in `linear_system.dart`), so the ported
scope is at parity with core 1.1.1. All other post-pin core changes are in
unported modules (`motion/`, `parser/`, `state/`, `utils/`), including the
core 1.1.1 visibility-toggle placement fix (b/299134793), which lives in the
`state/` layer used by Compose.

Scope ported from `core/src/main/java/androidx/constraintlayout/core/`:

- `widgets/` and `widgets/analyzer/`: widget model + the dependency-graph
  resolver (phase 1).
- The `LinearSystem` Cassowary-style solver and its supporting classes
  (phase 2): `SolverVariable`, `ArrayRow`, `ArrayLinkedVariables`,
  `SolverVariableValues`, `GoalRow`, `PriorityGoalRow`, `Cache`, `Pools`.
- Virtual layouts (phase 3): `VirtualLayout`, `Flow` (with the upstream
  FlowTest suite), and `utils/GridCore`.

Not ported: `motion/`, `parser/`, `dsl/`, `state/` (the Flutter adapter plays
that role), `Placeholder`, the `Direct`/`Grouping` optimizers (the dependency
graph plays that role), and `Metrics` instrumentation.

Known intentional divergences from upstream are documented inline at the
relevant code, and include:

- Dart `double` is used where Java uses 32-bit `float`; a handful of golden
  test values differ by 1 to 2 px from upstream because of this and carry a
  `closeTo` note where adjusted.
- `DependencyGraph.directMeasure` treats a measures-only invalidation as a
  graph invalidation (run reset destroys graph edges; upstream masks this via
  its solver fallback path).
- GONE widgets get their runs' dimension behaviour reset to pristine defaults
  in `_basicMeasureWidgets` (upstream leaves stale state that its solver
  fallback hides).
- Layout entry differs structurally: upstream's default path is the solver
  with optional graph optimization; this port tries the dependency graph
  first and falls back to the ported solver when the graph cannot faithfully
  resolve. The graph declines (routes to the solver) for: chains with GONE or
  ratio-sized members, chains along a wrap-content axis, MATCH_CONSTRAINT_WRAP
  widgets, circular (center) constraints, nested containers, widgets centered
  along a wrap axis, and wrap results whose children overflow the computed
  bounds. Pre-graph widget state is snapshotted and restored before the
  fallback, and wrap-sized children are re-measured, so the solver sees the
  same input upstream's would.
- Upstream's "width/height measured too small" clamp in the solver loop is
  omitted: it relies on the unported Direct optimizer pre-sizing wrap
  containers, and would wrongly squash wrap containers whose entry size is
  smaller than their content.
- `_basicMeasureWidgets` passes the widget's real dimension (not 0) as the
  fixed-axis measure hint for MATCH_CONSTRAINT_WRAP measures, so the measure
  pass cannot destroy fixed sizes the solver later needs.
- `addToSolver`'s center-point rows are guarded on a non-NaN circle angle
  (upstream would emit NaN rows for plain center connects, a path none of its
  tests exercise).
- `NestedLayout.testNestedLayout` stays skipped: it is disabled upstream too
  (its `@Test` is commented out) and expects a stale coordinate convention.
- Percent-sized matchConstraint dimensions are clamped by the matchConstraint
  min/max at their graph resolve sites (`_basicMeasureWidgets` and the
  widget-run percent cases). Upstream leaves these resolves unclamped and
  relies on its solver-first entry to apply the bounds; this engine resolves
  percent in the graph, so the clamp happens at the resolve site.
- Virtual layouts always route to the solver (added to the graph decline
  rules): their addToSolver pass is what creates the member constraints.
  Before the solver runs, layout()'s fallback measures virtual layouts with
  `SELF_DIMENSIONS` so a matchConstraint axis measures against the available
  space instead of a not-yet-solved zero size (upstream reaches the same
  state through its solverMeasure loop).
- `GridCore.measure` reports incoming EXACTLY sizes as its measured size.
  Upstream leaves the measured size untouched because its Compose host only
  sizes grids through the solver; a fixed-size grid measured through a host
  measurer would otherwise collapse to 0.

When updating the port, bump the commit above and re-run the full golden test
suite (`dart test`).
