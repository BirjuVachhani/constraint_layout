import 'package:constraint_layout/constraint_layout.dart';
import 'package:flutter/material.dart';

import '../highlight/highlighter_service.dart';
import '../theme/tokens.dart';
import 'code_block.dart';
import 'live_example.dart';
import 'pill.dart';
import 'preview.dart';

/// An interactive companion to the static visibility example: a segmented
/// control that flips one child between `visible`, `invisible`, and `gone` so
/// the reader can watch the layout reflow, and see how `goneMargin` closes the
/// gap. Because visibility is just a property, the whole change is one
/// `setState`, no rebuild of the layout itself.
///
/// It renders on the same [PreviewStage] as the static examples, so the dotted
/// canvas and red bounds handles match the rest of the page.
class VisibilityToggleDemo extends StatefulWidget {
  const VisibilityToggleDemo({super.key, this.height = 200});

  /// Height of the preview stage.
  final double height;

  @override
  State<VisibilityToggleDemo> createState() => _VisibilityToggleDemoState();
}

class _VisibilityToggleDemoState extends State<VisibilityToggleDemo> {
  // Start gone so the first thing the reader does (flip to visible) makes B
  // appear and push C over, the clearest demonstration of the effect.
  ConstraintVisibility _visibility = ConstraintVisibility.gone;

  static const _options = <(String, ConstraintVisibility)>[
    ('visible', ConstraintVisibility.visible),
    ('invisible', ConstraintVisibility.invisible),
    ('gone', ConstraintVisibility.gone),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = context.brand;
    final isDark = Theme.brightnessOf(context) == .dark;

    // Match the code/preview cards: same theme background, border, and radius.
    final bg = HighlighterService.instance.defaultBackground(
      isDark: isDark,
      fallback: colors.surface,
    );
    final onBg = bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final border = onBg.withValues(alpha: 0.10);

    final card = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(onBg, brand.azure),
            SizedBox(
              height: widget.height,
              child: PreviewStage(child: _layout()),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                "B's visibility:",
                style: TextStyle(
                  color: colors.mutedForeground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            for (final (label, value) in _options)
              SelectPill(
                label: label,
                selected: _visibility == value,
                onTap: () => setState(() => _visibility = value),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // The source for exactly the selection above: the `visibility:` line
        // tracks the pills, so the reader can map the control to the code.
        CodeBlock(
          code: _codeFor(_visibility),
          lang: 'dart',
          filename: 'visibility.dart',
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// The layout's source with `B`'s `visibility` set to the current [v], kept
  /// in step with [_layout] so the code always matches what the preview shows.
  String _codeFor(ConstraintVisibility v) {
    return '''
ConstraintLayout(
  children: [
    Constrained(
      id: #a,
      start: .startOf(parent, margin: 16),
      top: .topOf(parent),
      bottom: .bottomOf(parent),
      child: const DemoBox('A'),
    ),
    Constrained(
      id: #b,
      start: .endOf(#a, margin: 12),
      top: .topOf(#a),
      bottom: .bottomOf(#a),
      visibility: ConstraintVisibility.${v.name},
      child: const DemoBox('B'),
    ),
    Constrained(
      id: #c,
      // 40px gone-margin closes the gap when B collapses.
      start: .endOf(#b, margin: 12, goneMargin: 40),
      top: .topOf(#a),
      bottom: .bottomOf(#a),
      child: const DemoBox('C'),
    ),
  ],
)''';
  }

  /// The mono `visibility` label header, mirroring the live examples' preview
  /// header so this card sits flush with them.
  Widget _header(Color onBg, Color dot) {
    return SelectionContainer.disabled(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'visibility',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                  height: 1.0,
                  color: onBg.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A, B, C in a row, where B's visibility is state-driven and C keeps a
  /// larger `goneMargin` so it closes the gap when B collapses.
  Widget _layout() {
    return ConstraintLayout(
      children: [
        Constrained(
          id: #a,
          start: .startOf(parent, margin: 16),
          top: .topOf(parent),
          bottom: .bottomOf(parent),
          child: const DemoBox('A'),
        ),
        Constrained(
          id: #b,
          start: .endOf(#a, margin: 12),
          top: .topOf(#a),
          bottom: .bottomOf(#a),
          visibility: _visibility,
          child: const DemoBox('B'),
        ),
        Constrained(
          id: #c,
          // 12 past B normally; 40 past its collapsed point when B is gone.
          start: .endOf(#b, margin: 12, goneMargin: 40),
          top: .topOf(#a),
          bottom: .bottomOf(#a),
          child: const DemoBox('C'),
        ),
      ],
    );
  }
}
