import 'package:hive/hive.dart';

import '../../core/services/hive_encryption_service.dart';
import '../model/calorie_entry.dart';

class CalorieRepository {
  static const _hiveBoxName = "calorie_entries";

  late Box<CalorieEntry> _hiveBox;

  Future<void> init() async {
    final encryptionKey = await HiveEncryption.getKey();

    _hiveBox = await Hive.openBox<CalorieEntry>(
      _hiveBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  List<CalorieEntry> getEntries() =>
      _hiveBox.values.where((e) => !e.isDeleted).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> addEntry(CalorieEntry entry) async {
    await _hiveBox.put(entry.id, entry);
  }

  Future<void> updateEntry(CalorieEntry entry) async {
    entry.updatedAt = DateTime.now().toUtc();
    await _hiveBox.put(entry.id, entry);
  }

  Future<void> deleteEntry(CalorieEntry entry) async {
    entry.isDeleted = true;
    entry.updatedAt = DateTime.now().toUtc();
    await entry.save();
  }

  Map<DateTime, int> getCaloriesForDays() {
    final Map<DateTime, int> totals = {};

    for (final e in _hiveBox.values.where((e) => !e.isDeleted)) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      totals[day] = (totals[day] ?? 0) + e.calories;
    }

    return totals;
  }

  Future<void> upsertFromRemote(CalorieEntry entry) async {
    final local = _hiveBox.get(entry.id);

    if (local == null || entry.updatedAt.isAfter(local.updatedAt)) {
      await _hiveBox.put(entry.id, entry);
    }
  }

  List<CalorieEntry> getUnsyncedEntries() =>
      _hiveBox.values.where((e) => !e.isSynced).toList();

  Future<void> clearLocal() async {
    await _hiveBox.clear();
  }
}
