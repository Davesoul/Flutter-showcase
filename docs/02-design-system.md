# 02 · Design system

All visual decisions live in **two files**. Everything else reads from them.

## Tokens (`lib/src/core/tokens.dart`)

- 4-pt spacing scale (`s4…s48`), radii (`r12…r24`)
- Breakpoints: `compactMax = 720`, `expandedMin = 1100`
- `maxContentWidth = 1160` — line length cap for wide screens
- `seeds` — the 6 curated seed colours for the theming studio

Rule: no magic numbers in screens. If a padding/radius/width appears
twice, it belongs in Tokens.

## Colour (`lib/src/app/theme.dart`)

`ColorScheme.fromSeed(seedColor:…, brightness:…)` generates the full
palette — primary, containers, surfaces, on-colors — for light AND dark
from **one** colour. Hand-picking 30 colours is how inconsistent UIs happen.

- Light is the default (`ThemeModeState.build → light` in state.dart).
- The theming studio writes `seedColorProvider`; `PrismApp` rebuilds
  `MaterialApp` with the new scheme, re-skinning all 8 demos instantly.
- Screens must read `Theme.of(context).colorScheme` — never hard-code
  hex — or they won't re-skin. (Demo tiles like album art intentionally
  use fixed gradients: content, not chrome.)

## Type

One family app-wide: `GoogleFonts.plusJakartaSansTextTheme()` applied to
`ThemeData.textTheme`. Keep Material's size scale, swap the voice. Code
viewing uses `GoogleFonts.robotoMono()`.

## Shared widgets (`lib/src/core/widgets.dart`)

The seed of the design system — compose these instead of restyling:

| Widget | Job |
|---|---|
| `AuroraBackground` | Animated gradient blobs (CustomPaint + one repeating controller) |
| `GlassCard` | Bordered surface card, tints with the scheme |
| `SectionHeader` | Eyebrow + title + subtitle + action slot; every demo opens with one |
| `StatTile` | Icon + value + label + delta for KPIs |
| `MaxWidth` | Centres content, caps width at 1160 |

**Exercise:** add a `PillTag` widget here, use it in two demos, watch both
themes style it for free.
