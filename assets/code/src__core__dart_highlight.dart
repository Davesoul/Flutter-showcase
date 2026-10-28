// Dart syntax highlighter for the in-app code viewer.
//
// Hand-rolled single-pass scanner, zero packages: comments, strings,
// annotations, keywords, numbers and type names each get a colour derived
// from the active ColorScheme — so highlighting re-skins with the theming
// studio like everything else. Used by CodeSheet (core/code_view.dart)
// and dogfooded by the Dart 101 page (modules/learn_page.dart).
//
// Supported: // and /* */ comments, '...' "..." and triple-quoted strings
// (with escapes), @annotations, integer/hex/double literals, the Dart
// keyword set, and UpperCamelCase type names. Deliberately NOT supported:
// string interpolation spans (the whole literal stays one colour) and
// error recovery — source shown here is always valid.
library;

import 'package:flutter/material.dart';

const Set<String> _keywords = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case',
  'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred',
  'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
  'external', 'factory', 'false', 'final', 'finally', 'for', 'Function',
  'get', 'hide', 'if', 'implements', 'import', 'in', 'interface', 'late',
  'library', 'mixin', 'new', 'null', 'of', 'on', 'operator', 'part',
  'required', 'rethrow', 'return', 'sealed', 'set', 'show', 'static',
  'super', 'switch', 'sync', 'this', 'throw', 'true', 'try', 'typedef',
  'var', 'void', 'while', 'with', 'yield',
};

/// One coloured run; adjacent runs of the same style are merged so a
/// 400-line file becomes dozens of spans, not thousands.
class _Run {
  _Run(this.style, this.text);
  final TextStyle style;
  String text;
}

/// Highlight [src] as Dart, coloured from [scheme].
TextSpan highlightDart(String src, ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  final keywordStyle =
      TextStyle(color: scheme.primary, fontWeight: FontWeight.w600);
  final stringStyle = TextStyle(
      color: dark ? const Color(0xFF8FD69A) : const Color(0xFF1C7A3C));
  final commentStyle = TextStyle(
      color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic);
  final numberStyle = TextStyle(
      color: dark ? const Color(0xFF82B4FF) : const Color(0xFF0B5CAD));
  final annotationStyle = TextStyle(
      color: dark ? const Color(0xFFE8B93E) : const Color(0xFF9A6B0F));
  final typeStyle =
      TextStyle(color: scheme.tertiary, fontWeight: FontWeight.w600);
  final plainStyle = TextStyle(color: scheme.onSurface);

  final runs = <_Run>[];
  void add(TextStyle s, String t) {
    if (t.isEmpty) return;
    if (runs.isNotEmpty && identical(runs.last.style, s)) {
      runs.last.text += t;
    } else {
      runs.add(_Run(s, t));
    }
  }

  var i = 0;
  while (i < src.length) {
    final c = src[i];
    final n = i + 1 < src.length ? src[i + 1] : '';
    if (c == '/' && n == '/') {
      // line comment
      var j = src.indexOf('\n', i);
      j = j < 0 ? src.length : j;
      add(commentStyle, src.substring(i, j));
      i = j;
    } else if (c == '/' && n == '*') {
      // block comment
      var j = src.indexOf('*/', i + 2);
      j = j < 0 ? src.length : j + 2;
      add(commentStyle, src.substring(i, j));
      i = j;
    } else if (c == "'" || c == '"') {
      // string (possibly triple-quoted), honouring backslash escapes
      final q = src.startsWith(c * 3, i) ? c * 3 : c;
      var j = i + q.length;
      while (j < src.length) {
        if (src[j] == '\\') {
          j += 2;
          continue;
        }
        if (src.startsWith(q, j)) {
          j += q.length;
          break;
        }
        j++;
      }
      j = j.clamp(0, src.length);
      add(stringStyle, src.substring(i, j));
      i = j;
    } else if (c == '@' && _isIdStart(n)) {
      var j = i + 1;
      while (j < src.length && _isIdPart(src[j])) {
        j++;
      }
      add(annotationStyle, src.substring(i, j));
      i = j;
    } else if (_isDigit(c)) {
      // number: decimal, hex (0xFF), or dotted double
      var j = i;
      if (c == '0' && (n == 'x' || n == 'X')) {
        j += 2;
        while (j < src.length &&
            (_isDigit(src[j]) ||
                (src[j].codeUnitAt(0) >= 97 &&
                    src[j].codeUnitAt(0) <= 102) ||
                (src[j].codeUnitAt(0) >= 65 &&
                    src[j].codeUnitAt(0) <= 70) ||
                src[j] == '_')) {
          j++;
        }
      } else {
        while (j < src.length &&
            (_isDigit(src[j]) || src[j] == '_')) {
          j++;
        }
        if (j + 1 < src.length &&
            src[j] == '.' &&
            _isDigit(src[j + 1])) {
          j++;
          while (j < src.length &&
              (_isDigit(src[j]) || src[j] == '_')) {
            j++;
          }
        }
      }
      add(numberStyle, src.substring(i, j));
      i = j;
    } else if (_isIdStart(c)) {
      var j = i + 1;
      while (j < src.length && _isIdPart(src[j])) {
        j++;
      }
      final word = src.substring(i, j);
      if (_keywords.contains(word)) {
        add(keywordStyle, word);
      } else if (_isUpper(word[0])) {
        add(typeStyle, word);
      } else {
        add(plainStyle, word);
      }
      i = j;
    } else {
      add(plainStyle, c);
      i++;
    }
  }
  return TextSpan(
      children: [for (final r in runs) TextSpan(text: r.text, style: r.style)]);
}

bool _isDigit(String c) {
  final u = c.codeUnitAt(0);
  return u >= 48 && u <= 57;
}

bool _isUpper(String c) {
  final u = c.codeUnitAt(0);
  return u >= 65 && u <= 90;
}

bool _isIdStart(String c) {
  if (c.isEmpty) return false;
  final u = c.codeUnitAt(0);
  return (u >= 65 && u <= 90) ||
      (u >= 97 && u <= 122) ||
      u == 95 ||
      u == 36; // _ and $
}

bool _isIdPart(String c) => _isIdStart(c) || _isDigit(c);
