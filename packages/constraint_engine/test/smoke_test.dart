import 'package:constraint_engine/constraint_engine.dart';
import 'package:test/test.dart';

void main() {
  test('pinned top-left', () {
    final root = ConstraintWidgetContainer.rect(0, 0, 600, 800);
    final a = ConstraintWidget.size(100, 30);
    root.setDebugName('root');
    a.setDebugName('A');
    root.add(a);
    a.connect(ConstraintAnchorType.left, root, ConstraintAnchorType.left);
    a.connect(ConstraintAnchorType.top, root, ConstraintAnchorType.top);
    root.layout();
    expect(a.getLeft(), 0);
    expect(a.getTop(), 0);
    expect(a.getWidth(), 100);
    expect(a.getHeight(), 30);
  });

  test('centered horizontally', () {
    final root = ConstraintWidgetContainer.rect(0, 0, 600, 800);
    final a = ConstraintWidget.size(100, 30);
    root.setDebugName('root');
    a.setDebugName('A');
    root.add(a);
    a.connect(ConstraintAnchorType.left, root, ConstraintAnchorType.left);
    a.connect(ConstraintAnchorType.right, root, ConstraintAnchorType.right);
    a.connect(ConstraintAnchorType.top, root, ConstraintAnchorType.top);
    root.layout();
    expect(a.getLeft(), 250);
    expect(a.getWidth(), 100);
  });

  test('margin + below', () {
    final root = ConstraintWidgetContainer.rect(0, 0, 600, 800);
    final a = ConstraintWidget.size(100, 30);
    final b = ConstraintWidget.size(100, 30);
    root.setDebugName('root');
    a.setDebugName('A');
    b.setDebugName('B');
    root.add(a);
    root.add(b);
    a.connect(ConstraintAnchorType.left, root, ConstraintAnchorType.left, 20);
    a.connect(ConstraintAnchorType.top, root, ConstraintAnchorType.top, 16);
    b.connect(ConstraintAnchorType.left, a, ConstraintAnchorType.left);
    b.connect(ConstraintAnchorType.top, a, ConstraintAnchorType.bottom, 8);
    root.layout();
    expect(a.getLeft(), 20);
    expect(a.getTop(), 16);
    expect(b.getLeft(), 20);
    expect(b.getTop(), 54);
  });
}
