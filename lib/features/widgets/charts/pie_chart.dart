import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../data/fake_market_data.dart';
import '../../../../models/category.dart';

/// Callback function for when a pie chart slice is interacted with
///
/// [touchedIndex] The index of the touched slice, or null if no slice is touched
/// [position] The position of the touch event, or null if no touch occurred
/// [isClick] True for click/tap events, false for hover movements
typedef SliceTouchCallback =
    void Function(int? touchedIndex, Offset? position, bool isClick);

/// A donut chart that displays sales data by category
///
/// Takes a data repository and time range (as a list of daily snapshots) and
/// renders a donut chart showing the proportional sales by category.
class DonutSalesChart extends StatelessWidget {
  /// Creates a donut chart showing sales data
  ///
  /// [repo] The data repository containing sales information
  /// [days] The list of daily snapshots to analyze
  /// [touchedIndex] The currently selected slice index (if any)
  /// [onSliceTouch] Callback for when a slice is touched/clicked
  const DonutSalesChart({
    super.key,
    required this.repo,
    required this.days,
    required this.touchedIndex,
    required this.onSliceTouch,
  });

  /// Repository containing sales data
  final FakeDataRepository repo;

  /// List of daily snapshots to analyze and display
  final List<DailySnapshot> days;

  /// Currently touched/selected slice index, or null if none
  final int? touchedIndex;

  /// Callback when a slice is interacted with
  final SliceTouchCallback onSliceTouch;

  @override
  Widget build(BuildContext context) {
    // Calculate total sales for each category across all days
    final Map<Category, double> totals = _calculateCategoryTotals();
    final double sum = totals.values.fold(0.0, (s, e) => s + e);

    // Create chart sections from the totals
    final sections = _buildChartSections(totals, sum);

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40, // Creates the donut hole
        pieTouchData: PieTouchData(touchCallback: _handleTouch),
      ),
    );
  }

  /// Calculate the total sales for each category across all selected days
  Map<Category, double> _calculateCategoryTotals() {
    final totals = {for (final c in Category.values) c: 0.0};

    for (final day in days) {
      for (final category in Category.values) {
        totals[category] = totals[category]! + day.perCat[category]!.sales;
      }
    }

    return totals;
  }

  /// Build chart sections from the calculated totals
  List<PieChartSectionData> _buildChartSections(
    Map<Category, double> totals,
    double sum,
  ) {
    final sections = <PieChartSectionData>[];
    int idx = 0;

    for (final category in Category.values) {
      final percentage = (totals[category]! / sum) * 100;
      final isTouched = idx == touchedIndex;

      sections.add(
        PieChartSectionData(
          value: totals[category],
          title: '${percentage.toStringAsFixed(1)}%',
          color: category.color,
          radius: isTouched ? 90 : 80, // Expand radius when touched
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      idx++;
    }

    return sections;
  }

  /// Handle touch events on the chart
  void _handleTouch(FlTouchEvent event, PieTouchResponse? response) {
    // No valid touch or section was touched
    if (response == null ||
        response.touchedSection == null ||
        response.touchedSection!.touchedSectionIndex < 0) {
      onSliceTouch(null, null, false);
      return;
    }

    final touchedIndex = response.touchedSection!.touchedSectionIndex;

    // Determine if this was a click/tap or just a hover
    final isClick =
        event is FlLongPressEnd ||
        event is FlTapUpEvent ||
        event is FlPanEndEvent;

    onSliceTouch(touchedIndex, event.localPosition, isClick);
  }
}
