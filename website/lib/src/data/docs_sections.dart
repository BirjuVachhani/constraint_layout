/// Metadata for one docs section: its anchor [id] and display [title].
class DocsSection {
  const DocsSection(this.id, this.title);

  final String id;
  final String title;
}

/// A named group of sections, rendered as one labeled block in the nav.
class DocsSectionGroup {
  const DocsSectionGroup(this.title, this.sections);

  final String title;
  final List<DocsSection> sections;
}

/// The docs, grouped and ordered top-to-bottom: what ConstraintLayout is, the
/// positioning primitives, then chains, helpers, virtual layouts, a worked
/// example, and finally how the engine resolves it all. The sidebar and nav
/// popup render these groups; the reading column and scroll-spy walk the
/// flattened [docsSections] in this order.
const docsGroups = <DocsSectionGroup>[
  DocsSectionGroup('Getting started', [
    DocsSection('introduction', 'Introduction'),
    DocsSection('features', 'Features'),
    DocsSection('installation', 'Installation'),
    DocsSection('quick-start', 'Quick start'),
  ]),
  DocsSectionGroup('Positioning', [
    DocsSection('anchors', 'Anchors & links'),
    DocsSection('centering-bias', 'Centering & bias'),
    DocsSection('dimensions', 'Dimensions'),
    DocsSection('aspect-ratio', 'Aspect ratio'),
  ]),
  DocsSectionGroup('Chains & helpers', [
    DocsSection('chains', 'Chains'),
    DocsSection('guidelines', 'Guidelines'),
    DocsSection('barriers', 'Barriers'),
    DocsSection('circular', 'Circular positioning'),
    DocsSection('visibility', 'Visibility'),
  ]),
  DocsSectionGroup('Virtual layouts', [
    DocsSection('flow', 'Flow'),
    DocsSection('grid', 'Grid'),
  ]),
  DocsSectionGroup('Putting it together', [
    DocsSection('profile-card', 'A profile card'),
  ]),
  DocsSectionGroup('Under the hood', [
    DocsSection('engine', 'How the engine works'),
    DocsSection('android', 'Relation to Android'),
  ]),
];

/// The groups flattened into reading order, for the anchor keys, scroll-spy,
/// and the content column (all index-based).
final docsSections = <DocsSection>[
  for (final group in docsGroups) ...group.sections,
];
