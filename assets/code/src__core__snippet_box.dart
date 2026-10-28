// SnippetBox — one highlighted code block with a copy button.
//
// Shared by the Learn page (Dart samples) and the Setup page (terminal
// commands). Highlighting comes from core/dart_highlight.dart, which also
// handles non-Dart text gracefully: shell commands contain no Dart
// keywords, so they render as plain text with comments/strings still
// coloured — good enough for a command box.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart_highlight.dart';
import 'tokens.dart';

class SnippetBox extends StatelessWidget {
  const SnippetBox({super.key, required this.code, this.tag = 'dart'});
  final String code;
  final String tag; // small label, e.g. 'dart' or 'terminal'

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Tokens.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Tokens.r12),
        border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(tag.toUpperCase(),
                  style: GoogleFonts.robotoMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: scheme.onSurfaceVariant)),
              const Spacer(),
              // Copy beats retyping — especially for terminal commands.
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied')),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.copy_outlined,
                      size: 15, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: Tokens.s4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText.rich(
              highlightDart(code, scheme),
              style: GoogleFonts.robotoMono(fontSize: 12.5, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}
