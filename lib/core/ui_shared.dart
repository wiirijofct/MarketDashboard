import 'package:flutter/material.dart';

/* ---------- constants everyone can import ------------------------- */
abstract class UI {
  static const cardWidth = 250.0;
  static const gap = 24.0;
  static const chartHeight = 450.0;
  static const contentWidth = cardWidth * 3 + gap * 2;
}

/* ---------- sidebar used by every dashboard ----------------------- */
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, required this.current});

  final String current; // "Sales" | "Stock" | "Demand"

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

/* ---------- small grey stat card ---------------------------------- */
class SummaryCard extends StatelessWidget {
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
      // animate fade in/out
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
      //  ⬅ cursor on hover
      cursor: cursor,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
