# 04 · State management

Two tools, chosen by scope. The codebase says which it uses and why.

## Riverpod Notifiers — shared state (`lib/src/app/state.dart`)

Used when more than one widget needs the value:

| Provider | Type | Readers |
|---|---|---|
| `sectionIndexProvider` | `int` | shell, drawer, overview cards |
| `themeModeProvider` | `ThemeMode` | MaterialApp + every screen |
| `seedColorProvider` | `Color` | MaterialApp + theming studio |
| `cartProvider` | `Set<String>` | badge, cards, detail sheet |
| `transactionsProvider` | `List<Tx>` | dashboard list + Add form |

`NotifierProvider` (not the older `StateProvider`) compiles on Riverpod
2.x and 3.x. Logic lives next to state (`toggle()`, `select()`, `clear()`),
and a `Set` gives O(1) add/remove with no duplicates for the cart.

Read with `ref.watch(...)`, write with
`ref.read(provider.notifier).method(...)` — never pass callbacks down
three levels when a provider reaches anywhere.

## setState — local state

Used when exactly one widget cares: music player position/playing,
chat message list + typing flag, motion toggles, theming switches.
Cheapest tool that works; no provider ceremony.

## The commerce handshake (study this)

`CommercePage` (ConsumerWidget) watches `cartProvider` for the badge.
`_DetailSheet` (separate route!) writes it on tap. No callbacks cross the
`showModalBottomSheet` boundary — the provider is the bridge. This is the
core Riverpod pattern: **shared mutable state without prop drilling.**

**Exercise:** add cart quantities (`Map<String,int>`). Update `toggle`,
badge total, and the detail button. Notice how many widgets change: zero —
only the notifier and the two readers.
