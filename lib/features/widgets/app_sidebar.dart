import 'package:flutter/material.dart';

/// A sidebar widget that displays a list of navigational items.
///
/// This widget shows a vertical list of items with icons and labels,
/// highlighting the currently selected item.
class AppSidebar extends StatelessWidget {
  /// Creates an AppSidebar widget.
  ///
  /// The [current] parameter specifies which item should be highlighted as active.
  const AppSidebar({super.key, required this.current});

  /// The label of the currently selected item.
  final String current;

  @override
  Widget build(BuildContext context) {
    final items = <_SidebarItem>[
      const _SidebarItem('Sales', Icons.show_chart),
      const _SidebarItem('Inventory', Icons.inventory_2),
      const _SidebarItem('Customers', Icons.people),
      const _SidebarItem('Reports', Icons.insert_drive_file),
      const _SidebarItem('Settings', Icons.settings),
    ];

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(color: Colors.blueGrey[900]),
      child: ListView.separated(
        itemBuilder: (_, index) {
          final item = items[index];
          final bool isActive = item.label == current;

          return InkWell(
            onTap: () {
              debugPrint('Navigate to ${item.label}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration:
                  isActive
                      ? BoxDecoration(
                        color: Colors.blueGrey[700],
                        borderRadius: BorderRadius.circular(8),
                      )
                      : null,
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: Colors.white.withOpacity(isActive ? 1 : .7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(isActive ? 1 : .7),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemCount: items.length,
      ),
    );
  }
}

/// A model class representing a sidebar navigation item.
class _SidebarItem {
  /// Creates a sidebar item with a label and an icon.
  const _SidebarItem(this.label, this.icon);

  /// The text displayed for this item.
  final String label;

  /// The icon displayed next to the label.
  final IconData icon;
}
