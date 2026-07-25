import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/links.dart';
import '../theme/tokens.dart';
import 'brand.dart';
import 'brand_mark.dart';
import 'inline_link_text.dart';
import 'section.dart';

/// The site footer: brand + tagline on one side, link columns on the other,
/// with a credit line beneath a divider.
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = context.isCompact;

    final brandBlock = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Brand(),
          const SizedBox(height: 16),
          InlineLinkText(
            'A faithful port of Android\'s ConstraintLayout to Flutter, in '
            'pure Dart. Lay out by constraints and keep the widget tree flat.',
            linkLabel: 'ConstraintLayout',
            url: Links.androidConstraintLayout,
            style: TextStyle(
              color: colors.mutedForeground,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );

    final columns = Wrap(
      spacing: 64,
      runSpacing: 32,
      children: [
        _FooterColumn(
          title: 'Product',
          links: [
            _FooterLink('Home', onTap: () => context.go('/')),
            _FooterLink('Docs', onTap: () => context.go('/docs')),
          ],
        ),
        _FooterColumn(
          title: 'Resources',
          links: [
            _FooterLink('GitHub', onTap: () => Links.open(Links.github)),
            _FooterLink('pub.dev', onTap: () => Links.open(Links.pubDev)),
          ],
        ),
        _FooterColumn(
          title: 'Credits',
          links: [
            _FooterLink(
              'Android ConstraintLayout',
              onTap: () => Links.open(Links.androidConstraintLayout),
            ),
            _FooterLink(
              'androidx core',
              onTap: () => Links.open(Links.androidxCore),
            ),
          ],
        ),
      ],
    );

    // The credit divider is kept OUTSIDE the ContentContainer so it spans the
    // full viewport width, edge to edge - matching the footer's own top border
    // and the CTA band above it. The brand/columns and credit line stay inside
    // their own containers so their content still aligns to the content column.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContentContainer(
            child: Padding(
              padding: const EdgeInsets.only(top: 48, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (compact) ...[
                    brandBlock,
                    const SizedBox(height: 40),
                    columns,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: brandBlock),
                        columns,
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleFooter extends StatelessWidget {
  const SimpleFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContentContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(size: 48),
                const SizedBox(height: 12),
                const FooterBrand(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _FooterLink('Home', onTap: () => context.go('/')),
                    _FooterLink('Docs', onTap: () => context.go('/docs')),
                    _FooterLink(
                      'GitHub',
                      onTap: () => Links.open(Links.github),
                    ),
                    _FooterLink(
                      'pub.dev',
                      onTap: () => Links.open(Links.pubDev),
                    ),
                  ],
                ),
                // if (compact) ...[
                //   const Brand(),
                //   const SizedBox(height: 40),
                //   columns,
                // ] else
                //   Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Expanded(child: const Brand()),
                //       columns,
                //     ],
                //   ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<_FooterLink> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.foreground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        ...links,
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Widget footerLink = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? colors.foreground : colors.mutedForeground,
              fontSize: 14,
              decoration: _hovered
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: colors.foreground,
            ),
          ),
        ),
      ),
    );
    return SelectionContainer.disabled(child: footerLink);
  }
}
