import 'dart:async';

import 'package:calo_pulse/core/repo/network_repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../model/calorie_entry.dart';
import '../model/day_summary.dart';
import '../repo/calorie_remote_repo.dart';
import '../repo/calorie_repo.dart';

class CalorieProvider extends ChangeNotifier {
  final CalorieRepository? _calorieRepo;
  final CalorieRemmoteRepo? _remoteRepo;
  StreamSubscription? _socketStream;
  DateTime? filterStart;
  DateTime? filterEnd;
  final networkService = NetworkRepo();
  StreamSubscription? _connectivitySub;

  final List<CalorieEntry> _entries = [];
  List<CalorieEntry> get entries => List.unmodifiable(_entries);

  final String? _uid;
  String? get uid => _uid;

  String _error = "";
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _fromDate;
  DateTime? get fromDate => _fromDate;

  DateTime? _toDate;
  DateTime? get toDate => _toDate;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _searchMode = false;
  bool get searchMode => _searchMode;

  List<CalorieEntry> get filteredEntries {
    if (_fromDate == null || _toDate == null) {
      if (_searchQuery.isEmpty) {
        return _entries;
      } else {
        return _entries
            .where(
              (e) =>
                  (e.note ?? "").toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  (e.mealType ?? "").toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }
    }
    if (_searchQuery.isEmpty) {
      return _entries.where((e) {
        final d = e.date;
        return !d.isBefore(_fromDate!) && !d.isAfter(_toDate!);
      }).toList();
    } else {
      return _entries.where((e) {
        final d = e.date;
        return !d.isBefore(_fromDate!) &&
            !d.isAfter(_toDate!) &&
            ((e.note ?? "").toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (e.mealType ?? "").toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ));
      }).toList();
    }
  }

  CalorieProvider(this._calorieRepo, this._remoteRepo, this._uid) {
    init();
  }

  CalorieProvider.empty()
    : _calorieRepo = null,
      _uid = null,
      _remoteRepo = null;

  init() async {
    listenToConnectivity();
    updateLoader(isLoading: true);
    try {
      if (_uid != null) {
        _socketStream?.cancel();
        _socketStream = _remoteRepo?.getEntryStream(_uid).listen((
          snapshot,
        ) async {
          for (final doc in snapshot.docs) {
            final entry = CalorieEntry.fromJson(doc.data());
            await _calorieRepo?.upsertFromRemote(entry);
          }

          _loadEntries();
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      updateLoader(isLoading: false);
      _error = "Failed ,Please try again";
    }
  }

  List<DaySummary> get daySummaries {
    final Map<DateTime, int> totals = {};

    for (final entry in (filteredEntries)) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);

      totals[day] = (totals[day] ?? 0) + entry.calories;
    }

    final summaries = totals.entries
        .map((e) => DaySummary(date: e.key, totalCalories: e.value))
        .toList();

    summaries.sort((a, b) => b.date.compareTo(a.date));
    return summaries;
  }

  void _loadEntries() {
    _entries.clear();
    _entries.addAll(_calorieRepo?.getEntries() ?? []);
    updateLoader(isLoading: false);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _socketStream?.cancel();
    super.dispose();
  }

  Future<void> addEntry({
    required DateTime date,
    required int calories,
    String? mealType,
    String? note,
  }) async {
    updateLoader(isLoading: true);
    try {
      final entry = CalorieEntry(
        id: const Uuid().v4(),
        date: date,
        calories: calories,
        mealType: mealType,
        note: note,
      );

      if (_uid != null && await networkService.isConnected) {
        await _calorieRepo?.addEntry(entry);
        await _remoteRepo?.upsertEntry(_uid, entry);
      } else {
        entry.isSynced = false;
        await _calorieRepo?.addEntry(entry);
      }
      _loadEntries();
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      updateLoader(isLoading: false);
      _error = "Failed ,Please try again";
    }
  }

  Future<void> updateEntry(CalorieEntry entry) async {
    updateLoader(isLoading: true);
    try {
      if (_uid != null && await networkService.isConnected) {
        await _calorieRepo?.updateEntry(entry);
        await _remoteRepo?.upsertEntry(_uid, entry);
      } else {
        entry.isSynced = false;
        await _calorieRepo?.updateEntry(entry);
      }
      _loadEntries();
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      updateLoader(isLoading: false);
      _error = "Failed ,Please try again";
    }
  }

  Future<void> deleteEntry(CalorieEntry entry) async {
    updateLoader(isLoading: true);
    try {
      if (_uid != null && await networkService.isConnected) {
        await _calorieRepo?.deleteEntry(entry);
        await _remoteRepo?.softDelete(_uid, entry.id);
      } else {
        entry.isSynced = false;
        await _calorieRepo?.deleteEntry(entry);
      }
      _loadEntries();
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      updateLoader(isLoading: false);
      _error = "Failed ,Please try again";
    }
  }

  List<CalorieEntry> entriesForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _entries.where((entry) {
      final date = entry.date;
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end);
    }).toList();
  }

  Map<DateTime, List<CalorieEntry>> get groupedByDay {
    final Map<DateTime, List<CalorieEntry>> map = {};

    for (final entry in filteredEntries) {
      final day = entry.date;

      map.putIfAbsent(day, () => []);
      map[day]!.add(entry);
    }

    return map;
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void clearDateRange() {
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  void updateLoader({required bool isLoading}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void listenToConnectivity() {
    _connectivitySub = networkService.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none) && _uid != null) {
        _syncProgress();
      }
    });
  }

  Future<void> _syncProgress() async {
    final pending = _calorieRepo?.getUnsyncedEntries();

    if (pending?.isNotEmpty ?? false) {
      for (final entry in pending!) {
        try {
          if (entry.isDeleted) {
            await _remoteRepo?.softDelete(uid!, entry.id);
          } else {
            await _remoteRepo?.upsertEntry(uid!, entry);
          }

          entry.isSynced = true;
          await entry.save();
        } catch (_) {
          break;
        }
      }
    }
  }

  void toggleSearchMode() {
    _searchMode = !_searchMode;
    notifyListeners();
  }

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchMode = false;
    notifyListeners();
  }

  void clearEntries() async {
    await _calorieRepo?.clearLocal();
    _entries.clear();
    notifyListeners();
  }
}
