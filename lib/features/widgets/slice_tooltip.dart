import 'package:flutter/material.dart';
import '../../../data/fake_market_data.dart';
import '../../../models/category.dart';

/// A tooltip widget that displays information about a pie/donut chart slice.
///
/// Appears at the given [position] and shows information about the [category]
/// along with its [value]. Provides buttons to switch between chart types.
class SliceTooltip extends StatelessWidget {
  /// Creates a slice tooltip.
  ///
  /// All parameters except [key] are required.
  const SliceTooltip({
    super.key,
    required this.category,
    required this.value,
    required this.position,
    required this.onSelectLine,
    required this.onSelectBar,
  });

  /// The category represented by this slice.
  final Category category;

  /// The numerical value of this slice.
  final double value;

  /// The position where the tooltip should be displayed.
  final Offset position;

  /// Callback when the line chart button is pressed.
  final VoidCallback onSelectLine;

  /// Callback when the bar chart button is pressed.
  final VoidCallback onSelectBar;

  @override
  Widget build(BuildContext context) => Positioned(
    left: position.dx + 16,
    top: position.dy - 60,
    child: Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blueGrey[600],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, color: category.color, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '€ ${value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.show_chart, color: Colors.white),
                    tooltip: 'Line chart',
                    splashRadius: 22,
                    onPressed: onSelectLine,
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart, color: Colors.white),
                    tooltip: 'Bar chart',
                    splashRadius: 22,
                    onPressed: onSelectBar,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
