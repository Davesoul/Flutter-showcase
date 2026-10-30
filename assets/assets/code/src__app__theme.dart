// App theme: Material 3 colour schemes generated from a seed colour,
// plus the app's type scale (Plus Jakarta Sans via google_fonts).
//
// DESIGN DECISIONS
// ----------------
// 1. `ColorScheme.fromSeed` does the heavy lifting — one seed colour
//    produces a full accessible palette (primary, containers, surfaces,
//    on-colors) for light AND dark. Hand-picking 30 colours is how
//    inconsistent UIs happen.
// 2. Dark mode is a first-class theme, not an afterthought: same seed,
//    `Brightness.dark`. Toggle it in the app bar from anywhere.
// 3. Typography comes from a single Google Font so headings/body share
//    one voice. `textTheme` on ThemeData applies it app-wide.
//
// LEARN MORE: docs/02-design-system.md
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // One seed in, full palette out — light AND dark from the same hue.
  // Every screen reads these colours, so the studio re-skins everything.
  static ThemeData light(Color seed) => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      );

  static ThemeData dark(Color seed) => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      );

  static ThemeData _build(ColorScheme scheme) {
    // Start from the platform default text theme, then swap the family.
    // This keeps Material's size/weight scale intact.
    final base = ThemeData(colorScheme: scheme, useMaterial3: true).textTheme;
    final text = GoogleFonts.plusJakartaSansTextTheme(base);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
