# 01 · Getting started

Prism UI is a **pure-frontend Flutter component library**: 30+ components
in 6 categories, all mock data, zero backend. It builds to static files
and deploys to GitHub Pages.

## Prereqs

- Flutter stable (built with 3.38.2, Dart 3.10)
- Chrome (for `flutter run -d chrome`)

## Run it

```bash
flutter pub get
flutter run -d chrome        # web dev build with hot reload
```

Resize the browser while running: ≥1100px shows the extended rail
(Desktop badge), 720–1099px the icon rail (Tablet), <720px a drawer
(Phone). The badge in the app bar always shows the live width.

## Build it

```bash
python tool/sync_code_assets.py   # bundle lib/*.dart for the Code buttons
flutter analyze                   # must report no errors
flutter build web --release       # output in build/web/
```

Preview the release build exactly as Pages will serve it:

```bash
cd build/web && python -m http.server 8099
# open http://localhost:8099
```

## Project map

```
lib/main.dart            two lines: ProviderScope + PrismApp
lib/src/app/             shell, catalogue, theme, state
  app.dart               MaterialApp + responsive Shell
  catalog.dart           THE list: categories → components → code paths
  theme.dart             Material 3 light/dark from one seed
  state.dart             Riverpod notifiers (section, theme, seed, cart)
lib/src/core/            shared building blocks
  tokens.dart            spacing, radii, breakpoints, seed options
  data.dart              ALL mock data (the "fake backend")
  widgets.dart           Aurora, GlassCard, SectionHeader, StatTile
  code_view.dart         Code button + source bottom sheet
lib/src/modules/        one file per component demo (8 files)
tool/sync_code_assets.py copies lib/*.dart → assets/code/ for Code buttons
docs/                   you are here — start with LEARNING-PATH.md
```

## Where to look first

1. `lib/src/app/catalog.dart` — the whole library in 60 lines.
2. `lib/src/core/tokens.dart` — every number the UI uses.
3. `lib/src/modules/theming_page.dart` — the design system made visible.
