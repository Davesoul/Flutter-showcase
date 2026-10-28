// THEMING STUDIO — live seed colours, dark mode, type + components.
//
// This page edits the SAME providers the whole app reads
// (seedColorProvider, themeModeProvider), so every change here
// re-skins all 8 modules instantly. That is the design-system pitch:
// one seed → whole palette, one toggle → whole app dark.
//
// Also serves as a component gallery: buttons, chips, switches,
// sliders and progress bars in one place for visual QA.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/state.dart';
import '../core/code_view.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class ThemingPage extends ConsumerWidget {
  const ThemingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final seed = ref.watch(seedColorProvider);
    final mode = ref.watch(themeModeProvider);
    final dark = mode == ThemeMode.dark;

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                eyebrow: 'Foundations',
                title: 'Theming studio',
                subtitle:
                    'Change the seed or brightness — every component re-skins live.',
                action: const CodeAction(
                    assetPath:
                        'assets/code/src__modules__theming_page.dart'),
              ),
              const SizedBox(height: Tokens.s16),
              // -- seed picker --------------------------------------
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seed colour',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: Tokens.s4),
                    Text(
                      'ColorScheme.fromSeed(seedColor: …) generates the full palette from this one colour.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: Tokens.s12),
                    Wrap(
                      spacing: Tokens.s12,
                      runSpacing: Tokens.s12,
                      children: [
                        for (final s in Tokens.seeds)
                          _SeedDot(
                            option: s,
                            selected: s.color.toARGB32() ==
                                seed.toARGB32(),
                            onTap: () => ref
                                .read(seedColorProvider.notifier)
                                .set(s.color),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s16),
              // -- brightness ----------------------------------------
              GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Brightness',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800)),
                          Text(
                              dark
                                  ? 'Dark scheme from the same seed.'
                                  : 'Light scheme from the same seed.',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined)),
                        ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined)),
                      ],
                      selected: {mode},
                      onSelectionChanged: (s) => ref
                          .read(themeModeProvider.notifier)
                          .set(s.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s16),
              // -- type specimen --------------------------------------
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Typography — Plus Jakarta Sans',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: Tokens.s8),
                    Text('Display — Aa Bb Cc 123',
                        style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900)),
                    Text('Headline — The quick brown fox',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800)),
                    Text('Title — Jumps over the lazy dog',
                        style: theme.textTheme.titleMedium),
                    Text(
                        'Body — One textTheme on ThemeData styles the entire app. '
                        'google_fonts loads Jakarta once; every Text inherits it.',
                        style: theme.textTheme.bodyMedium),
                    Text('LABEL · LETTERSPACED MICROcopy'.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s16),
              // -- component gallery: every control does something --------
              const _ComponentGallery(),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeedDot extends StatelessWidget {
  const _SeedDot(
      {required this.option, required this.selected, required this.onTap});
  final SeedOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: option.color.withValues(alpha: 0.5),
                          blurRadius: 16)
                    ]
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check,
                    color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(height: Tokens.s4),
          Text(option.name,
              style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Toggleables extends StatefulWidget {
  const _Toggleables();

  @override
  State<_Toggleables> createState() => _ToggleablesState();
}

class _ToggleablesState extends State<_Toggleables> {
  bool _switch = true;
  bool _check = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: _switch, onChanged: (v) => setState(() => _switch = v)),
        Checkbox(value: _check, onChanged: (v) => setState(() => _check = v!)),
      ],
    );
  }
}

/// Interactive component gallery: every control does something. The slider
/// and the progress bar share one value (the controlled-input pattern);
/// every button reports itself in the status line + a SnackBar.
class _ComponentGallery extends StatefulWidget {
  const _ComponentGallery();

  @override
  State<_ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<_ComponentGallery> {
  double _level = 0.65;
  int _presses = 0;
  String _last = 'nothing yet';

  void _tap(String label) {
    setState(() {
      _presses++;
      _last = label;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label pressed ($_presses total)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Components — live QA',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Tokens.s12, vertical: Tokens.s4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$_presses taps · last: $_last',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s12),
          Wrap(
            spacing: Tokens.s8,
            runSpacing: Tokens.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                  onPressed: () => _tap('Filled'),
                  child: const Text('Filled')),
              FilledButton.tonal(
                  onPressed: () => _tap('Tonal'),
                  child: const Text('Tonal')),
              OutlinedButton(
                  onPressed: () => _tap('Outlined'),
                  child: const Text('Outlined')),
              TextButton(
                  onPressed: () => _tap('Text'),
                  child: const Text('Text')),
              IconButton.filled(
                  onPressed: () => _tap('IconButton'),
                  icon: const Icon(Icons.add)),
              const Chip(
                  avatar: Icon(Icons.check, size: 16),
                  label: Text('Chip')),
              const _Toggleables(),
            ],
          ),
          const SizedBox(height: Tokens.s12),
          LinearProgressIndicator(value: _level),
          const SizedBox(height: Tokens.s8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _level,
                  onChanged: (v) => setState(() => _level = v),
                ),
              ),
              SizedBox(
                width: 52,
                child: Text('${(_level * 100).round()}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
