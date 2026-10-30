// MOTION LAB — four animation techniques, side by side.
//
// 1. IMPLICIT (AnimatedContainer): describe the end state, Flutter
//    tweens there automatically. Cheapest animation in the toolkit.
// 2. CROSSFADE (AnimatedCrossFade): swap two children with size aware
//    of both. Perfect for loading → content transitions.
// 3. STAGGERED (flutter_animate): declarative `.fadeIn(delay: …)`
//    chains. One line per effect beats hand-rolled Controllers.
// 4. HERO: shared-element transition across routes via matching tags.
// Full walkthrough: docs/05-animations.md
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/code_view.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class MotionPage extends StatelessWidget {
  const MotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                eyebrow: 'Motion',
                title: 'Motion lab',
                subtitle:
                    'Four techniques. Tap, toggle and replay each one.',
                action: const CodeAction(
                    assetPath:
                        'assets/code/src__modules__motion_page.dart'),
              ),
              const SizedBox(height: Tokens.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 860;
                  final a = const _ImplicitDemo();
                  const b = _CrossfadeDemo();
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: a),
                        const SizedBox(width: Tokens.s16),
                        const Expanded(child: b),
                      ],
                    );
                  }
                  return Column(children: [
                    a,
                    const SizedBox(height: Tokens.s16),
                    b
                  ]);
                },
              ),
              const SizedBox(height: Tokens.s16),
              const _StaggerDemo(),
              const SizedBox(height: Tokens.s16),
              const _HeroDemo(),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// 1. Implicit: tap the tile to morph it.
// ------------------------------------------------------------------
class _ImplicitDemo extends StatefulWidget {
  const _ImplicitDemo();

  @override
  State<_ImplicitDemo> createState() => _ImplicitDemoState();
}

class _ImplicitDemoState extends State<_ImplicitDemo> {
  bool _big = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1 · Implicit — AnimatedContainer',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const Text(
              'One widget, two states. setState flips the values; Flutter animates between them.'),
          const SizedBox(height: Tokens.s12),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _big = !_big),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                width: _big ? 200 : 120,
                height: _big ? 200 : 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    scheme.primary,
                    _big ? scheme.tertiary : scheme.secondary
                  ]),
                  borderRadius:
                      BorderRadius.circular(_big ? 100 : Tokens.r24),
                ),
                child: Icon(
                    _big ? Icons.check : Icons.touch_app_outlined,
                    color: scheme.onPrimary,
                    size: 40),
              ),
            ),
          ),
          const SizedBox(height: Tokens.s8),
          const Center(
              child: Text('Tap the shape — no controller required')),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// 2. Crossfade: skeleton <-> content.
// ------------------------------------------------------------------
class _CrossfadeDemo extends StatefulWidget {
  const _CrossfadeDemo();

  @override
  State<_CrossfadeDemo> createState() => _CrossfadeDemoState();
}

class _CrossfadeDemoState extends State<_CrossfadeDemo> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('2 · Crossfade — loading pattern',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const Text(
              'AnimatedCrossFade swaps a skeleton for content — the standard loading transition.'),
          const SizedBox(height: Tokens.s12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            crossFadeState: _loading
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(Tokens.r12),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
                      duration: 1200.ms,
                      color: scheme.surface.withValues(alpha: 0.6)),
              ],
            ),
            secondChild: Column(
              children: const [
                ListTile(
                    leading: Icon(Icons.inbox_outlined),
                    title: Text('3 new messages')),
                ListTile(
                    leading: Icon(Icons.favorite_outline),
                    title: Text('128 new likes')),
                ListTile(
                    leading: Icon(Icons.group_outlined),
                    title: Text('2 invites')),
              ],
            ),
          ),
          const SizedBox(height: Tokens.s8),
          Center(
            child: FilledButton.tonal(
              onPressed: () =>
                  setState(() => _loading = !_loading),
              child: Text(_loading ? 'Simulate loaded' : 'Replay loading'),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// 3. Staggered entrance with flutter_animate + replay key.
// ------------------------------------------------------------------
class _StaggerDemo extends StatefulWidget {
  const _StaggerDemo();

  @override
  State<_StaggerDemo> createState() => _StaggerDemoState();
}

class _StaggerDemoState extends State<_StaggerDemo> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3 · Staggered entrance — flutter_animate',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const Text(
                        'delay: (i * 80).ms staggers each row. Changing the key replays the whole sequence.'),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _run++),
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Replay'),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s12),
          Column(
            key: ValueKey(_run), // new key → effects re-run
            children: [
              for (var i = 0; i < 5; i++)
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: Tokens.s4),
                  padding: const EdgeInsets.all(Tokens.s12),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer
                        .withValues(alpha: 0.35 + i * 0.12),
                    borderRadius:
                        BorderRadius.circular(Tokens.r12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.layers_outlined,
                          color: scheme.primary),
                      const SizedBox(width: Tokens.s12),
                      Text('Row ${i + 1} — delay ${(i * 80)}ms',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: (i * 80).ms, duration: 350.ms)
                    .slideX(begin: 0.12, end: 0),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// 4. Hero: tap a tile to fly it into a detail route.
// ------------------------------------------------------------------
class _HeroDemo extends StatelessWidget {
  const _HeroDemo();

  static const _tiles = [
    (Color(0xFF7C5CFF), Icons.rocket_launch_outlined, 'Launch'),
    (Color(0xFF0E9F8A), Icons.explore_outlined, 'Explore'),
    (Color(0xFFE14E9A), Icons.favorite_outline, 'Loved'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('4 · Hero — shared element transition',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const Text(
              'Matching Hero tags on two routes morph one into the other. Tap a tile.'),
          const SizedBox(height: Tokens.s12),
          Row(
            children: [
              for (final t in _tiles)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Tokens.s4),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => _HeroDetail(
                                color: t.$1,
                                icon: t.$2,
                                label: t.$3)),
                      ),
                      child: Hero(
                        tag: 'hero-${t.$3}',
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: t.$1,
                            borderRadius: BorderRadius.circular(
                                Tokens.r16),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(t.$2,
                                  color: Colors.white, size: 30),
                              const SizedBox(height: 4),
                              Text(t.$3,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroDetail extends StatelessWidget {
  const _HeroDetail(
      {required this.color, required this.icon, required this.label});
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Hero(
          tag: 'hero-$label',
          child: Container(
            width: 300,
            height: 380,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(Tokens.r24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 72),
                const SizedBox(height: Tokens.s12),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: Tokens.s8),
                const Text('Press back to fly home',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
