import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

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

/// Data *per category* for a single calendar day
class DailyCategoryData {
  final double sales; // € revenue
  final int demand; // units requested (shopping list / enquiries)
  final int stock; // units that remained on hand at end‑of‑day

  const DailyCategoryData({
    required this.sales,
    required this.demand,
    required this.stock,
  });
}

/// Data for one date, *all* categories
class DailySnapshot {
  final DateTime date;
  final Map<Category, DailyCategoryData> perCat;

  const DailySnapshot(this.date, this.perCat);
}

class FakeDataRepository {
  static final FakeDataRepository _instance = FakeDataRepository._internal();
  factory FakeDataRepository() => _instance;

  final List<DailySnapshot> _days;

  FakeDataRepository._internal() : _days = _generateFakeDays();

  // All snapshots, earliest ➜ latest
  List<DailySnapshot> get days => _days;

  // ───────── Helpers your UI cards can call ─────────

  /// Total sales of *all* categories for [date].
  double totalSalesOn(DateTime date) =>
      _lookup(date).perCat.values.fold(0.0, (sum, d) => sum + d.sales);

  /// ∆ vs. previous day (‑1 ≈ 100 % drop, 0 = flat, 0.2 = +20 %)
  double growthSinceYesterday(DateTime date) {
    final idx = _indexOf(date);
    if (idx == 0) return 0;
    final today = totalSalesOn(date);
    final yest = totalSalesOn(_days[idx - 1].date);
    return (today - yest) / yest;
  }

  double growthSinceLastWeek(DateTime date) {
    final idx = _indexOf(date);
    if (idx < 7) return 0;
    final today = totalSalesOn(date);
    final week = totalSalesOn(_days[idx - 7].date);
    return (today - week) / week;
  }

  double growthSinceLastMonth(DateTime date) {
    final idx = _indexOf(date);
    if (idx < 30) return 0;
    final today = totalSalesOn(date);
    final month = totalSalesOn(_days[idx - 30].date);
    return (today - month) / month;
  }

  Category bestSellingCategory(DateTime date) {
    final map = _lookup(date).perCat;
    return map.keys.reduce((a, b) => map[a]!.sales >= map[b]!.sales ? a : b);
  }

  Category mostDemandedCategory(DateTime date) {
    final map = _lookup(date).perCat;
    return map.keys.reduce((a, b) => map[a]!.demand >= map[b]!.demand ? a : b);
  }

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

  /// Returns a ready‑to‑plot time‑series for the chosen [category] & [metric].
  ///   metric = 'sales' | 'demand' | 'stock'
  Iterable<FlSpot> timeSeries(Category category, String metric) sync* {
    for (var i = 0; i < _days.length; ++i) {
      final d = _days[i].perCat[category]!;
      final y = switch (metric) {
        'sales' => d.sales,
        'demand' => d.demand.toDouble(),
        'stock' => d.stock.toDouble(),
        _ => 0,
      };
      yield FlSpot(i.toDouble(), y.toDouble());
    }
  }

  // -----------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------

  DailySnapshot _lookup(DateTime d) =>
      _days.firstWhere((e) => _isSameDate(e.date, d));

  int _indexOf(DateTime d) => _days.indexWhere((e) => _isSameDate(e.date, d));

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // -----------------------------------------------------------------
  // Fake data generator
  // -----------------------------------------------------------------

  static List<DailySnapshot> _generateFakeDays() {
    final rng = Random(42); // stable seed = same data each run
    // Give every category its own “profile”
    final baseSales = {
      // € per day
      for (final c in Category.values) c: rng.nextInt(900) + 400,
    };
    final baseDemand = {
      // units per day
      for (final c in Category.values) c: rng.nextInt(90) + 30,
    };
    final baseStock = {
      for (final c in Category.values) c: rng.nextInt(900) + 600,
    };

    // Simulate 180 days (≈ 6 months)
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 179));

    final list = <DailySnapshot>[];
    var currentStock = Map<Category, int>.from(baseStock);

    for (int offset = 0; offset < 180; offset++) {
      final date = start.add(Duration(days: offset));

      final perCat = <Category, DailyCategoryData>{};

      for (final c in Category.values) {
        // Add gentle upward trend + random daily noise
        final dayIdx = offset.toDouble();
        final trend = 1 + 0.0015 * dayIdx; // +0.15 % per day
        final noise = 0.85 + rng.nextDouble() * .3; // 0.85 – 1.15

        final sales = baseSales[c]! * trend * noise;
        final demand = (baseDemand[c]! * trend * noise).round();

        // Stock leaves the shop when it’s sold (capped at available units)
        final unitsSold = min(demand, currentStock[c]!);
        currentStock[c] = currentStock[c]! - unitsSold;

        // Re‑stock every Monday
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
