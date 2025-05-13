import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

/// Categories of products sold in the market
enum Category {
  bakery,
  cleaningProducts,
  dairy,
  fruit,
  frozenFood,
  meat,
  personalCare,
  snacks,
}

/// Extension to provide human-readable labels for categories
extension CategoryName on Category {
  String get label => switch (this) {
    Category.bakery => 'Bakery',
    Category.cleaningProducts => 'Cleaning Products',
    Category.dairy => 'Dairy',
    Category.fruit => 'Fruit',
    Category.frozenFood => 'Frozen Food',
    Category.meat => 'Meat',
    Category.personalCare => 'Personal Care',
    Category.snacks => 'Snacks',
  };
}

/// Represents sales data for a specific product category on a single day
class DailyCategoryData {
  /// Revenue in euros
  final double sales;

  /// Number of units requested by customers
  final int demand;

  /// Number of units remaining in inventory at end of day
  final int stock;

  const DailyCategoryData({
    required this.sales,
    required this.demand,
    required this.stock,
  });
}

/// Aggregates data for all product categories on a specific date
class DailySnapshot {
  /// The date of this snapshot
  final DateTime date;

  /// Data for each product category
  final Map<Category, DailyCategoryData> perCat;

  const DailySnapshot(this.date, this.perCat);
}

/// Repository providing access to market data
class FakeDataRepository {
  static final FakeDataRepository _instance = FakeDataRepository._internal();

  /// Factory constructor that returns singleton instance
  factory FakeDataRepository() => _instance;

  final List<DailySnapshot> _days;

  FakeDataRepository._internal() : _days = _generateFakeDays();

  /// All daily snapshots in chronological order
  List<DailySnapshot> get days => _days;

  /// Calculates total sales across all categories for a specific date
  double totalSalesOn(DateTime date) =>
      _lookup(date).perCat.values.fold(0.0, (sum, d) => sum + d.sales);

  /// Calculates growth rate compared to previous day
  ///
  /// Returns a value where -1.0 means 100% drop, 0.0 means no change,
  /// and 0.2 means 20% growth
  double growthSinceYesterday(DateTime date) {
    final idx = _indexOf(date);
    if (idx == 0) return 0;
    final today = totalSalesOn(date);
    final yest = totalSalesOn(_days[idx - 1].date);
    return (today - yest) / yest;
  }

  /// Calculates growth rate compared to last week
  double growthSinceLastWeek(DateTime date) {
    final idx = _indexOf(date);
    if (idx < 7) return 0;
    final today = totalSalesOn(date);
    final week = totalSalesOn(_days[idx - 7].date);
    return (today - week) / week;
  }

  /// Calculates growth rate compared to last month
  double growthSinceLastMonth(DateTime date) {
    final idx = _indexOf(date);
    if (idx < 30) return 0;
    final today = totalSalesOn(date);
    final month = totalSalesOn(_days[idx - 30].date);
    return (today - month) / month;
  }

  /// Identifies the category with highest sales on the given date
  Category bestSellingCategory(DateTime date) {
    final map = _lookup(date).perCat;
    return map.keys.reduce((a, b) => map[a]!.sales >= map[b]!.sales ? a : b);
  }

  /// Identifies the category with highest customer demand on the given date
  Category mostDemandedCategory(DateTime date) {
    final map = _lookup(date).perCat;
    return map.keys.reduce((a, b) => map[a]!.demand >= map[b]!.demand ? a : b);
  }

  /// Identifies the category with highest (or lowest) stock levels
  ///
  /// Set [lowest] to true to find the category with least stock
  Category stockLeader(DateTime date, {bool lowest = false}) {
    final map = _lookup(date).perCat;
    return map.keys.reduce((a, b) {
      final cond =
          lowest
              ? map[a]!.stock <= map[b]!.stock
              : map[a]!.stock >= map[b]!.stock;
      return cond ? a : b;
    });
  }

  /// Returns data points for a time-series chart for the specified category and metric
  ///
  /// [metric] must be one of: 'sales', 'demand', or 'stock'
  Iterable<FlSpot> timeSeries(Category category, String metric) sync* {
    for (var i = 0; i < _days.length; ++i) {
      final d = _days[i].perCat[category]!;
      final y = switch (metric) {
        'sales' => d.sales,
        'demand' => d.demand.toDouble(),
        'stock' => d.stock.toDouble(),
        _ => 0.0,
      };
      yield FlSpot(i.toDouble(), y.toDouble());
    }
  }

  /// Finds the snapshot for a specific date
  DailySnapshot _lookup(DateTime d) =>
      _days.firstWhere((e) => _isSameDate(e.date, d));

  /// Finds the index of a snapshot for a specific date
  int _indexOf(DateTime d) => _days.indexWhere((e) => _isSameDate(e.date, d));

  /// Compares if two dates represent the same calendar day
  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Generates 180 days of realistic market data
  static List<DailySnapshot> _generateFakeDays() {
    final rng = Random(42); // stable seed for consistent data across runs

    // Base metrics for each category
    final baseSales = {
      for (final c in Category.values) c: rng.nextInt(900) + 400,
    };
    final baseDemand = {
      for (final c in Category.values) c: rng.nextInt(90) + 30,
    };
    final baseStock = {
      for (final c in Category.values) c: rng.nextInt(900) + 600,
    };

    // Generate 180 days (approximately 6 months) of data
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 179));

    final list = <DailySnapshot>[];
    var currentStock = Map<Category, int>.from(baseStock);

    for (int offset = 0; offset < 180; offset++) {
      final date = start.add(Duration(days: offset));
      final perCat = <Category, DailyCategoryData>{};

      for (final c in Category.values) {
        // Model a gentle upward trend with random daily fluctuations
        final dayIdx = offset.toDouble();
        final trend = 1 + 0.0015 * dayIdx; // +0.15% per day
        final noise = 0.85 + rng.nextDouble() * .3; // 0.85 – 1.15

        final sales = baseSales[c]! * trend * noise;
        final demand = (baseDemand[c]! * trend * noise).round();

        // Units sold is limited by available stock
        final unitsSold = min(demand, currentStock[c]!);
        currentStock[c] = currentStock[c]! - unitsSold;

        // Replenish inventory every Monday
        if (date.weekday == DateTime.monday) {
          currentStock[c] = currentStock[c]! + rng.nextInt(500) + 300;
        }

        perCat[c] = DailyCategoryData(
          sales: sales,
          demand: demand,
          stock: currentStock[c]!,
        );
      }

      list.add(DailySnapshot(date, perCat));
    }

    return list;
  }
}
