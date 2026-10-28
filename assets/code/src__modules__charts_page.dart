// CHARTS LAB — fl_chart recipes with learning notes.
//
// Each card pairs a live chart with a one-line explanation of the API
// behind it. If you can read these three cards, you can build any
// dashboard chart: LineChart (trends), BarChart (comparisons),
// PieChart (composition). Full recipes: docs/06-charts.md
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/code_view.dart';
import '../core/data.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                eyebrow: 'Data display',
                title: 'Charts lab',
                subtitle:
                    'Three fl_chart recipes: trends, comparisons, composition.',
                action: const CodeAction(
                    assetPath:
                        'assets/code/src__modules__charts_page.dart'),
              ),
              const SizedBox(height: Tokens.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 860;
                  final line = _RecipeCard(
                    title: 'Line — weekly active users',
                    note:
                        'LineChartBarData(isCurved: true) + gradient belowBarData. '
                        'Touch tooltips are free via lineTouchData.',
                    chart: SizedBox(
                      height: 200,
                      child: _WeeklyLine(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  );
                  final bar = _RecipeCard(
                    title: 'Bar — same data, compared',
                    note:
                        'BarChartGroupData per day, BarChartRodData per value. '
                        'touchTooltipData gives hover labels on web.',
                    chart: SizedBox(
                      height: 200,
                      child: _WeeklyBars(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                          highlight: Theme.of(context)
                              .colorScheme
                              .secondary),
                    ),
                  );
                  if (wide) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ).withChildren([line, bar]);
                  }
                  return Column(children: [
                    line,
                    const SizedBox(height: Tokens.s16),
                    bar
                  ]);
                },
              ),
              const SizedBox(height: Tokens.s16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 860;
                  final pie = _RecipeCard(
                    title: 'Pie — traffic mix',
                    note:
                        'PieChartSectionData per slice. centerSpaceRadius turns '
                        'a pie into a donut; sectionsSpace adds gaps.',
                    chart: SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 48,
                          sectionsSpace: 3,
                          sections: [
                            for (final s in kTrafficMix)
                              PieChartSectionData(
                                value: s.value,
                                color: s.color,
                                title: '${s.value.toInt()}%',
                                titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                                radius: 56,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                  final legend = _RecipeCard(
                    title: 'Reading the mix',
                    note:
                        'A legend is just a Column of Rows — no chart API needed. '
                        'Pairing values with labels is a UI job, not a chart job.',
                    chart: Column(
                      children: [
                        for (final s in kTrafficMix)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Tokens.s8),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: Tokens.s12),
                                Text(s.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text('${s.value.toInt()}%'),
                                const SizedBox(width: Tokens.s8),
                                SizedBox(
                                  width: 120,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: s.value / 100,
                                      minHeight: 8,
                                      backgroundColor:
                                          Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      valueColor:
                                          AlwaysStoppedAnimation(
                                              s.color),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                  if (wide) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ).withChildren([pie, legend]);
                  }
                  return Column(children: [
                    pie,
                    const SizedBox(height: Tokens.s16),
                    legend
                  ]);
                },
              ),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card pairing a chart with its recipe note.
class _RecipeCard extends StatelessWidget {
  const _RecipeCard(
      {required this.title, required this.note, required this.chart});
  final String title;
  final String note;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: Tokens.s4),
          Text(note,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: Tokens.s12),
          chart,
        ],
      ),
    );
  }
}

class _WeeklyLine extends StatelessWidget {
  const _WeeklyLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
                strokeWidth: 1)),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                kWeekDays[v.toInt() % kWeekDays.length],
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < kWeeklyActive.length; i++)
                FlSpot(i.toDouble(), kWeeklyActive[i]),
            ],
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.30),
                  color.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.colors, required this.highlight});
  final List<Color> colors;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    final max =
        kWeeklyActive.reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                kWeekDays[v.toInt() % kWeekDays.length],
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < kWeeklyActive.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: kWeeklyActive[i],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  gradient: LinearGradient(
                    colors: kWeeklyActive[i] == max
                        ? [highlight, highlight]
                        : colors,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Tiny helper: Row with two expanded recipe cards + gap.
/// (Keeps the wide/narrow branching above readable.)
extension on Row {
  Widget withChildren(List<Widget> pair) => Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(child: pair[0]),
          const SizedBox(width: Tokens.s16),
          Expanded(child: pair[1]),
        ],
      );
}
