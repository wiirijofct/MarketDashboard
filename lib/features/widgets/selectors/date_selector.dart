import 'package:flutter/material.dart';

/// Preset zoom windows the dashboard supports.
enum DateRange { last7, last30, last90, last180 }

extension DateRangeLabel on DateRange {
  String get label => switch (this) {
    DateRange.last7 => 'Last 7 Days',
    DateRange.last30 => 'Last 30 Days',
    DateRange.last90 => 'Last 3 Months',
    DateRange.last180 => 'Last 6 Months',
  };

  /// Number of trailing days in this range.
  int get days => switch (this) {
    DateRange.last7 => 7,
    DateRange.last30 => 30,
    DateRange.last90 => 90,
    DateRange.last180 => 180,
  };
}

/// A stylised dropdown that lets the user pick the date window.
class DateSelector extends StatelessWidget {
  const DateSelector({super.key, required this.range, required this.onChanged});

  final DateRange range;
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
