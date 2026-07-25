import 'package:flutter/material.dart';

/// The site's color palette, exposed as a [ThemeExtension] so any widget can
/// read semantic tokens via `context.colors`.
///
/// The values mirror the shadcn/ui "neutral" system: a monochrome,
/// dark-forward scale with subtle borders.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceInset,
    required this.border,
    required this.borderStrong,
    required this.foreground,
    required this.mutedForeground,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.link,
    required this.navBackground,
    required this.codeShadow,
  });

  /// Page background.
  final Color background;

  /// Card / raised surface.
  final Color surface;

  /// Inset surface for chips, code header bars, etc.
  final Color surfaceInset;

  /// Hairline border (low contrast).
  final Color border;

  /// Slightly stronger border for emphasis.
  final Color borderStrong;

  /// Primary text color.
  final Color foreground;

  /// Secondary / de-emphasized text.
  final Color mutedForeground;

  /// Solid button background.
  final Color primary;

  /// Text/icon color on top of [primary].
  final Color onPrimary;

  /// Sparingly-used success accent (emerald).
  final Color accent;

  /// Link / interactive accent (blue).
  final Color link;

  /// Translucent background for the sticky, blurred nav bar.
  final Color navBackground;

  /// Shadow color under floating code cards.
  final Color codeShadow;

  static const AppColors dark = AppColors(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    // shadcn neutral accent/secondary/muted (oklch 26.9%).
    surfaceInset: Color(0xFF262626),
    border: Color(0x1AFFFFFF),
    borderStrong: Color(0xFF2A2A2A),
    foreground: Color(0xFFFAFAFA),
    mutedForeground: Color(0xFFA1A1A1),
    primary: Color(0xFFFAFAFA),
    onPrimary: Color(0xFF0A0A0A),
    // Pierre "green" and "azure" (the same hues the code blocks paint with).
    accent: Color(0xFF5ECC71),
    link: Color(0xFF009FFF),
    navBackground: Color(0xCC0A0A0A),
    codeShadow: Color(0x66000000),
  );

  static const AppColors light = AppColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceInset: Color(0xFFF5F5F5),
    border: Color(0xFFE6E6E6),
    borderStrong: Color(0xFFD4D4D4),
    foreground: Color(0xFF0A0A0A),
    mutedForeground: Color(0xFF6B6B6B),
    primary: Color(0xFF171717),
    onPrimary: Color(0xFFFAFAFA),
    // Pierre-light "green" and a slightly deepened "azure" for contrast on white.
    accent: Color(0xFF18A46C),
    link: Color(0xFF0A7CC7),
    navBackground: Color(0xF2FFFFFF),
    codeShadow: Color(0x14000000),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceInset,
    Color? border,
    Color? borderStrong,
    Color? foreground,
    Color? mutedForeground,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? link,
    Color? navBackground,
    Color? codeShadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceInset: surfaceInset ?? this.surfaceInset,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      foreground: foreground ?? this.foreground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      link: link ?? this.link,
      navBackground: navBackground ?? this.navBackground,
      codeShadow: codeShadow ?? this.codeShadow,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceInset: Color.lerp(surfaceInset, other.surfaceInset, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      link: Color.lerp(link, other.link, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      codeShadow: Color.lerp(codeShadow, other.codeShadow, t)!,
    );
  }
}

/// Vivid hues sampled from the Pierre code themes (the same palette the docs
/// code blocks paint syntax with), used for the layout-preview canvases and the
/// demo boxes rendered next to each snippet. Pulling the preview colors from the
/// code theme is what makes the live examples feel branded rather than generic.
@immutable
class BrandPalette {
  const BrandPalette({
    required this.azure,
    required this.cyan,
    required this.green,
    required this.lime,
    required this.gold,
    required this.orange,
    required this.coral,
    required this.pink,
    required this.magenta,
    required this.purple,
    required this.canvas,
    required this.canvasGrid,
    required this.canvasBorder,
    required this.guide,
  });

  /// The brand's primary hue: Pierre "azure".
  final Color azure;
  final Color cyan;
  final Color green;
  final Color lime;
  final Color gold;
  final Color orange;
  final Color coral;
  final Color pink;
  final Color magenta;
  final Color purple;

  /// Background of a layout-preview canvas.
  final Color canvas;

  /// Faint grid-dot color painted across the preview canvas (blueprint feel).
  final Color canvasGrid;

  /// Border around the preview canvas.
  final Color canvasBorder;

  /// Dashed guideline / barrier stroke color drawn over a preview.
  final Color guide;

  /// A stable, high-contrast rotation of hues for multi-box demos (chains,
  /// grids, flows). Index into it with the child's position.
  List<Color> get swatches => [
    azure,
    green,
    orange,
    pink,
    purple,
    cyan,
    gold,
    coral,
  ];

  /// The hue for the [i]th demo box, wrapping around [swatches].
  Color swatch(int i) => swatches[i % swatches.length];

  static const BrandPalette dark = BrandPalette(
    azure: Color(0xFF009FFF),
    cyan: Color(0xFF64D1DB),
    green: Color(0xFF5ECC71),
    lime: Color(0xFF86C427),
    gold: Color(0xFFFFCA00),
    orange: Color(0xFFFFA359),
    coral: Color(0xFFFF855E),
    pink: Color(0xFFFF678D),
    magenta: Color(0xFFD568EA),
    purple: Color(0xFF9D6AFB),
    canvas: Color(0xFF0C1117),
    canvasGrid: Color(0x1F009FFF),
    canvasBorder: Color(0x33009FFF),
    guide: Color(0xFFFFA359),
  );

  static const BrandPalette light = BrandPalette(
    azure: Color(0xFF0A7CC7),
    cyan: Color(0xFF1CA1C7),
    green: Color(0xFF18A46C),
    lime: Color(0xFF77A42A),
    gold: Color(0xFFC79310),
    orange: Color(0xFFD47628),
    coral: Color(0xFFD5512F),
    pink: Color(0xFFD32A61),
    magenta: Color(0xFFA631BE),
    purple: Color(0xFF693ACF),
    canvas: Color(0xFFEEF5FC),
    canvasGrid: Color(0x1F0A7CC7),
    canvasBorder: Color(0x330A7CC7),
    guide: Color(0xFFD47628),
  );

  static BrandPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Corner radii used across the site.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double pill = 999;
}

/// Layout constants.
abstract final class AppLayout {
  /// Max width of a standard content container: a `max-w-7xl` (1280px)
  /// container minus its `px-5` (20px) gutters on each side.
  static const double contentMaxWidth = 1240;

  /// Max width of the docs reading column.
  static const double readingMaxWidth = 780;

  /// Height of the sticky top navigation bar: a 36px-tall control row
  /// (`size-9` icon buttons) with 12px (`py-3`) padding each side.
  static const double navHeight = 60;

  /// Below this width, the layout collapses to a single column and menus move
  /// into drawers.
  static const double compactBreakpoint = 900;
}

/// Font families declared in `pubspec.yaml`.
abstract final class AppFonts {
  static const String sans = 'Geist';
  static const String mono = 'Geist Mono';
}

extension AppColorsContext on BuildContext {
  /// The active [AppColors] for this subtree.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// The vivid, Pierre-derived demo palette for the current brightness.
  BrandPalette get brand => BrandPalette.of(Theme.of(this).brightness);

  /// Whether the compact (mobile/tablet) layout should be used.
  bool get isCompact =>
      MediaQuery.sizeOf(this).width < AppLayout.compactBreakpoint;
}
