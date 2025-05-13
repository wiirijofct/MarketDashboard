import 'package:flutter/material.dart';

/// Represents the types of charts available in the application.
enum ChartType { line, bar, donut }

/// Extension on ChartType to provide human-readable labels.
extension ChartTypeLabel on ChartType {
  String get label => switch (this) {
    ChartType.line => 'Line Chart',
    ChartType.bar => 'Bar Chart',
    ChartType.donut => 'Donut Chart',
  };
}

/// A dropdown widget that allows users to select different chart types.
///
/// This widget displays available chart types in a styled dropdown menu
/// and notifies the parent widget when a selection changes.
class ChartSelector extends StatelessWidget {
  /// Creates a chart selector.
  ///
  /// [value] is the currently selected chart type.
  /// [onChanged] is called when the user selects a different chart type.
  const ChartSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// The currently selected chart type.
  final ChartType value;

  /// Callback that is called when a new chart type is selected.
  final ValueChanged<ChartType> onChanged;

  @override
  Widget build(BuildContext context) => _wrapInStyledContainer(
    DropdownButton<ChartType>(
      value: value,
      dropdownColor: Colors.blueGrey[500],
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      underline: const SizedBox.shrink(),
      items:
          ChartType.values
              .map(
                (v) => DropdownMenuItem<ChartType>(
                  value: v,
                  child: Text(
                    v.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    ),
  );

  /// Wraps the given [child] widget in a styled container.
  ///
  /// Applies consistent styling including background color,
  /// padding, and border radius.
  Widget _wrapInStyledContainer(Widget child) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blueGrey[500],
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(child: child),
  );
}
