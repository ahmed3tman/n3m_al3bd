import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task_list_model.dart';

class DailyTaskStorageService {
  static const String _currentDayKey = 'daily_task_current_day';
  static const String _historyKey = 'daily_task_history';

  /// Save the current day's task list
  Future<void> saveCurrentDay(DailyTaskList taskList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentDayKey, jsonEncode(taskList.toMap()));
  }

  /// Load the current day's task list
  Future<DailyTaskList?> loadCurrentDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_currentDayKey);

      if (data == null) return null;

      final map = jsonDecode(data) as Map<String, dynamic>;
      return DailyTaskList.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  /// Save a day to history
  Future<void> saveDayToHistory(DailyTaskList taskList) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    // Check if this day already exists in history
    final existingIndex = history.indexWhere(
      (day) => day.dateString == taskList.dateString,
    );

    if (existingIndex >= 0) {
      // Update existing day
      history[existingIndex] = taskList;
    } else {
      // Add new day
      history.add(taskList);
    }

    // Sort by date (newest first)
    history.sort((a, b) => b.date.compareTo(a.date));

    // Save to storage
    final historyMaps = history.map((day) => day.toMap()).toList();
    await prefs.setString(_historyKey, jsonEncode(historyMaps));
  }

  /// Load all history
  Future<List<DailyTaskList>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_historyKey);

      if (data == null) return [];

      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map(
            (item) =>
                DailyTaskList.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear current day (used when creating a new day)
  Future<void> clearCurrentDay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentDayKey);
  }

  /// Get a specific day from history by date
  Future<DailyTaskList?> getDayByDate(DateTime date) async {
    final history = await loadHistory();
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      return history.firstWhere((day) => day.dateString == dateString);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentDayKey);
    await prefs.remove(_historyKey);
  }
}
