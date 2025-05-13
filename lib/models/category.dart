import 'package:flutter/material.dart';
import '../data/fake_market_data.dart';

extension CategoryVisual on Category {
  /// Unique color for the category
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

  /// A Material icon that “fits”
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

  Color backgroundTint(Category? c) {
    if (c == null) return Colors.transparent; // “Overall”
    final hsl = HSLColor.fromColor(c.color); // use the vivid color
    return hsl.withLightness(0.94).toColor(); // very light pastel
  }
}
