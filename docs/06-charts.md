# 06 · Charts

Three `fl_chart` recipes in `charts_page.dart`, each a `_RecipeCard`
pairing a live chart with its one-line API note. Dashboard reuses the
line recipe — compare the two files.

## Line — trends (`_WeeklyLine`)

- `LineChartBarData(isCurved: true, barWidth: 3, color: scheme.primary)`
- `belowBarData` with a vertical gradient (`primary 30% → transparent`)
  = the filled-area look for free
- `FlDotData(show: false)` hides data dots; `lineTouchData` defaults give
  hover tooltips on web with zero code
- Hide everything else: `FlGridData(show: false)`,
  `FlTitlesData` with only bottom day labels, `FlBorderData(show: false)`

## Bar — comparisons (`_WeeklyBars`)

- One `BarChartGroupData(x:)` per day, one `BarChartRodData(toY:)` per bar
- `borderRadius: top-only 6` = modern rounded bars
- Max value gets the highlight colour — computed in the builder, showing
  charts are just widgets over data: any Dart expression can drive style

## Pie — composition

- `PieChartSectionData(value:, color:, radius:)` per slice
- `centerSpaceRadius: 48` turns pie → donut; `sectionsSpace: 3` gaps slices
- The legend is NOT chart API — just `Row`s + `LinearProgressIndicator`.
  Labels are a UI job, not a chart job.

## Data flow

Series live in `core/data.dart` (`kWeeklyActive`, `kTrafficMix`) as const
lists. Swap them for a `FutureProvider` later and no chart code changes —
`FlSpot(i, value)` construction stays identical.

**Exercise:** add a 4th card — radar or scatter from fl_chart's gallery —
wired to a new const series in data.dart.
