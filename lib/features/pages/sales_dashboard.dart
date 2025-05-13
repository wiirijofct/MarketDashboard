import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/fake_market_data.dart';
import '../../models/category.dart';
import '../widgets/selectors/date_selector.dart';
import '../widgets/selectors/selectors.dart';
import '../../core/ui_shared.dart';

void main() => runApp(const DashboardApp());

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Dashboard Web App',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const SalesDashboardPage(),
  );
}

/* ------------ page wrapper: sidebar + body ------------------------- */
class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: const [
            AppSidebar(current: 'Sales'),
            Expanded(child: _SalesDashboardBody()),
          ],
        ),
      ),
    );
  }
}

class _SliceTooltip extends StatelessWidget {
  const _SliceTooltip({
    required this.category,
    required this.value,
    required this.position,
    required this.onSelectLine,
    required this.onSelectBar,
  });

  final Category category;
  final double value;
  final Offset position;
  final VoidCallback onSelectLine;
  final VoidCallback onSelectBar;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx + 16, // offset so it doesn't cover cursor
      top: position.dy - 40,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueGrey[600],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '€ ${value.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.show_chart, color: Colors.white),
                    tooltip: 'Line chart',
                    onPressed: onSelectLine,
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart, color: Colors.white),
                    tooltip: 'Bar chart',
                    onPressed: onSelectBar,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------ stateful body with all logic ------------------------ */
class _SalesDashboardBody extends StatefulWidget {
  const _SalesDashboardBody();
  @override
  State<_SalesDashboardBody> createState() => _SalesDashboardBodyState();
}

class _SalesDashboardBodyState extends State<_SalesDashboardBody> {
  final repo = FakeDataRepository();
  DateRange _range = DateRange.last30;
  ChartType _chartType = ChartType.line;
  Category? _category; // null = overall
  bool _topSellerHover = false;
  int? _touchedIndex;
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();
    _category = null;
  }

  /* ---------- convenience formatters --------------------------- */
  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';
  String _eur(double v) => '€ ${v.toStringAsFixed(0)}';

  /* ---------- build -------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    /* summary numbers (always overall) */
    final today = repo.days.last.date;
    final growth = repo.growthSinceYesterday(today);
    final profit = repo.totalSalesOn(today);
    final bestCatObj = repo.bestSellingCategory(today);

    /* slice by range */
    final all = repo.days;
    final days = all.sublist(max(0, all.length - _range.days));

    /* choose chart widget */
    late final Widget chart;
    switch (_chartType) {
      case ChartType.line:
        chart = _lineChart(days);
        break;
      case ChartType.bar:
        chart = _barChart(days);
        break;
      case ChartType.donut:
        chart = _donutChart(days);
        break;
    }

    return Column(
      children: [
        const Spacer(),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(64),
            decoration: BoxDecoration(
              color: _category?.backgroundTint(_category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: UI.contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /* ------ summary cards -------- */
                  Row(
                    children: [
                      SummaryCard(title: 'Vs. Yesterday', value: _pct(growth)),
                      const SizedBox(width: UI.gap),
                      SummaryCard(title: 'Profit Today', value: _eur(profit)),
                      const SizedBox(width: UI.gap),
                      SummaryCard(
                        title: 'Top Seller',
                        value: bestCatObj.label,
                        underline: true,
                        bgColor:
                            (_category == null && _topSellerHover)
                                ? bestCatObj.color.withAlpha(
                                  (255 * 0.15).round(),
                                )
                                : null,
                        cursor: SystemMouseCursors.click,
                        onTap: () {
                          setState(() {
                            _category = bestCatObj; // jump to category
                            _topSellerHover = false; // reset hover tint
                          });
                        },
                        // hover listeners
                      ).wrapWithHover(
                        onEnter: () {
                          if (_category == null) {
                            setState(() => _topSellerHover = true);
                          }
                        },
                        onExit: () {
                          if (_category == null) {
                            setState(() => _topSellerHover = false);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /* ------ selectors row -------- */
                  Row(
                    children: [
                      SizedBox(
                        width: UI.cardWidth,
                        child: ChartSelector(
                          value: _chartType,
                          onChanged: (v) => setState(() => _chartType = v),
                        ),
                      ),
                      const SizedBox(width: UI.gap),
                      SizedBox(
                        width: UI.cardWidth,
                        child: CategorySelector(
                          value: _category,
                          onChanged: (c) => setState(() => _category = c),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: UI.cardWidth,
                        child: DateSelector(
                          range: _range,
                          onChanged: (r) => setState(() => _range = r),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /* ------ chart card ---------- */
                  SizedBox(
                    height: UI.chartHeight,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _chartTitle(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Expanded(child: chart),
                            ],
                          ),
                        ),

                        // icon overlay – only when a category is active
                        if (_category != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              _category!.icon,
                              size: 24,
                              color: _category!.color.withOpacity(.8),
                            ),
                          ),
                        if (_touchedIndex != null)
                          _SliceTooltip(
                            category: Category.values[_touchedIndex!],
                            value:
                                (_range.days == 0
                                    ? 0
                                    : // safety
                                    repo.totalSalesOn(repo.days.last.date) *
                                        100) /
                                100, // example calc
                            position: _touchPosition ?? const Offset(0, 0),
                            onSelectLine: () {
                              setState(() {
                                _chartType = ChartType.line;
                                _category = Category.values[_touchedIndex!];
                                _touchedIndex = null;
                              });
                            },
                            onSelectBar: () {
                              setState(() {
                                _chartType = ChartType.bar;
                                _category = Category.values[_touchedIndex!];
                                _touchedIndex = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  /* ---------- charts ------------------------------------------- */
  Widget _lineChart(List<DailySnapshot> days) {
    final spots = <FlSpot>[];
    double maxY = 0;
    final Color lineColor = _category?.color ?? Colors.red;
    for (var i = 0; i < days.length; i++) {
      final y =
          _category == null
              ? repo.totalSalesOn(days[i].date)
              : days[i].perCat[_category]!.sales;
      spots.add(FlSpot(i.toDouble(), y));
      maxY = max(maxY, y);
    }
    String k(num v) =>
        v >= 1000 ? '${(v / 1000).round()}k' : v.round().toString();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            dotData: FlDotData(show: false),
          ),
        ],
        gridData: FlGridData(show: false),
        titlesData: _axes(maxY, spots.length, k),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: maxY * 1.1,
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  _fmt(touchedSpot.y),
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _barChart(List<DailySnapshot> days) {
    final vals = <double>[];
    double maxY = 0;
    final Color lineColor = _category?.color ?? Colors.red;
    for (final d in days) {
      final y =
          _category == null
              ? repo.totalSalesOn(d.date)
              : d.perCat[_category]!.sales;
      vals.add(y);
      maxY = max(maxY, y);
    }
    final groups = List.generate(
      vals.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: vals[i], width: 8, color: lineColor)],
      ),
    );

    String k(num v) =>
        v >= 1000 ? '${(v / 1000).round()}k' : v.round().toString();

    return BarChart(
      BarChartData(
        barGroups: groups,
        gridData: FlGridData(show: false),
        titlesData: _axes(maxY, vals.length, k),
        borderData: FlBorderData(show: true),
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                _fmt(rod.toY),
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _donutChart(List<DailySnapshot> days) {
    // ---- data prep --------------------------------------------------
    final totals = {for (final c in Category.values) c: 0.0};
    for (final d in days) {
      for (final c in Category.values) {
        totals[c] = totals[c]! + d.perCat[c]!.sales;
      }
    }
    final sum = totals.values.fold(0.0, (s, e) => s + e);

    // ---- sections ---------------------------------------------------
    final sections = <PieChartSectionData>[];
    int idx = 0;
    for (final c in Category.values) {
      final pct = totals[c]! / sum * 100;
      final isTouched = idx == _touchedIndex;
      sections.add(
        PieChartSectionData(
          value: totals[c],
          title: '${pct.toStringAsFixed(1)}%',
          color: c.color,
          radius: isTouched ? 90 : 80, // pop‑out on hover/tap
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      idx++;
    }

    // ---- chart with touch handling ---------------------------------
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
        pieTouchData: PieTouchData(
          touchCallback: (event, resp) {
            if (resp == null ||
                resp.touchedSection == null ||
                resp.touchedSection!.touchedSectionIndex < 0) {
              if (_touchedIndex != null) setState(() => _touchedIndex = null);
              return;
            }

            final idx =
                resp.touchedSection!.touchedSectionIndex; //  guaranteed ≥ 0
            setState(() {
              _touchedIndex = idx;
              _touchPosition = event.localPosition;
            });
          },
        ),
      ),
    );
  }

  /* ---------- axes builder reused by line & bar ----------------- */
  FlTitlesData _axes(double maxY, int len, String Function(num) fmt) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: maxY / 5,
          getTitlesWidget:
              (v, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(fmt(v), style: const TextStyle(fontSize: 10)),
              ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: len > 1 ? (len - 1) / 2 : 1,
          getTitlesWidget: (val, _) {
            final d = len - 1 - val.toInt();
            if (val == 0 || val == (len - 1) / 2 || val == len - 1) {
              return Text('$d', style: const TextStyle(fontSize: 10));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /* ---------- title -------------------------------------------- */
  String _chartTitle() {
    if (_chartType == ChartType.donut) {
      return 'Category Share – ${_range.label}';
    }
    final name = _category == null ? 'Overall' : _category!.label;
    return '$name – ${_range.label}';
  }
}

String _fmt(num v) => v.toStringAsFixed(1); // 0 int, 1 decimal;

extension _Hover on Widget {
  Widget wrapWithHover({
    required VoidCallback onEnter,
    required VoidCallback onExit,
  }) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: this,
    );
  }
}
