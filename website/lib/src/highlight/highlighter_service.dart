import 'package:flutter/material.dart';
import 'package:shiki_flutter/shiki_flutter.dart';

/// Wraps a single, shared [ShikiHighlighter] for the whole site.
///
/// Code blocks highlight asynchronously (see main.dart), so tokenization runs
/// off the UI thread and the highlighter's own token cache keeps rebuilds
/// instant, no hand-rolled span cache needed here. This service just owns the
/// shared highlighter and the theme background colors.
class HighlighterService {
  HighlighterService._();

  static final HighlighterService instance = HighlighterService._();

  /// The site-wide default theme for code blocks: the Pierre light/dark pair.
  /// Used when a [CodeBlock]/widget is not given an explicit `theme:`.
  static const ShikiThemeBase defaultTheme = ShikiDualTheme(
    light: PierreThemes.pierreLight,
    dark: PierreThemes.pierreDark,
  );

  // The only languages this site renders: Dart for every example, plus YAML and
  // shell for the installation section. Bundled symbols are top-level `final`s
  // (not `const`), so this list can't be `const`.
  static final List<CodeLanguage> _bundledLanguages = [
    CodeLanguages.dart,
    CodeLanguages.yaml,
    CodeLanguages.shellscript,
  ];

  /// Maps a language id (as passed to a code block) to its bundled
  /// [CodeLanguage]. Every id the site uses is in [_bundledLanguages].
  static final Map<String, CodeLanguage> _languagesById = {
    for (final lang in _bundledLanguages) lang.id: lang,
  };

  /// The bundled [CodeLanguage] registered under [id] (e.g. `'dart'`). The
  /// widgets take a [CodeLanguage] object, so string-id call sites resolve here.
  static CodeLanguage languageForId(String id) => _languagesById[id]!;

  late final ShikiHighlighter _highlighter = ShikiHighlighter()
    ..preload(
      langs: _bundledLanguages,
      themes: [PierreThemes.pierreDark, PierreThemes.pierreLight],
    );

  /// The shared highlighter, e.g. for passing straight to a [ShikiCodeView].
  ShikiHighlighter get highlighter => _highlighter;

  final Map<String, Color> _bgCache = {};

  /// The background color declared by [theme], falling back to [fallback].
  Color backgroundOf(String theme, Color fallback) {
    return _bgCache.putIfAbsent(theme, () {
      final reg = _highlighter.getThemeRegistration(theme);
      return parseColor(reg.bg) ?? fallback;
    });
  }

  /// The background to paint for [theme] on the site.
  Color displayBackground(String theme, Color fallback) =>
      backgroundOf(theme, fallback);

  /// The background the default (Pierre) code theme paints for the current
  /// brightness. Shared by the code cards and the live-preview panes so the two
  /// sit on an identical surface.
  Color defaultBackground({required bool isDark, required Color fallback}) {
    final theme = defaultTheme.resolve(isDark: isDark);
    return displayBackground(theme.id, fallback);
  }
}
