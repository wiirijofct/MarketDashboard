import 'package:flutter/material.dart';

/// UI constants for consistent sizing and spacing across the application.
abstract class UI {
  /// Standard width for cards used throughout the application.
  static const cardWidth = 250.0;

  /// Standard gap between elements.
  static const gap = 24.0;

  /// Standard height for charts.
  static const chartHeight = 450.0;

  /// Standard content width calculation based on cards and gaps.
  static const contentWidth = cardWidth * 3 + gap * 2;
}

/// Sidebar navigation component used across dashboard screens.
class AppSidebar extends StatelessWidget {
  /// Creates a sidebar with navigation options.
  ///
  /// The [current] parameter highlights the active section.
  const AppSidebar({super.key, required this.current});

  /// The currently active section identifier.
  /// Expected values: "Sales", "Stock", or "Demand"
  final String current;

  @override
  Widget build(BuildContext context) {
    Widget item(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: title == current ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );

    return Container(
      width: 200,
      color: const Color(0xFFE0E0E0),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [item('Sales'), item('Stock'), item('Demand')],
      ),
    );
  }
}

/// A compact card widget for displaying summary statistics.
class SummaryCard extends StatelessWidget {
  /// Creates a summary card with a title and value display.
  ///
  /// [title] is the label displayed at the top of the card.
  /// [value] is the primary data point displayed prominently.
  /// [onTap] enables interaction when the card is tapped.
  /// [icon] optional icon to display with the data.
  /// [underline] determines if the value should be underlined.
  /// [bgColor] customizes the background color (defaults to light grey).
  /// [cursor] specifies the mouse cursor when hovering (defaults to basic).
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.onTap,
    this.icon,
    this.underline = false,
    this.bgColor,
    this.cursor = SystemMouseCursors.basic,
  });

  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool underline;
  final Color? bgColor;
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: UI.cardWidth,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: underline ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
