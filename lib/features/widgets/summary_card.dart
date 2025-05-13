import 'package:flutter/material.dart';

/// A card widget that displays a summary with a title and value.
///
/// This widget creates a card-like container with a title and value display.
/// It supports optional features like a leading widget, underline decoration,
/// custom background color, and tap functionality.
class SummaryCard extends StatelessWidget {
  /// Creates a summary card.
  ///
  /// The [title] and [value] parameters are required and cannot be null.
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.leading,
    this.underline = false,
    this.bgColor,
    this.cursor,
    this.onTap,
  });

  /// The title text displayed at the top of the card.
  final String title;

  /// The main value text displayed prominently in the card.
  final String value;

  /// An optional widget to display before the value.
  final Widget? leading;

  /// Whether to show an underline decoration below the content.
  final bool underline;

  /// The background color of the card. Defaults to white if not specified.
  final Color? bgColor;

  /// The cursor to show when hovering over the card.
  final MouseCursor? cursor;

  /// Callback function when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor:
        cursor ??
        (onTap != null ? SystemMouseCursors.click : MouseCursor.defer),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            if (leading == null)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Row(
                children: [
                  leading!,
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (underline)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
