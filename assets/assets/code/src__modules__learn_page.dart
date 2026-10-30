// LEARN — Dart 101 + the widget catalogue.
//
// For the true beginner: the 20% of Dart behind 80% of this library, each
// idea with a short sample rendered by OUR highlighter (dogfooding
// core/dart_highlight.dart); the widgets you will meet in every Flutter
// app, each with a one-screen usage sample; a complete first app you can
// read top to bottom; and a where-used table whose rows jump to the demo.
// Pair with Foundations → Setup (environment) and docs/09 (cheat sheet).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/catalog.dart';
import '../app/state.dart';
import '../core/code_view.dart';
import '../core/snippet_box.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open(String label) {
      final i = kSections.indexWhere((s) => s.label == label);
      if (i >= 0) ref.read(sectionIndexProvider.notifier).select(i);
    }

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                eyebrow: 'Foundations',
                title: 'Dart 101 & widgets',
                subtitle:
                    'The language subset and widget set behind this library.',
                action: CodeAction(
                    assetPath:
                        'assets/code/src__modules__learn_page.dart'),
              ),
              const SizedBox(height: Tokens.s16),
              const _Subhead('Dart in 14 ideas',
                  'Everything below appears verbatim somewhere in this codebase.'),
              const SizedBox(height: Tokens.s8),
              for (final idea in _ideas) _IdeaCard(idea: idea),
              const SizedBox(height: Tokens.s16),
              const _Subhead('Widgets you will use everywhere',
                  'If it is on screen, it is one of these — each with its smallest real usage.'),
              const SizedBox(height: Tokens.s8),
              for (final w in _widgets) _WidgetCard(entry: w),
              const SizedBox(height: Tokens.s16),
              const _Subhead('Your first working app',
                  '30 lines that run. Read top to bottom, then read the 5 steps.'),
              const SizedBox(height: Tokens.s8),
              _FirstAppCard(),
              const SizedBox(height: Tokens.s16),
              const _Subhead('Where this library uses them',
                  'Same widgets, real pages. Open one and read its Code tab.'),
              const SizedBox(height: Tokens.s8),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < _usages.length; i++)
                      _UsageRow(
                        usage: _usages[i],
                        last: i == _usages.length - 1,
                        onOpen: () => open(_usages[i].section),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Part 1: Dart ideas.
// ------------------------------------------------------------------
class _Idea {
  const _Idea(this.title, this.body, this.sample);
  final String title;
  final String body;
  final String sample;
}

const List<_Idea> _ideas = [
  _Idea(
    '1 · final vs const',
    'final = decided once at run time. const = decided at compile time, '
    'and canonicalised (identical consts share one object). Widgets love '
    'const: it lets Flutter skip rebuild work.',
    'final now = DateTime.now(); // runs now\nconst pad = 16.0;           // known forever',
  ),
  _Idea(
    '2 · Null safety (?, ??, !)',
    'Types are non-nullable by default. A trailing ? allows null; ?. calls '
    'only if non-null; ?? supplies a fallback. ! asserts non-null — the '
    'compiler trusts you, the runtime may not.',
    'String? name;                    // may be absent\nfinal len = name?.length ?? 0;   // safe chain + fallback',
  ),
  _Idea(
    '3 · Arrow functions',
    'One expression, no braces. Callbacks everywhere in Flutter are arrows: '
    'onPressed, builders, map(). If it needs two statements, use a block.',
    'onTap: () => select(i),\nfinal doubled = items.map((e) => e * 2).toList();',
  ),
  _Idea(
    '4 · Spread + collection-for',
    '... unpacks a list inline; for() inside a literal builds UI lists '
    'declaratively. Most "dynamic children" code in this library is one of '
    'these two lines.',
    'final all = [...a, ...b];\nchildren: [for (final t in ts) Tile(t)],',
  ),
  _Idea(
    '5 · Classes in one sip',
    'final fields + generative constructor. const constructor when all '
    'fields are final — like every model in core/data.dart.',
    'class Tx {\n  const Tx(this.title, this.amount);\n  final String title;\n  final double amount;\n}',
  ),
  _Idea(
    '6 · async / await',
    'await pauses THIS function, never the UI. The chat reply, the fake '
    'loading skeleton and the music ticker all lean on this.',
    'final res = await fetch();   // UI stays alive meanwhile\nFuture.delayed(const Duration(seconds: 1), reply);',
  ),
  _Idea(
    '7 · String interpolation',
    r'Stick $variable or ${expression} inside a string. That is how every '
    r'amount, count and label in this library is formatted.',
    r"'Balance: $amount';",
  ),
  _Idea(
    '8 · Control flow',
    'if/else for branches, for-in for iterating, switch for many-way '
    'choices. The drawer, the rail and every list in this app are for-ins '
    'in disguise.',
    'if (loggedIn) {\n  showHome();\n} else {\n  showLogin();\n}\nfor (final t in ts) {\n  print(t);\n}',
  ),
  _Idea(
    '9 · Functions & named parameters',
    'Positional params for the required core, {named} for options. '
    'required marks must-pass options; = gives defaults. Nearly every '
    'Flutter widget constructor works exactly like this.',
    'Widget tile({required String title, bool active = false}) {\n  return ListTile(title: Text(title), selected: active);\n}',
  ),
  _Idea(
    '10 · Lists & Maps',
    'List = ordered, index by number. Map = keyed, index by key. <String> '
    'and <String, int> are type arguments: they tell the compiler what '
    'the collection holds so mistakes fail fast.',
    r"final names = <String>[]; // typed empty list\nnames.add('ada');          // grow it\nfinal scores = <String, int>{'ada': 42};\nscores['bob'] = 7; // Maps work the same way",
  ),
  _Idea(
    '11 · Imports: packages vs files',
    'package: imports come from dependencies (pubspec). Relative imports '
    'are your own files. The rule: never import across packages with ../ '
    '— depend on it properly instead.',
    r"import 'package:flutter/material.dart'; // a package you depend on\nimport '../core/tokens.dart';           // your own file, relative",
  ),
  _Idea(
    '12 · main() & runApp()',
    'main is where execution starts; runApp inflates the widget tree and '
    'attaches it to the screen. lib/main.dart in this project is two '
    'lines — everything else is widgets.',
    'void main() {\n  runApp(const CounterApp()); // inflate the tree\n}',
  ),
  _Idea(
    '13 · The widget tree (read inside-out)',
    'A Flutter UI is widgets inside widgets. Read it inside-out: content '
    'at the center, layout around it, page frame outside, app outside '
    'that. Every demo page in this library has this exact shape.',
    r"MaterialApp(      // theme + navigation\n  home: Scaffold( // page frame\n    body: Center( // layout\n      child: Text('Hi'), // content\n    ),\n  ),\n);",
  ),
  _Idea(
    '14 · State & setState in 3 lines',
    'StatelessWidget = no memory, pure function of inputs. StatefulWidget '
    '+ State = memory that survives rebuilds. setState marks the widget '
    'dirty; Flutter re-runs build() and the UI reflects the new values.',
    r"""int count = 0; // the memory, lives in State
void bump() => setState(() => count++); // write + mark dirty
Text('$count'); // build() reads the variable""",
  ),
];

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.idea});
  final _Idea idea;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Tokens.s12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(idea.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: Tokens.s4),
            Text(idea.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Tokens.s8),
            SnippetBox(code: idea.sample),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Part 2: everyday widgets, each with its smallest real usage.
// ------------------------------------------------------------------
class _WidgetEntry {
  const _WidgetEntry(this.name, this.what, this.sample);
  final String name;
  final String what;
  final String sample;
}

const List<_WidgetEntry> _widgets = [
  _WidgetEntry('Scaffold', 'The page frame: app bar, body, floating button.',
      "Scaffold(\n  appBar: AppBar(title: Text('Shop')),\n  body: ProductGrid(),\n)"),
  _WidgetEntry('AppBar / Drawer / NavigationRail',
      'Top bar, side drawer, side rail — the three responsive shells.',
      'NavigationRail(\n  selectedIndex: i,\n  destinations: [...],\n)'),
  _WidgetEntry(
      'Text', 'Styled strings. Theme text styles keep sizes consistent.',
      "Text('Hello', style: TextStyle(fontWeight: FontWeight.bold))"),
  _WidgetEntry('Row / Column',
      'Horizontal / vertical layout. Main axis vs cross axis.',
      "Row(children: [Icon(Icons.star), Text('4.9')])"),
  _WidgetEntry('Expanded / Flexible',
      'Split leftover space inside a Row or Column.',
      "Row(children: [Icon(Icons.star), Expanded(child: Text('fills the rest'))])"),
  _WidgetEntry('Stack + Positioned',
      'Layer widgets: badge over art, hero text over gradient.',
      "Stack(children: [Icon(Icons.photo, size: 64), Positioned(right: 0, child: Badge(label: Text('2')))])"),
  _WidgetEntry('Container',
      'The box: padding, margin, colour, borders, gradients, shape.',
      "Container(padding: EdgeInsets.all(16), color: Colors.blue, child: Text('Hi'))"),
  _WidgetEntry('Padding / Center / Align',
      'Spacing primitives. Gaps are widgets, not margins.',
      "Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Hi')))"),
  _WidgetEntry('ListView',
      'Scrolling list. .builder for long or unknown lengths.',
      'ListView.builder(\n  itemCount: items.length,\n  itemBuilder: (c, i) => Tile(items[i]),\n)'),
  _WidgetEntry('GridView',
      'Scrolling grid. count/crossAxisExtent picks columns for you.',
      'GridView.count(\n  crossAxisCount: 2,\n  children: [...],\n)'),
  _WidgetEntry('Icon', 'Material icons render from a font — no assets.',
      'Icon(Icons.favorite, color: Colors.red, size: 32)'),
  _WidgetEntry('GestureDetector / InkWell',
      'Taps: silent (Detector) or with Material ripple (InkWell).',
      "InkWell(onTap: () => open(i), child: Text('Open'))"),
  _WidgetEntry('StatelessWidget / StatefulWidget',
      'Immutable UI vs UI with memory. setState marks "rebuild me".',
      'class Hi extends StatelessWidget {\n  const Hi({super.key});\n  @override\n  Widget build(BuildContext context) => const Text(\'Hi\');\n}'),
  _WidgetEntry('Navigator + MaterialPageRoute',
      'Push/pop routes. Hero animations ride on top of it.',
      'Navigator.push(\n  context,\n  MaterialPageRoute(builder: (_) => const Detail()),\n)'),
  _WidgetEntry('FutureBuilder',
      'Render an AsyncSnapshot: spinner → data or error.',
      'FutureBuilder<String>(\n  future: loadName(),\n  builder: (c, snap) => snap.hasData\n      ? Text(snap.data!)\n      : const CircularProgressIndicator(),\n)'),
  _WidgetEntry('Switch / Checkbox / Slider',
      'Inputs with (value, onChanged) — the controlled-input pattern.',
      'Switch(\n  value: soundOn,\n  onChanged: (v) => setState(() => soundOn = v),\n)'),
];

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({required this.entry});
  final _WidgetEntry entry;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(Tokens.s8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Tokens.r12),
                  ),
                  child: Text(entry.name[0],
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color:
                              theme.colorScheme.onPrimaryContainer)),
                ),
                const SizedBox(width: Tokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(entry.what,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme
                                  .colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Tokens.s8),
            SnippetBox(code: entry.sample),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Part 3: the smallest complete app. Copy it into `flutter create`
// output and run it — then change the Text and watch hot reload.
// -------------------------------------------------------------------
const String _firstApp = r"""import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CounterPage());
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int count = 0; // the memory

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My first app')),
      body: Center(child: Text('$count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}""";

const List<(String, String)> _firstSteps = [
  ('main runs first',
      'runApp takes your root widget and attaches it to the screen.'),
  ('CounterApp never changes',
      'Stateless: same inputs, same UI. It just names the MaterialApp.'),
  ('CounterPage has memory',
      'Stateful + createState: the State object outlives rebuilds, so count survives.'),
  ('count lives in State',
      'A plain int field. build() reads it; the button writes it.'),
  ('setState rebuilds',
      'It marks the widget dirty; Flutter re-runs build() and the Text shows the new count.'),
];

class _FirstAppCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('main.dart, complete',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: Tokens.s4),
          Text(
              'Paste into any `flutter create` project, `flutter run -d chrome`.',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: Tokens.s8),
          const SnippetBox(code: _firstApp),
          const SizedBox(height: Tokens.s8),
          for (var i = 0; i < _firstSteps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Tokens.s4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary)),
                  Expanded(
                    child: Text(
                        '${_firstSteps[i].$1} — ${_firstSteps[i].$2}',
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// Part 4: where the library uses them.
// ------------------------------------------------------------------
class _Usage {
  const _Usage(this.widget, this.where, this.section);
  final String widget;
  final String where;
  final String section;
}

const List<_Usage> _usages = [
  _Usage('ColorScheme.fromSeed', 'one seed → whole palette (theme.dart)',
      'Theming'),
  _Usage('SegmentedButton', 'light/dark switch (theming_page.dart)',
      'Theming'),
  _Usage('CustomPaint', 'aurora blobs (widgets.dart)', 'Overview'),
  _Usage('GridView', 'responsive product grid (commerce_page.dart)',
      'Storefront'),
  _Usage('showModalBottomSheet + Badge', 'detail sheet + cart count',
      'Storefront'),
  _Usage('NotifierProvider', 'cart + section + theme (state.dart)',
      'Storefront'),
  _Usage('LineChart / BarChart / PieChart',
      'trend, compare, compose (charts_page.dart)', 'Charts'),
  _Usage('Timer + Slider', 'fake playback (music_page.dart)',
      'Music player'),
  _Usage('ListView + typing dots', 'chat with local replies', 'Chat'),
  _Usage('Hero + AnimatedContainer', 'shared-element tile (motion_page.dart)',
      'Motion lab'),
];

class _UsageRow extends StatelessWidget {
  const _UsageRow(
      {required this.usage, required this.last, required this.onOpen});
  final _Usage usage;
  final bool last;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5))),
      ),
      child: ListTile(
        title: Text(usage.widget,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        subtitle: Text(usage.where),
        trailing: TextButton(
          onPressed: onOpen,
          child: Text('Open ${usage.section}'),
        ),
      ),
    );
  }
}

class _Subhead extends StatelessWidget {
  const _Subhead(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900)),
        Text(subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
