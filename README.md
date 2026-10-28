# Prism UI — Flutter Component Library

A browsable, **pure-frontend** Flutter component library: 30+ components in
6 categories, every demo shipped with its own source. Zero backend, zero API
keys — it builds to static files and deploys to GitHub Pages.

**Live areas:** Foundations (Overview, Theming studio) · Data display
(Dashboard, Charts lab) · Commerce (Storefront) · Media (Music player) ·
Messaging (Chat) · Motion (Motion lab).

## Try it

```bash
flutter pub get
flutter run -d chrome
```

Open `http://localhost:8099` — or the served release build below — and:
resize through **Phone / Tablet / Desktop** (the app-bar badge shows the
live breakpoint), flip light/dark, change the seed colour, and tap **Code**
on any page to read its source.

## Release build + Pages deploy

```bash
python tool/sync_code_assets.py   # bundle lib/*.dart for the Code buttons
flutter analyze                   # must report no issues
flutter build web --release --base-href="/<repo>/"
cd build/web && python -m http.server 8099
```

Pushing to `main` triggers `.github/workflows/pages.yml`: sync → analyze →
build with the repo name as base-href → deploy to GitHub Pages. See
`docs/07-github-pages.md` (the base-href rule is the #1 blank-page cause).

## Structure

```
lib/main.dart            ProviderScope + PrismApp (two lines)
lib/src/app/             shell, catalogue, theme, state
  catalog.dart           THE list: categories → demos → code-asset paths
  app.dart               MaterialApp + responsive Shell (rail/drawer/badge)
  theme.dart             Material 3 light/dark from one seed colour
  state.dart             Riverpod notifiers (section, theme, seed, cart)
lib/src/core/            shared building blocks
  tokens.dart            spacing, radii, breakpoints, seed options
  data.dart              ALL mock data (the "fake backend")
  widgets.dart           Aurora, GlassCard, SectionHeader, StatTile, MaxWidth
  code_view.dart         Code button + source sheet (full file + per-widget chips)
lib/src/modules/         one file per component demo (10 files)
tool/sync_code_assets.py lib/**/*.dart → assets/code/ (flat, see script)
docs/                    00–09 topic guides + LEARNING-PATH.md
```

## Docs reading order

`docs/LEARNING-PATH.md` first — ordered exercises with checkboxes.
Reference: 01 setup · 02 design system · 03 responsive · 04 state ·
05 animations · 06 charts · 07 pages deploy · 08 growing the library.

## Conventions

- Screens read `Theme.of(context)` (never hex) so the theming studio
  re-skins them; content art (album gradients) is the exception.
- Numbers from `Tokens`, shared chrome from `core/widgets.dart`.
- Riverpod notifiers for shared state, `setState` for local state.
- Every source file header names its techniques and its doc.
- `flutter analyze` stays at **no issues** — the Pages workflow enforces it.
