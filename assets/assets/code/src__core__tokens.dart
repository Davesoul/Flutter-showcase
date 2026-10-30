// Design tokens: the single source of truth for spacing, radii,
// breakpoints and content width.
//
// WHY THIS FILE EXISTS
// --------------------
// Scattering magic numbers (`EdgeInsets.all(16)`, `BorderRadius.circular(20)`,
// `if (width > 800)`) across screens makes a UI impossible to keep
// consistent. Tokens centralise those decisions so a redesign is a
// one-file change. This mirrors how design systems (Material, Tailwind)
// work: see docs/02-design-system.md.
library;

import 'package:flutter/material.dart';

/// Spacing / radius / layout constants used across every module.
abstract final class Tokens {
  // -- spacing scale (4-pt grid) --
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  // -- corner radii --
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r24 = 24;

  // -- layout --
  /// Max width of centred content on wide screens. Beyond this the UI
  /// would stretch into unreadably long lines.
  static const double maxContentWidth = 1160;

  /// Below this width the shell switches to a drawer + bottom-safe
  /// single column (phones).
  static const double compactMax = 720;

  /// At/above this width the shell shows an extended NavigationRail
  /// with labels (desktop).
  static const double expandedMin = 1100;

  // -- curated seed colours for the theming lab --
  static const List<SeedOption> seeds = [
    SeedOption('Crimson', Color(0xFFC8553D)),
    SeedOption('Violet', Color(0xFF7C5CFF)),
    SeedOption('Teal', Color(0xFF0E9F8A)),
    SeedOption('Amber', Color(0xFFD9930D)),
    SeedOption('Azure', Color(0xFF2F7DE1)),
    SeedOption('Rose', Color(0xFFE14E9A)),
  ];
}

/// A named seed colour shown in the Theming lab.
class SeedOption {
  const SeedOption(this.name, this.color);
  final String name;
  final Color color;
}
