// SETUP — from zero to running Flutter, then running THIS project.
//
// Written for a true beginner on Windows: install the SDK, prove it with
// `flutter doctor`, create a throwaway app, then open Prism UI. Every
// command is copyable (tap the icon). If you already code, skim to step 4.
library;

import 'package:flutter/material.dart';

import '../core/code_view.dart';
import '../core/snippet_box.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                eyebrow: 'Foundations',
                title: 'Setup from zero',
                subtitle:
                    'Install Flutter, prove it works, run your first app.',
                action: CodeAction(
                    assetPath:
                        'assets/code/src__modules__setup_page.dart'),
              ),
              const SizedBox(height: Tokens.s16),
              for (var i = 0; i < _steps.length; i++)
                _StepCard(number: i + 1, step: _steps[i]),
              const SizedBox(height: Tokens.s16),
              const SectionHeader(
                eyebrow: 'Troubleshooting',
                title: 'When something complains',
              ),
              const SizedBox(height: Tokens.s8),
              for (final t in _trouble) _TroubleCard(entry: t),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  const _Step(this.title, this.body, this.commands);
  final String title;
  final String body;
  final List<String> commands; // one SnippetBox each, terminal tag
}

const List<_Step> _steps = [
  _Step(
    'Install the Flutter SDK',
    'Two supported ways on Windows. Either works — pick one, then close '
    'and reopen your terminal so PATH updates apply.',
    [
      '# Option A — winget (one line):\nwinget install --id=Google.Flutter -e',
      '# Option B — manual:\n# 1. Download the SDK zip from docs.flutter.dev\n# 2. Unzip to C:\\src\\flutter (no spaces in the path!)\n# 3. Add C:\\src\\flutter\\bin to your user PATH',
    ],
  ),
  _Step(
    'Prove it with flutter doctor',
    'This command checks every dependency and tells you exactly what is '
    'missing. A clean web-only setup needs checkmarks on Flutter, Chrome '
    'and (optionally) Android Studio — VS Code issues are fixed in step 3.',
    [
      'flutter doctor',
      '# Web-only shortcut: Chrome counts as a full target.\n# No Android SDK needed unless you want a phone emulator.',
    ],
  ),
  _Step(
    'Install an editor',
    'VS Code with the Flutter + Dart extensions gives you run/debug '
    'buttons, hot reload on save and widget guides. Android Studio works '
    'too — the extensions are what matter, not the editor.',
    [
      '# In VS Code, install these two extensions:\n#   1. "Flutter" (by Dart Code)\n#   2. "Dart" (installed automatically with it)',
    ],
  ),
  _Step(
    'Create and run a throwaway app',
    'Never learn inside a project you care about first. This makes a tiny '
    'counter app, enables web, and runs it in Chrome with hot reload — '
    'save a file and the browser updates in under a second.',
    [
      'flutter config --enable-web',
      'flutter create hello_first',
      'cd hello_first',
      'flutter run -d chrome',
    ],
  ),
  _Step(
    'Open THIS project',
    'Prism UI is a normal Flutter project. Same three commands as any app: '
    'get packages, run. The sync script bundles the .dart sources so the '
    'Code buttons show current code — the Pages workflow runs it for you.',
    [
      'cd D:\\Coding\\flutter-prism-lab',
      'flutter pub get',
      'python tool/sync_code_assets.py',
      'flutter run -d chrome',
    ],
  ),
];

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.step});
  final int number;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Tokens.s12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Numbered badge: steps read top-to-bottom, never skip.
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$number',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: Tokens.s12),
                Expanded(
                  child: Text(step.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: Tokens.s8),
            Text(step.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Tokens.s8),
            for (final cmd in step.commands) ...[
              SnippetBox(code: cmd, tag: 'terminal'),
              const SizedBox(height: Tokens.s8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Trouble {
  const _Trouble(this.symptom, this.fix);
  final String symptom;
  final String fix;
}

const List<_Trouble> _trouble = [
  _Trouble('“flutter is not recognized”',
      'PATH did not update: close EVERY terminal/VS Code window and reopen. Then `flutter --version`.'),
  _Trouble('flutter doctor shows red X on Android',
      'Web-only developers can ignore it. Need a phone emulator later? Install Android Studio and re-run doctor.'),
  _Trouble('flutter pub get fails',
      'Run `flutter clean`, then `flutter pub get` again. Still failing = no internet on first run (packages download once).'),
  _Trouble('Google Fonts look wrong offline',
      'Plus Jakarta Sans downloads on first run and caches. One online run fixes every later offline run.'),
  _Trouble('Deployed page is blank white',
      'Wrong --base-href. Project sites need `--base-href="/<repo>/"`. See docs/07-github-pages.md.'),
  _Trouble('Code button shows an error, not source',
      'You edited code without re-running the sync: `python tool/sync_code_assets.py`, then rebuild.'),
];

class _TroubleCard extends StatelessWidget {
  const _TroubleCard({required this.entry});
  final _Trouble entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Tokens.s8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_outlined,
                    size: 18, color: theme.colorScheme.error),
                const SizedBox(width: Tokens.s8),
                Expanded(
                  child: Text(entry.symptom,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: Tokens.s4),
            Text(entry.fix, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
