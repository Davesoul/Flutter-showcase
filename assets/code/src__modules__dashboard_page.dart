// DASHBOARD — premium fintech overview.
//
// TECHNIQUES ON DISPLAY
// ---------------------
// • fl_chart LineChart with a curved series + gradient fill
// • KPI stat tiles composed from a shared widget (core/widgets.dart)
// • Budget bars built from LinearProgressIndicator (zero dependencies)
// • A transaction list with leading icon chips and +/- amounts
// All data comes from core/data.dart — swap that file for a
// FutureProvider later and this screen won't change.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/state.dart';
import '../core/code_view.dart';
import '../core/data.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  /// true = 12 months, false = last 30 days (tail of the series).
  /// sublist() is a VIEW, not a copy — one source of truth either way.
  bool _longRange = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final txns = ref.watch(transactionsProvider);
    final series = _longRange ? kBalanceSeries : kBalanceSeries.sublist(8);

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                eyebrow: 'Data display',
                title: 'Good evening, Ada',
                subtitle: 'Here is your money at a glance.',
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CodeAction(
                        assetPath:
                            'assets/code/src__modules__dashboard_page.dart'),
                    const SizedBox(width: Tokens.s8),
                    FilledButton.tonalIcon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(Tokens.r24)),
                        ),
                        builder: (_) => const _AddTxSheet(),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s16),
              // KPI row: wraps on narrow screens.
              const Wrap(
                spacing: Tokens.s16,
                runSpacing: Tokens.s16,
                children: [
                  _Kpi('Total balance', '\$24,806', '+8.2% MoM',
                      Icons.account_balance_wallet_outlined, Color(0xFF7C5CFF)),
                  _Kpi('Income', '\$5,770', '2 sources',
                      Icons.trending_up_outlined, Color(0xFF0E9F8A)),
                  _Kpi('Spending', '\$1,214', '12 txns',
                      Icons.trending_down_outlined, Color(0xFFE14E9A)),
                ],
              ),
              const SizedBox(height: Tokens.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final sideBySide = constraints.maxWidth > 860;
                  final chart = GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Balance trend',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800)),
                            const Spacer(),
                            _Chip(
                              '12 mo',
                              selected: _longRange,
                              onTap: () =>
                                  setState(() => _longRange = true),
                            ),
                            const SizedBox(width: Tokens.s8),
                            _Chip(
                              '30 d',
                              selected: !_longRange,
                              onTap: () =>
                                  setState(() => _longRange = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: Tokens.s8),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData:
                                  const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineTouchData: const LineTouchData(
                                  handleBuiltInTouches: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (var i = 0; i < series.length; i++)
                                      FlSpot(i.toDouble(), series[i]),
                                  ],
                                  isCurved: true,
                                  color: scheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData:
                                      const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        scheme.primary
                                            .withValues(alpha: 0.30),
                                        scheme.primary
                                            .withValues(alpha: 0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  final budgets = GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budgets',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: Tokens.s12),
                        for (final b in kBudgets) ...[
                          _BudgetRow(budget: b),
                          const SizedBox(height: Tokens.s12),
                        ],
                      ],
                    ),
                  );
                  if (sideBySide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: chart),
                        const SizedBox(width: Tokens.s16),
                        Expanded(flex: 2, child: budgets),
                      ],
                    );
                  }
                  return Column(children: [
                    chart,
                    const SizedBox(height: Tokens.s16),
                    budgets
                  ]);
                },
              ),
              const SizedBox(height: Tokens.s16),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Tokens.s16,
                          Tokens.s16, Tokens.s16, Tokens.s8),
                      child: Text('Recent activity',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800)),
                    ),
                    for (var i = 0; i < txns.length; i++)
                      _TxRow(
                              tx: txns[i],
                              last: i == txns.length - 1)
                          .animate()
                          .fadeIn(
                              delay: (i * 60).ms, duration: 350.ms)
                          .slideX(begin: 0.06, end: 0),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, this.delta, this.icon, this.tint);
  final String label, value, delta;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: StatTile(
          icon: icon, value: value, label: label, tint: tint, delta: delta),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, {required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Tokens.s12, vertical: Tokens.s4),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: selected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant)),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.budget});
  final Budget budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(budget.icon,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: Tokens.s8),
            Text(budget.label, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              '\$${budget.spent.toStringAsFixed(0)} / \$${budget.limit.toStringAsFixed(0)}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: Tokens.s4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: budget.ratio,
            minHeight: 8,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              budget.ratio > 0.85
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx, required this.last});
  final Tx tx;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final credit = tx.amount >= 0;
    return Container(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5))),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(Tokens.s8),
          decoration: BoxDecoration(
            color: tx.tint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Tokens.r12),
          ),
          child: Icon(tx.icon, color: tx.tint, size: 20),
        ),
        title: Text(tx.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${tx.detail} · ${tx.time}'),
        trailing: Text(
          '${credit ? '+' : '−'}\$${tx.amount.abs().toStringAsFixed(2)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: credit
                ? const Color(0xFF0E9F8A)
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Add-transaction sheet: mini form (title, amount, direction) that
/// prepends to transactionsProvider. The dashboard list updates with
/// zero callbacks — the provider is the bridge.
class _AddTxSheet extends ConsumerStatefulWidget {
  const _AddTxSheet();

  @override
  ConsumerState<_AddTxSheet> createState() => _AddTxSheetState();
}

class _AddTxSheetState extends ConsumerState<_AddTxSheet> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  bool _credit = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount =
        double.tryParse(_amount.text.replaceAll(',', '.'));
    if (_title.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a title and an amount over 0')),
      );
      return;
    }
    ref.read(transactionsProvider.notifier).add(Tx(
          _title.text.trim(),
          'Manual entry',
          'just now',
          _credit ? amount : -amount,
          _credit
              ? Icons.arrow_circle_down_outlined
              : Icons.arrow_circle_up_outlined,
          _credit
              ? const Color(0xFF0E9F8A)
              : Theme.of(context).colorScheme.primary,
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_credit ? 'Income' : 'Expense'} added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // viewInsets.bottom lifts the sheet above the on-screen keyboard;
      // without it the Amount field would hide behind the keys.
      padding: EdgeInsets.fromLTRB(
          Tokens.s24,
          Tokens.s8,
          Tokens.s24,
          MediaQuery.viewInsetsOf(context).bottom + Tokens.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New transaction',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: Tokens.s12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
                labelText: 'Title', hintText: 'e.g. Bookstore'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: Tokens.s8),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(
                labelText: 'Amount', hintText: 'e.g. 24.50'),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: Tokens.s12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: false,
                  icon: Icon(Icons.arrow_circle_up_outlined),
                  label: Text('Expense')),
              ButtonSegment(
                  value: true,
                  icon: Icon(Icons.arrow_circle_down_outlined),
                  label: Text('Income')),
            ],
            selected: {_credit},
            onSelectionChanged: (s) =>
                setState(() => _credit = s.first),
          ),
          const SizedBox(height: Tokens.s16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Add transaction'),
          ),
        ],
      ),
    );
  }
}
