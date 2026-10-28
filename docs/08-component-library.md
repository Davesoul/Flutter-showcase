# 08 · The component library

How the library is organised and how to grow it.

## Catalogue (`lib/src/app/catalog.dart`)

One list rules everything: categories → sections → demo widget → bundled
code path. The rail, the grouped drawer, the Overview index and the Code
buttons all read from `kCategories`/`kSections`, so they can never drift
apart. `categoryOf(index)` derives the eyebrow for any page.

## Code buttons (`lib/src/core/code_view.dart`)

`CodeAction(assetPath:)` in each demo header opens a bottom sheet that
loads the page's own source via `rootBundle.loadString` + copy button.
Sources get there via:

```
tool/sync_code_assets.py   # lib/**/*.dart → assets/code/*.dart (flat)

The sheet also builds an outline — one chip per class/mixin/extension —
and tapping a chip extracts just that block (brace-matched, strings and
comments skipped, /// docs included). That is the per-widget view: open
Code on any page, tap `_BudgetRow`, and you read only `_BudgetRow`.
```

declared in pubspec `assets:`. The Pages workflow runs the sync before
every build, so deployed code is always current. Forgot locally? The
sheet prints the exact recovery command.

## Adding a component (the recipe)

1. **Data** (if any): const model + list in `core/data.dart`.
2. **Widget**: build it in `core/widgets.dart` if 2+ demos will reuse it,
   else privately inside the demo file.
3. **Demo**: new file `lib/src/modules/<name>_page.dart` — open with a
   `SectionHeader(eyebrow: '<Category>', …, action: CodeAction(assetPath:
   'assets/code/lib/src/modules/<name>_page.dart'))`.
4. **Register**: append a `Section(...)` under the right `Category` in
   `catalog.dart`. Rail, drawer, overview and code path update themselves.
5. **Sync + verify**: `python tool/sync_code_assets.py`,
   `flutter analyze` (zero errors), `flutter build web --release`.

## Conventions that keep it coherent

- Screens read `Theme.of(context)` — never hex — so the theming studio
  re-skins them (content art like album gradients is the exception).
- Numbers come from `Tokens`; shared chrome from `core/widgets.dart`.
- Every file header names its techniques + points at its doc.
- `setState` for local, Notifiers for shared (see 04-state-management).

**Exercise:** add a "Toast / Snackbar" component under Foundations:
widget in core, demo page, catalogue entry, Code button. Time yourself —
it should take under 20 minutes.
