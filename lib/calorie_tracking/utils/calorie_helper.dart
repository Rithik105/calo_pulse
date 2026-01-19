import '../model/calorie_entry.dart';

Map<DateTime, List<CalorieEntry>> groupByDay(List<CalorieEntry> entries) {
  final Map<DateTime, List<CalorieEntry>> map = {};

  for (final e in entries) {
    final day = DateTime(e.date.year, e.date.month, e.date.day);
    map.putIfAbsent(day, () => []).add(e);
  }

  return map;
}

int totalCalories(List<CalorieEntry> entries) =>
    entries.fold(0, (sum, e) => sum + e.calories);
