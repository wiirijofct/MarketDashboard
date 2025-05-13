import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/ui_shared.dart' as core_ui;
import '../../../data/fake_market_data.dart';
import '../../../models/category.dart';
import '../widgets/summary_card.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/selectors/chart_selector.dart';
import '../widgets/selectors/category_selector.dart';
import '../widgets/selectors/date_selector.dart';
import '../widgets/slice_tooltip.dart';
import '../widgets/charts/line_chart.dart';
import '../widgets/charts/bar_chart.dart';
import '../widgets/charts/pie_chart.dart';
import '../widgets/compare_cat_dialog.dart';

/// A Flutter web application that displays an interactive sales dashboard.
///
/// This page provides multiple visualizations of sales data including line charts,
/// bar charts, and donut charts, with the ability to filter by category and time range.
class SalesDashboardPage extends StatelessWidget {
  const SalesDashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Row(
        children: [
          AppSidebar(current: 'Sales'),
          const Expanded(child: _SalesDashboardView()),
        ],
      ),
    ),
  );
}

/// The main content area of the sales dashboard with interactive elements and state management.
///
/// Handles chart type selection, category filtering, date range selection,
/// and interactive data visualization components.
class _SalesDashboardView extends StatefulWidget {
  const _SalesDashboardView();

  @override
  State<_SalesDashboardView> createState() => _SalesDashboardViewState();
}

class _SalesDashboardViewState extends State<_SalesDashboardView> {
  final repo = FakeDataRepository();

  /// Selected date range for data visualization
  DateRange _range = DateRange.last30;

  /// Currently selected chart type
  ChartType _chartType = ChartType.line;

  /// Selected category to focus on (null means "Overall" view)
  Category? _category;

  /// Whether the Top Seller card is being hovered over
  bool _topSellerHover = false;

  /// Whether the tooltip is locked in place (stays visible after click)
  bool _tooltipLocked = false;

  /// Value to display in the tooltip
  double? _tooltipValue;

  /// Set of categories selected for comparison in the line chart
  Set<Category> _compare = {};

  /// Index of the currently touched/selected slice in the donut chart
  int? _touchedIndex;

  /// Position of the touch event for tooltip placement
  Offset? _touchPos;

  /// Calculates the total revenue for a specific category over a period.
  ///
  /// [idx] - The index of the category in Category.values
  /// [days] - The list of daily snapshots to calculate revenue from
  ///
  /// Returns the sum of sales for the specified category across all days.
  double _revenueFor(int idx, List<DailySnapshot> days) {
    final cat = Category.values[idx];
    double sum = 0;
    for (final d in days) {
      sum += d.perCat[cat]!.sales;
    }
    return sum;
  }

  /// Formats a value as a percentage string
  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  /// Formats a value as a Euro currency string
  String _eur(double v) => '€ ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    // Get summary data for the dashboard
    final today = repo.days.last.date;
    final growth = repo.growthSinceYesterday(today);
    final profit = repo.totalSalesOn(today);
    final bestCat = repo.bestSellingCategory(today);

    // Get data for the selected time period
    final List<DailySnapshot> days = repo.days.sublist(
      max(0, repo.days.length - _range.days),
    );

    // Create the appropriate chart based on selection
    late final Widget chart;
    switch (_chartType) {
      case ChartType.line:
        chart = LineSalesChart(
          repo: repo,
          days: days,
          categories: [_category, ..._compare],
        );
        break;

      case ChartType.bar:
        chart = BarSalesChart(repo: repo, days: days, category: _category);
        break;

      case ChartType.donut:
        chart = DonutSalesChart(
          repo: repo,
          days: days,
          touchedIndex: _touchedIndex,
          onSliceTouch: (i, p, click) => _handleSliceTouch(i, p, click, days),
        );
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
              width: core_ui.UI.contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Summary cards row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Use same breakpoint for consistency
                      const breakpoint = 600.0;
                      final useVerticalLayout =
                          constraints.maxWidth < breakpoint;

                      final summaryCards = [
                        SummaryCard(
                          title: 'Vs. Yesterday',
                          value: _pct(growth),
                        ),
                        SummaryCard(title: 'Profit Today', value: _eur(profit)),
                        Container(
                          // Apply clipBehavior to ensure nothing overflows
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SummaryCard(
                            title: 'Top Seller',
                            value: bestCat.label,
                            leading: Icon(
                              bestCat.icon,
                              color: bestCat.color,
                              size: 18,
                            ),
                            underline: true,
                            bgColor:
                                (_category == null && _topSellerHover)
                                    ? bestCat.color.withAlpha(
                                      (255 * .15).round(),
                                    )
                                    : null,
                            cursor: SystemMouseCursors.click,
                            onTap: () => setState(() => _category = bestCat),
                          ).wrapWithHover(
                            onEnter: () => _toggleTopSellerHover(true),
                            onExit: () => _toggleTopSellerHover(false),
                          ),
                        ),
                      ];

                      if (useVerticalLayout) {
                        // Vertical layout for small screens
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < summaryCards.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              summaryCards[i],
                            ],
                          ],
                        );
                      } else {
                        // Horizontal layout for wider screens
                        return Row(
                          children: [
                            for (int i = 0; i < summaryCards.length; i++) ...[
                              if (i > 0) SizedBox(width: core_ui.UI.gap),
                              Expanded(child: summaryCards[i]),
                            ],
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // Chart control selectors row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Define a threshold width below which we'll stack vertically
                      const breakpoint = 600.0;
                      final useVerticalLayout =
                          constraints.maxWidth < breakpoint;

                      // Use different layouts based on available width
                      if (useVerticalLayout) {
                        // Vertical column layout for small screens
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ChartSelector(
                              value: _chartType,
                              onChanged:
                                  (v) => setState(() {
                                    _chartType = v;
                                    if (v != ChartType.line) _compare.clear();
                                    if (v == ChartType.donut) _category = null;
                                  }),
                            ),
                            const SizedBox(height: 8),
                            CategorySelector(
                              value: _category,
                              onChanged:
                                  (c) => setState(() {
                                    _category = c;
                                    _compare.remove(c);
                                  }),
                              enabled: _chartType != ChartType.donut,
                            ),
                            const SizedBox(height: 8),
                            DateSelector(
                              range: _range,
                              onChanged: (r) => setState(() => _range = r),
                            ),
                          ],
                        );
                      } else {
                        // Horizontal row layout for wider screens
                        return Row(
                          children: [
                            Expanded(
                              child: ChartSelector(
                                value: _chartType,
                                onChanged:
                                    (v) => setState(() {
                                      _chartType = v;
                                      if (v != ChartType.line) _compare.clear();
                                      if (v == ChartType.donut)
                                        _category = null;
                                    }),
                              ),
                            ),
                            SizedBox(width: core_ui.UI.gap),
                            Expanded(
                              child: CategorySelector(
                                value: _category,
                                onChanged:
                                    (c) => setState(() {
                                      _category = c;
                                      _compare.remove(c);
                                    }),
                                enabled: _chartType != ChartType.donut,
                              ),
                            ),
                            SizedBox(width: core_ui.UI.gap),
                            Expanded(
                              child: DateSelector(
                                range: _range,
                                onChanged: (r) => setState(() => _range = r),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Chart visualization area
                  SizedBox(
                    height: core_ui.UI.chartHeight,
                    child: Stack(
                      children: [
                        // Invisible layer to capture clicks when tooltip is locked
                        if (_tooltipLocked)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap:
                                  () => setState(() {
                                    _tooltipLocked = false;
                                    _touchedIndex = null;
                                  }),
                            ),
                          ),
                        // Main chart container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _title(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Expanded(child: chart),
                              // Legend for line chart
                              if (_chartType == ChartType.line)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Wrap(
                                    spacing: 12,
                                    children: [
                                      for (final cat in [
                                        _category,
                                        ..._compare,
                                      ])
                                        if (cat != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                color: cat.color,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                cat.label,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Category comparison controls for line chart
                        if (_category != null && _chartType == ChartType.line)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Clear button for comparisons
                                if (_compare.isNotEmpty) ...[
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 20,
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Clear comparison',
                                    onPressed:
                                        () => setState(() => _compare.clear()),
                                  ),
                                  const SizedBox(width: 6),
                                ],

                                // Icons for compared categories
                                for (final cat in _compare) ...[
                                  Icon(cat.icon, color: cat.color, size: 24),
                                  const SizedBox(width: 6),
                                ],

                                // Main category icon
                                Icon(
                                  _category!.icon,
                                  size: 24,
                                  color: _category!.color.withOpacity(.8),
                                ),
                                const SizedBox(width: 6),

                                // Add comparison button
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 24,
                                  icon: const Icon(Icons.add_circle_outline),
                                  tooltip: 'Compare categories',
                                  onPressed: () async {
                                    final result =
                                        await showDialog<Set<Category>>(
                                          context: context,
                                          builder:
                                              (_) => CompareCategoriesDialog(
                                                initialSelection: {..._compare},
                                              ),
                                        );
                                    if (result != null) {
                                      setState(
                                        () =>
                                            _compare = result.difference({
                                              _category,
                                            }),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        // Category icon for Bar/Donut charts
                        else if (_category != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              _category!.icon,
                              size: 24,
                              color: _category!.color.withAlpha(200),
                            ),
                          ),

                        // Tooltip for donut chart slices
                        if (_touchedIndex != null && _touchPos != null)
                          SliceTooltip(
                            category: Category.values[_touchedIndex!],
                            value: _tooltipValue ?? 0,
                            position: _touchPos!,
                            onSelectLine:
                                () =>
                                    _switchView(ChartType.line, _touchedIndex!),
                            onSelectBar:
                                () =>
                                    _switchView(ChartType.bar, _touchedIndex!),
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

  /// Handles hover state for the Top Seller card
  void _toggleTopSellerHover(bool on) {
    if (_category == null) setState(() => _topSellerHover = on);
  }

  /// Switches to a different chart view for a specific category
  void _switchView(ChartType t, int idx) => setState(() {
    _chartType = t;
    _category = Category.values[idx];
    _tooltipLocked = false;
    _touchedIndex = null;
  });

  /// Handles interaction with donut chart slices
  void _handleSliceTouch(
    int? idx,
    Offset? pos,
    bool isClick,
    List<DailySnapshot> days,
  ) {
    setState(() {
      if (idx == null) {
        // Reset when clicking outside any slice
        _tooltipLocked = false;
        _touchedIndex = null;
        return;
      }

      if (isClick) {
        // Toggle tooltip lock state
        _tooltipLocked = !_tooltipLocked || _touchedIndex != idx;
      }

      if (!_tooltipLocked || isClick) {
        // Update tooltip data
        _touchedIndex = idx;
        _touchPos = pos;
        _tooltipValue = _revenueFor(idx, days);
      }
    });
  }

  /// Generates the chart title based on current selections
  String _title() {
    if (_chartType == ChartType.donut) {
      return 'Category Share – ${_range.label}';
    }
    final name = _category?.label ?? 'Overall';
    return '$name – ${_range.label}';
  }
}

/// Extension providing hover functionality for widgets.
///
/// Wraps a widget with MouseRegion to handle mouse enter and exit events.
extension _Hover on Widget {
  /// Adds hover detection to a widget.
  ///
  /// [onEnter] - Callback executed when the mouse enters the widget area
  /// [onExit] - Callback executed when the mouse exits the widget area
  Widget wrapWithHover({
    required VoidCallback onEnter,
    required VoidCallback onExit,
  }) => MouseRegion(
    onEnter: (_) => onEnter(),
    onExit: (_) => onExit(),
    child: this,
  );
}
