import 'package:flutter/material.dart';
import '../../../data/fake_market_data.dart';
import '../../../models/category.dart';

// ───────────────────── Chart Selector ─────────────────────────────

enum ChartType { line, bar, donut }

extension ChartTypeLabel on ChartType {
  String get label => switch (this) {
    ChartType.line => 'Line Chart',
    ChartType.bar => 'Bar Chart',
    ChartType.donut => 'Donut Chart',
  };
}

class ChartSelector extends StatelessWidget {
  const ChartSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ChartType value;
  final ValueChanged<ChartType> onChanged;

  @override
  Widget build(BuildContext context) => _wrap(
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
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}

// ───────────────────── Category Selector ─────────────────────────

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// `null` means "Overall" (aggregate across categories)
  final Category? value;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context) => _wrap(
    DropdownButton<Category?>(
      value: value,
      dropdownColor: Colors.blueGrey[500],
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      underline: const SizedBox.shrink(),
      items: [
        const DropdownMenuItem<Category?>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.layers, color: Colors.white, size: 18), // generic icon
              SizedBox(width: 6),
              Text('Overall', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        ...Category.values.map(
          (c) => DropdownMenuItem<Category?>(
            value: c,
            child: Row(
              children: [
                Icon(c.icon, color: c.color, size: 18), // ← icon+color
                const SizedBox(width: 6),
                Text(c.label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    ),
  );
}

// ───────────────────── Shared Container ─────────────────────────

Widget _wrap(Widget child) => Container(
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blueGrey[500],
    borderRadius: BorderRadius.circular(8),
  ),
  child: DropdownButtonHideUnderline(child: child),
);
