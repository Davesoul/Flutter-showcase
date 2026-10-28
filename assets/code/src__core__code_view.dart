// Code viewer: every demo page ships with a "Code" button that opens
// the page's own source in a bottom sheet — the FULL file or ONE widget.
//
// HOW IT WORKS
// ------------
// `tool/sync_code_assets.py` copies lib/**/*.dart into assets/code/,
// which pubspec.yaml declares as bundled assets. At runtime we load the
// file with rootBundle.loadString — still 100% static, no network.
//
// The sheet also parses an outline (every class/mixin/extension) with a
// RegExp and shows one chip per type. Tapping a chip extracts just that
// block: from the declaration to its matching closing brace. Matching is
// done by [_extractBlock], a tiny lexer that ignores braces inside
// strings and comments — so '${...}' interpolations can't fool it — and
// leading /// doc lines are pulled in so the snippet keeps its context.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart_highlight.dart';
import 'tokens.dart';

/// "Code" button for demo page headers. Opens [CodeSheet] for [assetPath],
/// e.g. 'assets/code/src__modules__dashboard_page.dart'.
class CodeAction extends StatelessWidget {
  const CodeAction({super.key, required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(Tokens.r24)),
        ),
        builder: (_) => CodeSheet(assetPath: assetPath),
      ),
      icon: const Icon(Icons.code, size: 18),
      label: const Text('Code'),
    );
  }
}

/// One type declaration found in a source file.
class _OutlineEntry {
  const _OutlineEntry(this.name, this.kind, this.start);
  final String name;
  final String kind; // 'class' | 'mixin' | 'extension'
  final int start; // offset of the declaration in the source
}

/// Every top-level type declaration in [src], in file order.
List<_OutlineEntry> _outline(String src) {
  // ^ with multiLine = start of each line; optional modifiers first.
  final re = RegExp(
    r'^(?:abstract\s+|sealed\s+|base\s+|final\s+)?(?:class|mixin|extension)\s+(\w+)',
    multiLine: true,
  );
  final out = <_OutlineEntry>[];
  for (final m in re.allMatches(src)) {
    final raw = m.group(0)!;
    final kind = raw.contains('extension')
        ? 'extension'
        : (raw.contains('mixin') && !raw.contains('class'))
            ? 'mixin'
            : 'class';
    out.add(_OutlineEntry(m.group(1)!, kind, m.start));
  }
  return out;
}

/// Extract one declaration block: leading /// doc (and @annotation) lines
/// plus everything through the matching closing brace. The scan skips
/// string literals (with escapes), // line comments and /* */ blocks, so
/// only real code braces affect the depth count.
String _extractBlock(String src, int start) {
  // 1. Pull in the /// doc lines directly above the declaration, so the
  //    snippet explains itself. Match starts at a line start (^ flag).
  var blockStart = start;
  var cursor = start - 1; // the '\n' ending the previous line
  while (cursor > 0) {
    final lineStart = src.lastIndexOf('\n', cursor - 1) + 1;
    final line = src.substring(lineStart, cursor).trim();
    if (line.startsWith('///') || line.startsWith('@')) {
      blockStart = lineStart;
      cursor = lineStart - 1;
    } else {
      break;
    }
  }
  // 2. Walk braces from the declaration's opening brace.
  final open = src.indexOf('{', start);
  if (open < 0) return src.substring(blockStart).trimRight();
  var depth = 0;
  var i = open;
  String? quote; // non-null while inside a '...' or "..." literal
  while (i < src.length) {
    final c = src[i];
    final n = i + 1 < src.length ? src[i + 1] : '';
    if (quote != null) {
      // Inside a string: only escapes and the closing quote matter.
      if (c == '\\') {
        i += 2;
        continue;
      }
      if (src.startsWith(quote, i)) {
        i += quote.length;
        quote = null;
        continue;
      }
      i++;
      continue;
    }
    if (c == '/' && n == '/') {
      i = src.indexOf('\n', i); // skip // comment
      if (i < 0) return src.substring(blockStart).trimRight();
      continue;
    }
    if (c == '/' && n == '*') {
      final end = src.indexOf('*/', i + 2); // skip /* */ comment
      i = end < 0 ? src.length : end + 2;
      continue;
    }
    if (c == "'" || c == '"') {
      quote = src.startsWith(c * 3, i) ? c * 3 : c; // triple or single
      i += quote.length;
      continue;
    }
    if (c == '{') depth++;
    if (c == '}') {
      depth--;
      if (depth == 0) return src.substring(blockStart, i + 1);
    }
    i++;
  }
  return src.substring(blockStart).trimRight(); // unbalanced: rest of file
}

class CodeSheet extends StatefulWidget {
  const CodeSheet({super.key, required this.assetPath});
  final String assetPath;

  @override
  State<CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends State<CodeSheet> {
  String? _full; // whole file once loaded
  String? _error;
  int _sel = -1; // -1 = full file, else index into the outline
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Loads the bundled source once; the sheet shows a spinner meanwhile.
  Future<void> _load() async {
    try {
      final text = await rootBundle.loadString(widget.assetPath);
      if (mounted) setState(() => _full = text);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Source not bundled for ${widget.assetPath}.\n\n'
            'Run:  python tool/sync_code_assets.py\n'
            'Then rebuild:  flutter build web --release');
      }
    }
  }

  String get _fileName => widget.assetPath.split('/').last;

  /// What the code box (and the copy button) currently shows.
  String _displayed(List<_OutlineEntry> outline) {
    if (_full == null) return '';
    if (_sel < 0 || _sel >= outline.length) return _full!;
    return _extractBlock(_full!, outline[_sel].start);
  }

  void _pick(int index) {
    setState(() => _sel = index);
    // Back to the top: snippets always start at their declaration.
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = _full == null ? const <_OutlineEntry>[] : _outline(_full!);
    final shown = _displayed(outline);
    final lines = shown.isEmpty ? 0 : '\n'.allMatches(shown).length + 1;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Tokens.s24, Tokens.s8, Tokens.s24, Tokens.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.insert_drive_file_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: Tokens.s8),
                Expanded(
                  child: Text(_fileName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  tooltip: 'Copy shown code',
                  onPressed: _full == null
                      ? null
                      : () async {
                          // Copies exactly what is on screen: full file
                          // or the selected widget — never stale text.
                          await Clipboard.setData(
                              ClipboardData(text: shown));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${_sel < 0 ? _fileName : outline[_sel].name} copied')),
                            );
                          }
                        },
                  icon: const Icon(Icons.copy_outlined),
                ),
              ],
            ),
            Text(
                '${widget.assetPath} · ${_full == null ? '…' : '$lines lines'}',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const Divider(height: Tokens.s24),
            if (_error != null)
              Text(_error!, style: theme.textTheme.bodyMedium)
            else if (_full == null)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else ...[
              // Widget navigator: Full file + one chip per type.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(right: Tokens.s8),
                      child: ChoiceChip(
                        label: const Text('Full file'),
                        selected: _sel == -1,
                        onSelected: (_) => _pick(-1),
                      ),
                    ),
                    for (var i = 0; i < outline.length; i++)
                      Padding(
                        padding:
                            const EdgeInsets.only(right: Tokens.s8),
                        child: ChoiceChip(
                          label: Text(outline[i].name),
                          avatar: Icon(
                            outline[i].kind == 'class'
                                ? Icons.widgets_outlined
                                : Icons.extension_outlined,
                            size: 16,
                          ),
                          selected: _sel == i,
                          onSelected: (_) => _pick(i),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius:
                        BorderRadius.circular(Tokens.r16),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.6)),
                  ),
                  padding: const EdgeInsets.all(Tokens.s16),
                  // Vertical scroll (with controller so chip taps reset
                  // to the top) wrapping horizontal scroll for long lines.
                  child: SingleChildScrollView(
                    controller: _scroll,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText.rich(
                        highlightDart(shown,
                            Theme.of(context).colorScheme),
                        style: GoogleFonts.robotoMono(
                            fontSize: 12.5, height: 1.55),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
