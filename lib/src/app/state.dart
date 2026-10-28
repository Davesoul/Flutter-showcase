// Global UI state, managed with Riverpod `NotifierProvider`s.
//
// WHY RIVERPOD (and why Notifiers)?
// ---------------------------------
// Every showcase section needs to read shared state (which tab is active,
// light/dark, seed colour, cart contents) without prop-drilling it
// through ten constructors. Riverpod providers expose that state to any
// widget via `ref.watch(...)`, and `Notifier` classes keep the *logic*
// (toggle/select/clear) next to the state it mutates.
//
// `NotifierProvider` is used instead of the older `StateProvider` so this
// code compiles on both Riverpod 2.x and 3.x. See
// docs/04-state-management.md for a step-by-step explainer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data.dart';
import '../core/tokens.dart';

// ------------------------------------------------------------------
// Active showcase section (index into the section list in app.dart).
// ------------------------------------------------------------------
class SectionIndex extends Notifier<int> {
  @override
  int build() => 0; // the Overview page

  // Assigning state notifies every watcher and rebuilds them — this one
  // line IS the navigation system (see Shell in app.dart).
  void select(int index) => state = index;
}

final sectionIndexProvider =
    NotifierProvider<SectionIndex, int>(SectionIndex.new);

// ------------------------------------------------------------------
// Light / dark mode.
// ------------------------------------------------------------------
class ThemeModeState extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light; // light-first: library default

  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeState, ThemeMode>(ThemeModeState.new);

// ------------------------------------------------------------------
// Seed colour that generates the whole Material 3 palette.
// ------------------------------------------------------------------
class SeedColor extends Notifier<Color> {
  @override
  Color build() => Tokens.seeds.first.color;

  void set(Color color) => state = color;
}

final seedColorProvider = NotifierProvider<SeedColor, Color>(SeedColor.new);

// ------------------------------------------------------------------
// Commerce cart: a set of product ids. A Set (not a List) makes
// toggle/add/remove O(1) and guarantees no duplicates.
// ------------------------------------------------------------------
class Cart extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  bool contains(String id) => state.contains(id);

  // Never mutate state in place: {...state} copies first, so Riverpod
  // sees a NEW object identity and rebuilds. state.add() would silently
  // skip every watcher.
  void toggle(String id) {
    final next = {...state};
    if (!next.remove(id)) next.add(id); // remove() returns false if absent
    state = next;
  }

  void clear() => state = {};
}

final cartProvider = NotifierProvider<Cart, Set<String>>(Cart.new);

// ------------------------------------------------------------------
// Transactions: the dashboard ledger. Seeded from the mock data; the Add
// button prepends real entries (title + amount + direction).
// ------------------------------------------------------------------
class Transactions extends Notifier<List<Tx>> {
  @override
  List<Tx> build() => [...kTransactions];

  // Prepend: newest first. [tx, ...state] builds a NEW list — calling
  // state.insert() instead would mutate in place and skip rebuilds.
  void add(Tx tx) => state = [tx, ...state];
}

final transactionsProvider =
    NotifierProvider<Transactions, List<Tx>>(Transactions.new);
