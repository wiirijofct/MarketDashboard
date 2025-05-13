import 'package:flutter/material.dart';
import '../data/fake_market_data.dart';

/// Extension for visual properties related to [Category] enum
extension CategoryVisual on Category {
  /// Returns the unique color associated with this category
  Color get color => switch (this) {
    Category.bakery => Colors.brown.shade400,
    Category.cleaningProducts => Colors.blue.shade400,
    Category.dairy => Colors.yellow.shade600,
    Category.fruit => Colors.red.shade400,
    Category.frozenFood => Colors.cyan.shade600,
    Category.meat => Colors.pink.shade400,
    Category.personalCare => Colors.purple.shade400,
    Category.snacks => Colors.orange.shade400,
  };

  /// Returns a representative Material icon for this category
  IconData get icon => switch (this) {
    Category.bakery => Icons.bakery_dining,
    Category.cleaningProducts => Icons.cleaning_services,
    Category.dairy => Icons.icecream,
    Category.fruit => Icons.apple,
    Category.frozenFood => Icons.ac_unit,
    Category.meat => Icons.set_meal,
    Category.personalCare => Icons.spa,
    Category.snacks => Icons.fastfood,
  };

  /// Creates a light background tint based on the category's color
  ///
  /// Returns a very light pastel version of the category color or
  /// transparent if the category is null (representing "Overall")
  Color backgroundTint(Category? c) {
    if (c == null) return Colors.transparent;
    final hsl = HSLColor.fromColor(c.color);
    return hsl.withLightness(0.94).toColor();
  }
}
