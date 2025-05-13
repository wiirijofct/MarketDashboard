import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../data/fake_market_data.dart';
import '../../../../models/category.dart';

/// A bar chart visualization for sales data.
///
/// Displays sales values as vertical bars, with optional category filtering.
/// The chart automatically scales based on the maximum value in the dataset
/// and provides interactive tooltips on hover/tap.
class BarSalesChart extends StatelessWidget {
  /// Creates a bar chart for sales data.
  ///
  /// [repo] - Data repository providing access to sales information
  /// [days] - List of daily snapshots to visualize
  /// [category] - Optional category filter; if null, shows total sales across all categories
  const BarSalesChart({
    super.key,
    required this.repo,
    required this.days,
    required this.category,
  });

  /// Data repository providing sales information
  final FakeDataRepository repo;

  /// List of daily snapshots to display in the chart
  final List<DailySnapshot> days;

  /// Optional category filter; when null, shows total sales across all categories
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final values = _prepareChartData();
    final maxValue = values.isEmpty ? 0.0 : values.reduce(max);
    final barColor = category?.color ?? Colors.red;

    final groups = _createBarGroups(values, barColor);

    return BarChart(
      BarChartData(
        barGroups: groups,
        maxY: maxValue * 1.1, // Add 10% padding at the top
        gridData: FlGridData(show: false),
        titlesData: _configureAxes(maxValue, values.length),
        borderData: FlBorderData(show: true),
        barTouchData: _configureTouchInteraction(),
      ),
    );
  }

  /// Prepares chart data by calculating values based on category selection
  ///
  /// Returns a list of sales values for each day in the dataset
  List<double> _prepareChartData() {
    final values = <double>[];

    for (final day in days) {
      final value =
          category == null
              ? repo.totalSalesOn(day.date)
              : day.perCat[category]!.sales;
      values.add(value);
    }

    return values;
  }

  /// Creates bar chart group data from values
  ///
  /// [values] - List of sales values
  /// [barColor] - Color to use for bars
  ///
  /// Returns a list of configured bar chart groups
  List<BarChartGroupData> _createBarGroups(
    List<double> values,
    Color barColor,
  ) {
    return List.generate(
      values.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: values[i], width: 8, color: barColor)],
      ),
    );
  }

  /// Configures touch interaction and tooltips
  ///
  /// Returns configured BarTouchData for the chart
  BarTouchData _configureTouchInteraction() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueAccent,
        getTooltipItem:
            (_, __, rod, ___) => BarTooltipItem(
              _formatValue(rod.toY),
              const TextStyle(color: Colors.white),
            ),
      ),
    );
  }

  /// Configures axis titles and labels for the chart.
  ///
  /// [maxY] - Maximum Y value for scaling the vertical axis
  /// [dataLength] - Number of data points (bars) in the chart
  ///
  /// Returns configured FlTitlesData for the chart's axes.
  FlTitlesData _configureAxes(double maxY, int dataLength) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: maxY > 0 ? maxY / 5 : 1,
          getTitlesWidget:
              (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  _formatAxisLabel(value),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: dataLength > 1 ? (dataLength - 1) / 2 : 1,
          getTitlesWidget: (value, _) {
            final dayIndex = dataLength - 1 - value.toInt();
            return (value == 0 ||
                    value == (dataLength - 1) / 2 ||
                    value == dataLength - 1)
                ? Text('$dayIndex', style: const TextStyle(fontSize: 10))
                : const SizedBox.shrink();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Formats a value for Y-axis labels, using "k" suffix for thousands
  ///
  /// [value] - The numeric value to format
  ///
  /// Returns a formatted string representation of the value
  String _formatAxisLabel(num value) {
    return value >= 1000
        ? '${(value / 1000).round()}k'
        : value.round().toString();
  }

  /// Formats a numeric value for display in tooltips.
  ///
  /// [value] - The value to format
  ///
  /// Returns a string with one decimal place.
  String _formatValue(num value) => value.toStringAsFixed(1);
}
