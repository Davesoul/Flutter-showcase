# 03 · Responsive layout

One codebase, three shells. The rule: **branch the chrome, never the content.**

## Breakpoints (`tokens.dart`)

| Width | Shell | Badge |
|---|---|---|
| ≥ 1100 | Extended `NavigationRail` (icons + labels) | Desktop |
| 720–1099 | Compact `NavigationRail` (icons) | Tablet |
| < 720 | `Drawer` + hamburger | Phone |

Implemented in `Shell.build` (`lib/src/app/app.dart`) with a single
`MediaQuery.widthOf(context)` read. The body is always
`kSections[index].page` — identical widget tree at every width.

## Patterns used in demos

- **Side-by-side → stacked:** `LayoutBuilder` on the page's own
  constraints (dashboard chart + budgets, music art + playlist, motion
  pairs). LayoutBuilder is preferred over MediaQuery inside pages because
  it reacts to the *available* width, not the window.
- **Adaptive grids:** `SliverGridDelegateWithMaxCrossAxisExtent`
  (commerce) picks column count from width — no breakpoint math.
  `SliverGridDelegateWithFixedCrossAxisCount` (overview) switches 3/2/1
  columns at 800/520px.
- **Wrapping rows:** KPI tiles and hero CTAs use `Wrap`, so narrow
  screens flow instead of overflowing.
- **Cap + centre:** every page wraps its body in `MaxWidth` (1160px) so
  ultrawide monitors get margins, not stretched lines.

## Proving it

The app-bar badge (`Desktop · 1440px`) names the live breakpoint — resize
and watch it flip. Overflow debugging: run with `--dart-define` … no,
just open DevTools' overflow overlay; `Wrap` + `LayoutBuilder` mean you
should find zero overflow banners at 360px.

**Exercise:** shrink to 360px wide, visit every demo, screenshot each.
Then add a 4th breakpoint (e.g. watch-size rail hiding) and note what
breaks — that friction is the lesson.
