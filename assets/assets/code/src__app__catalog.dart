// Library catalogue: categories → components → bundled code paths.
//
// Code paths are FLAT (src__modules__x.dart) because a pubspec assets
// directory entry only bundles files directly inside it — see
// tool/sync_code_assets.py. One list rules the rail, drawer, Overview
// index and Code buttons so they can never drift apart.
library;

import 'package:flutter/material.dart';

import '../modules/home_page.dart';
import '../modules/learn_page.dart';
import '../modules/setup_page.dart';
import '../modules/dashboard_page.dart';
import '../modules/commerce_page.dart';
import '../modules/music_page.dart';
import '../modules/chat_page.dart';
import '../modules/charts_page.dart';
import '../modules/motion_page.dart';
import '../modules/theming_page.dart';

/// One demo in the library. [codeAsset] points at this file's bundled
/// source so the page can show its code.
class Section {
  const Section(this.label, this.icon, this.selectedIcon, this.page,
      this.codeAsset);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  final String codeAsset;
}

class Category {
  const Category(this.label, this.icon, this.sections);
  final String label;
  final IconData icon;
  final List<Section> sections;
}

const _codeBase = 'assets/code/src__modules';

/// The library catalogue, in display order.
const List<Category> kCategories = [
  Category('Foundations', Icons.foundation_outlined, [
    Section('Overview', Icons.home_outlined, Icons.home, HomePage(),
        '${_codeBase}__home_page.dart'),
    Section('Setup', Icons.download_outlined, Icons.download, SetupPage(),
        '${_codeBase}__setup_page.dart'),
    Section('Dart 101', Icons.school_outlined, Icons.school, LearnPage(),
        '${_codeBase}__learn_page.dart'),
    Section('Theming', Icons.palette_outlined, Icons.palette,
        ThemingPage(), '${_codeBase}__theming_page.dart'),
  ]),
  Category('Data display', Icons.table_chart_outlined, [
    Section('Dashboard', Icons.dashboard_outlined, Icons.dashboard,
        DashboardPage(), '${_codeBase}__dashboard_page.dart'),
    Section('Charts', Icons.bar_chart_outlined, Icons.bar_chart,
        ChartsPage(), '${_codeBase}__charts_page.dart'),
  ]),
  Category('Commerce', Icons.storefront_outlined, [
    Section('Storefront', Icons.storefront_outlined, Icons.storefront,
        CommercePage(), '${_codeBase}__commerce_page.dart'),
  ]),
  Category('Media', Icons.play_circle_outlined, [
    Section('Music player', Icons.music_note_outlined, Icons.music_note,
        MusicPage(), '${_codeBase}__music_page.dart'),
  ]),
  Category('Messaging', Icons.forum_outlined, [
    Section('Chat', Icons.chat_bubble_outline, Icons.chat_bubble,
        ChatPage(), '${_codeBase}__chat_page.dart'),
  ]),
  Category('Motion', Icons.animation_outlined, [
    Section('Motion lab', Icons.animation_outlined, Icons.animation,
        MotionPage(), '${_codeBase}__motion_page.dart'),
  ]),
];

/// Flat list for indexed navigation (rail + AnimatedSwitcher).
final List<Section> kSections = [
  for (final c in kCategories) ...c.sections,
];

/// Category label for a flat section index (used as page eyebrows).
String categoryOf(int index) {
  var i = index;
  for (final c in kCategories) {
    if (i < c.sections.length) return c.label;
    i -= c.sections.length;
  }
  return '';
}
