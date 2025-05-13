import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../data/fake_market_data.dart';

/// A dialog that allows users to select multiple categories for comparison.
///
/// This dialog displays a list of all available categories with checkboxes
/// to enable selection. Users can apply their selection or cancel the operation.
class CompareCategoriesDialog extends StatefulWidget {
  /// Creates a category comparison dialog with the given initial selection.
  ///
  /// The [initialSelection] parameter specifies which categories should be
  /// pre-selected when the dialog opens.
  const CompareCategoriesDialog({super.key, required this.initialSelection});

  /// The set of categories that are initially selected.
  final Set<Category> initialSelection;

  @override
  State<CompareCategoriesDialog> createState() =>
      _CompareCategoriesDialogState();
}

class _CompareCategoriesDialogState extends State<CompareCategoriesDialog> {
  /// The current selection of categories, initialized with the widget's initial selection.
  late final Set<Category> _selection = {...widget.initialSelection};

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Compare categories'),
    content: SizedBox(
      width: 260,
      child: ListView(
        shrinkWrap: true,
        children:
            Category.values
                .map(
                  (c) => CheckboxListTile(
                    value: _selection.contains(c),
                    onChanged:
                        (v) => setState(() {
                          v == true ? _selection.add(c) : _selection.remove(c);
                        }),
                    // Fixed Row to handle overflow properly
                    title: Row(
                      children: [
                        Icon(c.icon, color: c.color, size: 18),
                        const SizedBox(width: 8),
                        // Wrap the text in an Expanded widget to handle overflow
                        Expanded(
                          child: Text(c.label, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    ),
    // Make dialog more responsive
    contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, _selection),
        child: const Text('Apply'),
      ),
    ],
  );
}
