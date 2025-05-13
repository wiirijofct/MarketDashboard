import 'package:flutter/material.dart';

/// Represents predefined date ranges for dashboard filtering.
enum DateRange { last7, last30, last90, last180 }

/// Extension on DateRange to provide human-readable labels and day calculations.
extension DateRangeLabel on DateRange {
  /// Returns a human-readable description of the date range.
  String get label => switch (this) {
    DateRange.last7 => 'Last 7 Days',
    DateRange.last30 => 'Last 30 Days',
    DateRange.last90 => 'Last 3 Months',
    DateRange.last180 => 'Last 6 Months',
  };

  /// Returns the number of days in this range.
  int get days => switch (this) {
    DateRange.last7 => 7,
    DateRange.last30 => 30,
    DateRange.last90 => 90,
    DateRange.last180 => 180,
  };
}

/// A styled dropdown widget that allows users to select a date range.
///
/// This widget creates a visually consistent date range selector with a
/// blue-gray background and white text for improved readability.
class DateSelector extends StatelessWidget {
  /// Creates a date selector.
  ///
  /// The [range] parameter sets the initially selected date range.
  /// The [onChanged] callback is called when the user selects a new range.
  const DateSelector({super.key, required this.range, required this.onChanged});

  /// The currently selected date range.
  final DateRange range;

  /// Callback that is called when the selected date range changes.
  final ValueChanged<DateRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[500],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateRange>(
          value: range,
          dropdownColor: Colors.blueGrey[500],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items:
              DateRange.values
                  .map(
                    (d) => DropdownMenuItem<DateRange>(
                      value: d,
                      child: Text(
                        d.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (DateRange? value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
