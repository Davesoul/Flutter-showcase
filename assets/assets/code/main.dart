// Prism Lab — entry point.
//
// This file is intentionally tiny. All wiring lives in `src/app/app.dart`
// so `main()` stays a readable two-liner. See docs/01-getting-started.md
// for the full project tour.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app.dart';

void main() {
  runApp(const ProviderScope(child: PrismApp()));
}
