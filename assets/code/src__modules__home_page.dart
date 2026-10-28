// OVERVIEW — the library index.
//
// The hero sells the library; below it the full catalogue renders
// GROUPED BY CATEGORY (read from kCategories, the same list the drawer
// uses), so the index, drawer and rail can never disagree. Each card
// navigates via the shared section index — no routes needed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/catalog.dart';
import '../app/state.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final go = ref.read(sectionIndexProvider.notifier).select;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -- hero --------------------------------------------------
          Stack(
            children: [
              const AuroraBackground(height: 430),
              MaxWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Tokens.s24,
                    Tokens.s48,
                    Tokens.s24,
                    Tokens.s32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Tokens.s12,
                              vertical: Tokens.s4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'FLUTTER COMPONENT LIBRARY · ZERO BACKEND',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.3, end: 0),
                      const SizedBox(height: Tokens.s16),
                      Text(
                            'Thirty-plus components.\nOne codebase.\nNo server.',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: Tokens.s12),
                      Text(
                        'Prism UI is a browsable Flutter component library: dashboards, '
                        'charts, storefront, player, chat, motion recipes and a live '
                        'theming studio. Every demo ships with its source — tap Code '
                        'on any page. All mock data, deployable to GitHub Pages as '
                        'static files.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ).animate().fadeIn(delay: 240.ms, duration: 500.ms),
                      const SizedBox(height: Tokens.s24),
                      Wrap(
                        spacing: Tokens.s12,
                        runSpacing: Tokens.s12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => go(2),
                            icon: const Icon(Icons.dashboard_outlined),
                            label: const Text('Browse components'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => go(1),
                            icon: const Icon(Icons.palette_outlined),
                            label: const Text('Open theming studio'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 360.ms, duration: 500.ms),
                      const SizedBox(height: Tokens.s24),
                      const _HeroStats(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // -- catalogue, grouped by category -------------------------
          MaxWidth(
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var ci = 0; ci < kCategories.length; ci++) ...[
                    SectionHeader(
                      eyebrow: 'Category ${ci + 1}',
                      title: kCategories[ci].label,
                    ),
                    const SizedBox(height: Tokens.s12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth > 800
                            ? 3
                            : constraints.maxWidth > 520
                            ? 2
                            : 1;
                        final sections = kCategories[ci].sections;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: Tokens.s16,
                                mainAxisSpacing: Tokens.s16,
                                mainAxisExtent: 170,
                              ),
                          itemCount: sections.length,
                          itemBuilder: (context, i) =>
                              _ComponentCard(
                                    section: sections[i],
                                    blurb: _blurbs[sections[i].label] ?? '',
                                  )
                                  .animate()
                                  .fadeIn(delay: (i * 70).ms, duration: 400.ms)
                                  .slideY(begin: 0.15, end: 0),
                        );
                      },
                    ),
                    const SizedBox(height: Tokens.s24),
                  ],
                  GlassCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: Tokens.s12),
                        Expanded(
                          child: Text(
                            'Learning path: Overview → Theming → Dashboard → Charts → '
                            'Motion → Storefront → Music → Chat. Docs live in /docs, '
                            'source on every page behind the Code button.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Tokens.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('30+', 'components'),
      ('6', 'categories'),
      ('0', 'servers'),
      ('2', 'themes'),
    ];
    return Wrap(
      spacing: Tokens.s24,
      runSpacing: Tokens.s12,
      children: [
        for (final s in stats)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.$1,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: Tokens.s8),
              Text(
                s.$2,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    ).animate().fadeIn(delay: 480.ms, duration: 500.ms);
  }
}

const Map<String, String> _blurbs = {
  'Overview': 'You are here — the library index.',
  'Setup': 'Install Flutter, run your first app',
  'Dart 101': 'Language crash-course + widget catalogue',
  'Theming': 'Seed colours, dark mode, type specimen',
  'Dashboard': 'Balance chart, KPIs, budgets, transactions',
  'Charts': 'Line, bar & donut recipes with fl_chart',
  'Storefront': 'Product grid, detail sheet, cart state',
  'Music player': 'Now-playing card, playlist, fake progress',
  'Chat': 'Bubbles, typing indicator, local replies',
  'Motion lab': 'Implicit, staggered, crossfade + Hero',
};

class _ComponentCard extends ConsumerWidget {
  const _ComponentCard({required this.section, required this.blurb});
  final Section section;
  final String blurb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(Tokens.r16),
      // No routes: the shell swaps bodies by flat index, so navigating
      // anywhere in the app is a single provider write.
      onTap: () => ref
          .read(sectionIndexProvider.notifier)
          .select(kSections.indexOf(section)),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(Tokens.s8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(Tokens.r12),
              ),
              child: Icon(
                section.selectedIcon,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const Spacer(),
            Text(
              section.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Tokens.s4),
            Text(
              blurb,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
