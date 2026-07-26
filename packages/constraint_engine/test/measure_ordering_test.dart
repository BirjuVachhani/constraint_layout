import 'package:constraint_engine/constraint_engine.dart';
import 'package:test/test.dart';

/// A measurer that models content whose height depends on its width, the way
/// wrapping text does: a widget carries a content "length", and at a given
/// width it wraps to `ceil(length / width)` lines of [lineHeight] each. At
/// width 0 every unit lands on its own line, so a mis-order that measures a
/// wrapContent height before its matchConstraint width is resolved produces a
/// wildly tall result, exactly like real text wrapping at width 0.
class _TextLikeMeasurer implements Measurer {
  _TextLikeMeasurer(this.length, {this.lineHeight = 20});

  /// Content length per widget, keyed by debug name.
  final Map<String, int> length;
  final int lineHeight;

  @override
  void measure(ConstraintWidget widget, Measure measure) {
    final len = length[widget.getDebugName()] ?? 0;

    final int width;
    if (measure.horizontalBehavior == DimensionBehaviour.wrapContent) {
      width = len; // natural single-line width
    } else {
      width = measure.horizontalDimension; // fixed or solver-resolved
    }

    final int height;
    if (measure.verticalBehavior == DimensionBehaviour.wrapContent) {
      final w = width <= 0 ? 1 : width; // width 0 => one unit per line
      final lines = (len + w - 1) ~/ w; // ceil(len / w)
      height = (lines <= 0 ? 1 : lines) * lineHeight;
    } else {
      height = measure.verticalDimension;
    }

    measure.measuredWidth = width;
    measure.measuredHeight = height;
    measure.measuredHasBaseline = false;
    measure.measuredBaseline = 0;
    widget.setMeasureRequested(false);
  }

  @override
  void didMeasures() {}
}

void main() {
  group('measure ordering: wrap size depends on resolved match size', () {
    test('matchConstraint width resolves before the wrapContent height is '
        'measured, under a wrapContent (unbounded) container height', () {
      // Container 340 wide, its own height wrapping to content (the case that
      // pushed the layout onto the solver-fallback path where the bug lived).
      final root = ConstraintWidgetContainer.rect(0, 0, 340, 0);
      root.setDebugName('root');
      root.setVerticalDimensionBehaviour(DimensionBehaviour.wrapContent);
      root.setMeasurer(_TextLikeMeasurer({'a': 300}));

      final a = ConstraintWidget();
      a.setDebugName('a');
      root.add(a);
      a.setHorizontalDimensionBehaviour(DimensionBehaviour.matchConstraint);
      a.setVerticalDimensionBehaviour(DimensionBehaviour.wrapContent);
      a.connect(ConstraintAnchorType.left, root, ConstraintAnchorType.left, 20);
      a.connect(ConstraintAnchorType.right, root, ConstraintAnchorType.right, 20);
      a.connect(ConstraintAnchorType.top, root, ConstraintAnchorType.top);

      root.layout();

      // Width resolves to 340 - 20 - 20 = 300; at width 300 the length-300
      // content is a single 20px line, NOT 300 lines measured at width 0.
      expect(a.getWidth(), 300);
      expect(a.getHeight(), 20);
      expect(root.getHeight(), 20);
    });

    test('a bottom barrier settles on the true wrapped height of the tallest '
        'match-width child', () {
      final root = ConstraintWidgetContainer.rect(0, 0, 660, 0);
      root.setDebugName('root');
      root.setVerticalDimensionBehaviour(DimensionBehaviour.wrapContent);
      // 'a' wraps to 2 lines (40px) at its resolved width, 'b' to 1 (20px).
      root.setMeasurer(_TextLikeMeasurer({'a': 500, 'b': 100}));

      final guide = Guideline();
      guide.setDebugName('guide');
      guide.setOrientation(Guideline.vertical);
      guide.setGuidePercent(0.5);
      root.add(guide);

      final a = ConstraintWidget()..setDebugName('a');
      final b = ConstraintWidget()..setDebugName('b');
      root.add(a);
      root.add(b);
      for (final w in [a, b]) {
        w.setHorizontalDimensionBehaviour(DimensionBehaviour.matchConstraint);
        w.setVerticalDimensionBehaviour(DimensionBehaviour.wrapContent);
        w.connect(ConstraintAnchorType.top, root, ConstraintAnchorType.top);
      }
      // Each column is 330 wide, less a 15px inset on each side -> width 300.
      a.connect(ConstraintAnchorType.left, root, ConstraintAnchorType.left, 15);
      a.connect(ConstraintAnchorType.right, guide, ConstraintAnchorType.left, 15);
      b.connect(ConstraintAnchorType.left, guide, ConstraintAnchorType.right, 15);
      b.connect(ConstraintAnchorType.right, root, ConstraintAnchorType.right, 15);

      final barrier = Barrier();
      barrier.setDebugName('barrier');
      barrier.setBarrierType(Barrier.bottom);
      barrier.add(a);
      barrier.add(b);
      root.add(barrier);

      final follower = ConstraintWidget.size(10, 10)..setDebugName('follower');
      root.add(follower);
      follower.connect(ConstraintAnchorType.left, root, ConstraintAnchorType.left);
      follower.connect(
          ConstraintAnchorType.top, barrier, ConstraintAnchorType.top);

      root.layout();

      expect(a.getWidth(), 300);
      expect(a.getHeight(), 40, reason: 'ceil(500/300)=2 lines at 20px');
      expect(b.getHeight(), 20);
      // Barrier and the follower below it sit at the tall column's height.
      expect(follower.getTop(), 40);
    });
  });
}
