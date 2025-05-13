import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../data/fake_market_data.dart';
import '../../../../models/category.dart';

/// A line chart component for displaying sales data across multiple categories.
///
/// This widget uses [fl_chart] to render a line chart with interactive tooltips
/// that show sales data. Each line represents a different product category,
/// with an optional "Overall" category when null is provided.
class LineSalesChart extends StatelessWidget {
  /// Creates a line sales chart.
  ///
  /// [repo] provides the data source for sales information.
  /// [days] specifies the date range to display on the chart.
  /// [categories] defines which product categories to render as lines.
  /// When a null entry is included in [categories], it represents the "Overall" total.
  const LineSalesChart({
    super.key,
    required this.repo,
    required this.days,
    required this.categories,
  });

  /// Data repository containing sales information.
  final FakeDataRepository repo;

  /// List of daily snapshots to display on the chart.
  final List<DailySnapshot> days;

  /// Categories to display (null represents the "Overall" total).
  final List<Category?> categories;

  @override
  Widget build(BuildContext context) {
    // Build line data for each requested category
    final bars = <LineChartBarData>[];
    final List<Category?> categoryOrder =
        []; // Maintains bar-to-category mapping
    double maxY = 0;

    for (final category in categories) {
      final spots = <FlSpot>[];
      categoryOrder.add(category);

      // Create data points for this category
      for (var i = 0; i < days.length; i++) {
        final y =
            category == null
                ? repo.totalSalesOn(days[i].date)
                : days[i].perCat[category]!.sales;

        spots.add(FlSpot(i.toDouble(), y));
        maxY = max(maxY, y);
      }

      // Configure line appearance
      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: category?.color ?? Colors.grey,
          dotData: FlDotData(
            show: false,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: barData.color ?? Colors.grey,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          barWidth: 3,
        ),
      );
    }

    // Helper for compact y-axis labels
    String formatK(num value) =>
        value >= 1000 ? '${(value / 1000).round()}k' : value.round().toString();

    return LineChart(
      LineChartData(
        lineBarsData: bars,
        minY: 0,
        maxY: maxY * 1.1, // Add 10% padding at the top
        minX: 0,
        maxX: days.length.toDouble() - 1,
        gridData: FlGridData(show: false),
        titlesData: _buildAxesTitles(maxY, days.length, formatK),
        borderData: FlBorderData(show: true),
        lineTouchData: _buildTouchData(categoryOrder),
      ),
    );
  }

  /// Builds interactive touch handling configuration for the chart.
  LineTouchData _buildTouchData(List<Category?> categoryOrder) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.black.withAlpha(200),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(12),
        tooltipMargin: 16,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        maxContentWidth: 200,
        getTooltipItems: (touchedSpots) {
          if (touchedSpots.isEmpty) return [];

          // Calculate total for all touched points
          final total = touchedSpots.fold<double>(0, (prev, s) => prev + s.y);

          // Sort by value (descending) for better readability
          final sortedSpots = List<LineBarSpot>.from(touchedSpots)
            ..sort((a, b) => b.y.compareTo(a.y));

          return sortedSpots.asMap().entries.map((entry) {
            final index = entry.key;
            final spot = entry.value;
            final category = categoryOrder[spot.barIndex];
            final label = category?.label ?? 'Overall';
            final color = category?.color ?? Colors.grey;

            // Add total summary to the last tooltip item if multiple lines
            if (index == sortedSpots.length - 1 && sortedSpots.length > 1) {
              return LineTooltipItem(
                "$label: ${_formatValue(spot.y)}",
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: "\nTotal: ${_formatValue(total)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }

            return LineTooltipItem(
              "$label: ${_formatValue(spot.y)}",
              TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
    );
  }

  /// Builds the axis titles and configuration.
  FlTitlesData _buildAxesTitles(
    double maxY,
    int dataLength,
    String Function(num) formatter,
  ) {
    // Prevent division by zero with safe interval values
    final yInterval = maxY > 0 ? maxY / 5 : 1;
    final xInterval = dataLength > 1 ? (dataLength - 1) / 2 : 1;

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: yInterval.toDouble(),
          getTitlesWidget:
              (value, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  formatter(value),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: xInterval.toDouble(),
          getTitlesWidget: (value, _) {
            final daysAgo = dataLength - 1 - value.toInt();
            return (value == 0 || value == xInterval || value == dataLength - 1)
                ? Text('$daysAgo', style: const TextStyle(fontSize: 10))
                : const SizedBox.shrink();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Formats a numeric value with one decimal place.
  String _formatValue(num value) => value.toStringAsFixed(1);
}
