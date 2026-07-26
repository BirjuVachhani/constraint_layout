import 'package:constraint_layout/constraint_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shiki_flutter/shiki_flutter.dart';

import 'src/router/app_router.dart';
import 'src/theme/app_theme.dart';
import 'src/theme/theme_controller.dart';
import 'src/widgets/nav_sheet.dart';

void main() {
  // Clean URLs for the web (/, /docs) instead of hash fragments.
  usePathUrlStrategy();
  // The site ships as a release web build, where ConstraintLayout's debug
  // overlays are off by default. Opt in so the per-preview "chains" and
  // "blueprint" toggles on the home page actually render.
  ConstraintLayout.allowDebugFlags = true;
  // The docs render every code block live with shiki_flutter, themed with the
  // Pierre light/dark pair so the code follows the site's light/dark mode. Web
  // uses the pure-Dart embedded engine by default (no WebAssembly, no worker),
  // which is plenty fast for the small snippets shown here.
  ShikiHighlighter.config = const ShikiHighlighterConfig(
    defaultTheme: .dual(
      light: PierreThemes.pierreLight,
      dark: PierreThemes.pierreDark,
    ),
  );
  runApp(const ConstraintLayoutSite());
}

/// Root of the showcase site. Owns the [ThemeController] and rebuilds the app
/// when the light/dark mode changes.
class ConstraintLayoutSite extends StatefulWidget {
  const ConstraintLayoutSite({super.key});

  @override
  State<ConstraintLayoutSite> createState() => _ConstraintLayoutSiteState();
}

class _ConstraintLayoutSiteState extends State<ConstraintLayoutSite> {
  final ThemeController _theme = ThemeController();

  /// Bridges the docs page's section list to the app-wide nav popup. Lives above
  /// the router so the shell's nav bar and the docs page share one instance.
  final NavSheetController _navSheet = NavSheetController();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      controller: _theme,
      child: NavSheetScope(
        controller: _navSheet,
        child: ListenableBuilder(
          listenable: _theme,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'constraint_layout: constraint-based layout for Flutter',
              debugShowCheckedModeBanner: false,
              theme: buildTheme(Brightness.light),
              darkTheme: buildTheme(Brightness.dark),
              themeMode: _theme.value,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
