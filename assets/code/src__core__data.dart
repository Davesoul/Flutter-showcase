// Mock domain data for every showcase module.
//
// 100% LOCAL — no backend, no network, no API keys. Everything the UI
// renders comes from these lists, which is exactly why this project
// deploys to GitHub Pages with zero infrastructure. When you later add a
// real backend, these classes become your DTOs and only the *source*
// changes (e.g. a Riverpod `FutureProvider`), not the widgets.
//
// Each model is immutable (`const` constructor + final fields) so widgets
// can freely share instances without defensive copies.
library;

import 'package:flutter/material.dart';

// ------------------------------------------------------------------
// Fintech dashboard
// ------------------------------------------------------------------
class Tx {
  const Tx(this.title, this.detail, this.time, this.amount, this.icon,
      this.tint);
  final String title;
  final String detail;
  final String time;
  final double amount; // negative = money out
  final IconData icon;
  final Color tint;
}

const List<Tx> kTransactions = [
  Tx('Aurora Coffee', 'Dining · Card •• 4412', '09:42', -6.40,
      Icons.coffee_outlined, Color(0xFFB4703A)),
  Tx('Salary — Studio North', 'Income · Transfer', '08:00', 4850.00,
      Icons.work_outline, Color(0xFF0E9F8A)),
  Tx('Metro Pass', 'Transport · Card •• 8810', 'Yesterday', -34.00,
      Icons.train_outlined, Color(0xFF2F7DE1)),
  Tx('Prism Pro', 'Subscriptions', 'Yesterday', -12.99,
      Icons.bolt_outlined, Color(0xFF7C5CFF)),
  Tx('Freelance payout', 'Income · Transfer', 'Tue', 920.00,
      Icons.payments_outlined, Color(0xFF0E9F8A)),
  Tx('Bookstore', 'Shopping · Card •• 4412', 'Tue', -48.25,
      Icons.menu_book_outlined, Color(0xFFE14E9A)),
];

/// 12-point balance sparkline (in thousands).
const List<double> kBalanceSeries = [
  4.2, 4.5, 4.3, 4.8, 5.1, 4.9, 5.4, 5.8, 5.6, 6.1, 6.4, 6.9
];

class Budget {
  const Budget(this.label, this.spent, this.limit, this.icon);
  final String label;
  final double spent;
  final double limit;
  final IconData icon;
  double get ratio => (spent / limit).clamp(0.0, 1.0);
}

const List<Budget> kBudgets = [
  Budget('Dining', 320, 500, Icons.restaurant_outlined),
  Budget('Transport', 140, 200, Icons.directions_bus_outlined),
  Budget('Shopping', 610, 800, Icons.shopping_bag_outlined),
  Budget('Fun', 180, 250, Icons.celebration_outlined),
];

// ------------------------------------------------------------------
// Commerce
// ------------------------------------------------------------------
class Product {
  const Product(
      this.id, this.name, this.price, this.rating, this.tag, this.icon,
      this.colors);
  final String id;
  final String name;
  final double price;
  final double rating;
  final String tag;
  final IconData icon;
  final List<Color> colors; // gradient tile background
}

const List<Product> kProducts = [
  Product('p1', 'Nebula Headphones', 249.00, 4.9, 'Best seller',
      Icons.headphones_outlined, [Color(0xFF2B2E6B), Color(0xFF7C5CFF)]),
  Product('p2', 'Drift Watch S', 399.00, 4.8, 'New',
      Icons.watch_outlined, [Color(0xFF0B3B39), Color(0xFF0E9F8A)]),
  Product('p3', 'Lumen Lamp', 89.00, 4.7, 'Low stock',
      Icons.lightbulb_outline, [Color(0xFF5B3413), Color(0xFFD9930D)]),
  Product('p4', 'Orbit Speaker', 179.00, 4.8, 'Best seller',
      Icons.speaker_outlined, [Color(0xFF4A1230), Color(0xFFE14E9A)]),
  Product('p5', 'Field Backpack', 129.00, 4.6, 'New',
      Icons.backpack_outlined, [Color(0xFF1E3A5F), Color(0xFF2F7DE1)]),
  Product('p6', 'Mono Keyboard', 159.00, 4.9, 'Limited',
      Icons.keyboard_outlined, [Color(0xFF3A2B2B), Color(0xFFC8553D)]),
];

// ------------------------------------------------------------------
// Music
// ------------------------------------------------------------------
class Track {
  const Track(this.title, this.artist, this.length, this.colors);
  final String title;
  final String artist;
  final Duration length;
  final List<Color> colors;
}

const List<Track> kTracks = [
  Track('Midnight Circuit', 'Glass Animals RMX', Duration(minutes: 3, seconds: 24),
      [Color(0xFF2B2E6B), Color(0xFF7C5CFF)]),
  Track('Solar Drift', 'Aurora Fields', Duration(minutes: 4, seconds: 2),
      [Color(0xFF5B3413), Color(0xFFD9930D)]),
  Track('Neon Tide', 'Velvet Static', Duration(minutes: 2, seconds: 58),
      [Color(0xFF0B3B39), Color(0xFF0E9F8A)]),
  Track('Paper Moons', 'Cassette Club', Duration(minutes: 3, seconds: 41),
      [Color(0xFF4A1230), Color(0xFFE14E9A)]),
  Track('Low Orbit', 'Satellite Youth', Duration(minutes: 3, seconds: 12),
      [Color(0xFF1E3A5F), Color(0xFF2F7DE1)]),
];

// ------------------------------------------------------------------
// Chat
// ------------------------------------------------------------------
class ChatMsg {
  const ChatMsg(this.text, this.time, this.me);
  final String text;
  final String time;
  final bool me;
}

const List<ChatMsg> kInitialMessages = [
  ChatMsg('Hey! Is this the Flutter showcase?', '10:02', false),
  ChatMsg('Yes — everything here runs 100% locally.', '10:03', true),
  ChatMsg('No backend at all? Even the charts?', '10:03', false),
  ChatMsg('Correct. Mock data + fl_chart + Riverpod.', '10:04', true),
];

// ------------------------------------------------------------------
// Analytics chart series (shared by dashboard + charts lab).
// ------------------------------------------------------------------
const List<double> kWeeklyActive = [42, 68, 55, 90, 76, 120, 104];
const List<String> kWeekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class Slice {
  const Slice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

const List<Slice> kTrafficMix = [
  Slice('Direct', 38, Color(0xFF7C5CFF)),
  Slice('Search', 27, Color(0xFF0E9F8A)),
  Slice('Social', 21, Color(0xFFE14E9A)),
  Slice('Referral', 14, Color(0xFFD9930D)),
];
