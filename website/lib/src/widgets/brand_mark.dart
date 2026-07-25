import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The package's logo mark, drawn in code so it scales cleanly and needs no
/// asset: a small blueprint canvas holding two anchored boxes (azure pinned to
/// the top-start corner, green to the bottom-end), the essence of a constraint
/// layout. Colors come from the brand palette, so it reads in light and dark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final d = size;
    final pad = d * 0.16;
    final box = d * 0.30;
    return SizedBox.square(
      dimension: d,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: brand.canvas,
          borderRadius: BorderRadius.circular(d * 0.24),
          border: Border.all(color: brand.canvasBorder),
        ),
        child: Stack(
          children: [
            Positioned(top: pad, left: pad, child: _box(box, brand.azure, d)),
            Positioned(
              bottom: pad,
              right: pad,
              child: _box(box, brand.green, d),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double s, Color color, double d) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(d * 0.11),
    ),
  );
}
