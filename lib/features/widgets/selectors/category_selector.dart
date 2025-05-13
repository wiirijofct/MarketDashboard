import 'package:flutter/material.dart';
import '../../../../data/fake_market_data.dart';
import '../../../../models/category.dart';

/// A dropdown widget that allows selecting a category or "Overall" option.
///
/// This widget renders a styled dropdown button for category selection with
/// appropriate icons and colors for each category option.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Currently selected category.
  /// When null, represents the "Overall" option (aggregate across all categories).
  final Category? value;

  /// Callback triggered when the selected category changes.
  final ValueChanged<Category?> onChanged;

  /// Whether the dropdown is interactive. When false, the control appears dimmed.
  final bool enabled;

  @override
  Widget build(BuildContext context) => _wrap(
    AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : .5,
        child: DropdownButton<Category?>(
          value: value,
          dropdownColor: Colors.blueGrey[500],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: const SizedBox.shrink(),
          items: [
            const DropdownMenuItem<Category?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.layers, color: Colors.white, size: 18),
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
                    Icon(c.icon, color: c.color, size: 18),
                    const SizedBox(width: 6),
                    Text(c.label, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    ),
  );

  /// Wraps the dropdown in a styled container with rounded corners.
  Widget _wrap(Widget child) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blueGrey[500],
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(child: child),
  );
}
