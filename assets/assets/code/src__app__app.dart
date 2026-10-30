// App shell: MaterialApp + responsive navigation.
//
// Reads the catalogue (catalog.dart) — the grouped drawer, the flat
// rail and the page body all derive from kCategories/kSections.
//
// RESPONSIVE STRATEGY (docs/03-responsive-layout.md)
// --------------------------------------------------
// One codebase, three layouts, chosen by width at build time:
//   width >= 1100  → extended NavigationRail (icon + label, desktop)
//   720 – 1099     → compact NavigationRail (icons, tablet)
//   width < 720    → Drawer + hamburger (phones)
// The body is always the same component demo — only the *chrome*
// changes. The app bar badge names the live breakpoint so the
// responsiveness is visible, not just claimed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tokens.dart';
import 'catalog.dart';
import 'state.dart';
import 'theme.dart';

class PrismApp extends ConsumerWidget {
  const PrismApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final seed = ref.watch(seedColorProvider);
    return MaterialApp(
      title: 'Prism UI — Flutter Component Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seed),
      darkTheme: AppTheme.dark(seed),
      themeMode: mode,
      home: const Shell(),
    );
  }
}

class Shell extends ConsumerWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(sectionIndexProvider);
    final width = MediaQuery.widthOf(context);
    final extended = width >= Tokens.expandedMin;
    final showRail = width >= Tokens.compactMax;
    // One width read drives all three shells — and the badge prints it,
    // so responsiveness is observable, not just claimed.
    final breakpoint =
        extended ? 'Desktop' : showRail ? 'Tablet' : 'Phone';

    final destinations = [
      for (final s in kSections)
        NavigationRailDestination(
          icon: Icon(s.icon),
          selectedIcon: Icon(s.selectedIcon),
          label: Text(s.label),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoMark(),
            SizedBox(width: 8),
            Text('Prism UI',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          // Live breakpoint badge: proves the responsive shell.
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              '$breakpoint · ${width.round()}px',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: 'Toggle light / dark',
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: showRail
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _LogoMark(size: 40),
                        SizedBox(height: 8),
                        Text('Prism UI',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        Text('Flutter component library',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  for (final cat in kCategories) ...[
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        cat.label.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                      ),
                    ),
                    for (final s in cat.sections)
                      Builder(builder: (context) {
                        final i = kSections.indexOf(s);
                        return ListTile(
                          leading: Icon(i == index
                              ? s.selectedIcon
                              : s.icon),
                          title: Text(s.label),
                          selected: i == index,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.4),
                          onTap: () {
                            ref
                                .read(sectionIndexProvider.notifier)
                                .select(i);
                            Navigator.pop(context);
                          },
                        );
                      }),
                  ],
                ],
              ),
            ),
      body: Row(
        children: [
          if (showRail)
            NavigationRail(
              extended: extended,
              selectedIndex: index,
              onDestinationSelected: (i) => ref
                  .read(sectionIndexProvider.notifier)
                  .select(i),
              destinations: destinations,
            ),
          Expanded(
            // KeyedSubtree + changing ValueKey: without a new key each
            // time, AnimatedSwitcher would reuse the old subtree and the
            // 250ms cross-fade would never play.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(index),
                child: kSections[index].page,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient prism mark used in the app bar and drawer.
class _LogoMark extends StatelessWidget {
  const _LogoMark({this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.tertiary,
            scheme.secondary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.auto_awesome,
          size: size * 0.55, color: scheme.onPrimary),
    );
  }
}
