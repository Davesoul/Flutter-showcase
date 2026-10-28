# 05 · Animations

Four techniques in the motion lab (`motion_page.dart`), cheapest first.
Open the lab, tap everything, then read the file top to bottom.

## 1. Implicit — `AnimatedContainer`

Describe the end state; Flutter tweens there. The morphing tile flips
width/height/colour/radius in `setState` — no controller, ~10 lines.
Rule: if you can express it as "these values change", use implicit
(`AnimatedContainer`, `AnimatedOpacity`, `AnimatedPadding`).

## 2. Crossfade — `AnimatedCrossFade`

Swaps skeleton → content with one widget that understands both sizes.
This is the standard loading transition: `crossFadeState` flips after a
`Future.delayed` (faking a fetch). Real app: flip it when your
`FutureProvider` resolves.

## 3. Staggered — `flutter_animate`

Declarative chains: `.animate().fadeIn(delay: (i*80).ms).slideX(...)`.
No controllers, no `TickerProvider`, per-item delays in one expression.
Replay trick: put the list under `ValueKey(run)` — changing the key
rebuilds the subtree and re-runs every effect.

## 4. Hero — shared element

Matching `Hero(tag:)` on two routes morphs one into the other.
Tags must be unique per route pair (`'hero-$label'`). The detail route
is a plain `MaterialPageRoute` — heroes work with the stock Navigator.

## Also in the app

- `AnimatedSwitcher` in the shell cross-fades demos on navigation.
- The aurora uses one repeating `AnimationController` + `CustomPainter`
  (decorative: `IgnorePointer`, repaints only itself).
- The cart badge pops via `.animate(target: count.toDouble()).scale(...)`
  — animating *toward* a changing target value.

**Exercise:** add a 5th card — `AnimatedContainer` progress ring that fills
on tap. Then rebuild the stagger demo with explicit `AnimationController`s
to feel why `flutter_animate` exists.
