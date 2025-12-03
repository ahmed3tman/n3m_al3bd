import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/daily_task_list_model.dart';
import '../data/services/daily_task_storage_service.dart';
import '../data/services/prayer_times_service.dart';
import 'salaty_state.dart';

class SalatyCubit extends Cubit<SalatyState> {
  final DailyTaskStorageService _storageService;
  final PrayerTimesService _prayerTimesService;
  Timer? _midnightTimer;
  Timer? _unlockTimer;
  bool _isDisposed = false;

  SalatyCubit({
    DailyTaskStorageService? storageService,
    PrayerTimesService? prayerTimesService,
  }) : _storageService = storageService ?? DailyTaskStorageService(),
       _prayerTimesService = prayerTimesService ?? PrayerTimesService(),
       super(const SalatyState()) {
    _scheduleMidnightReset();
    _scheduleTaskUnlockCheck();
  }

  /// Initialize - load current day or create new one
  Future<void> initialize() async {
    emit(state.copyWith(status: SalatyStatus.loading));

    try {
      // Load history first
      final history = await _storageService.loadHistory();

      // Load current day from storage
      var currentDay = await _storageService.loadCurrentDay();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Check if we have valid cached data for today
      if (currentDay != null && !currentDay.date.isBefore(todayDate)) {
        // We have valid data for today! Show it immediately.

        // Update lock states for existing day
        currentDay = _updateTaskLockStates(currentDay);

        // Get cached prayer times if available in the day model
        final prayerTimes = currentDay.prayerTimes;

        final nextPrayer = prayerTimes != null
            ? _prayerTimesService.getNextPrayer(prayerTimes)
            : null;

        emit(
          state.copyWith(
            status: SalatyStatus.success,
            currentDay: currentDay,
            history: history,
            todayPrayerTimes: prayerTimes,
            nextPrayer: nextPrayer,
          ),
        );

        // Now trigger background update to refresh if needed
        _updatePrayerTimesInBackground();
        return;
      }

      // If we are here, we need to create a new day or rotate the day

      // Save old day to history if exists
      if (currentDay != null) {
        await _storageService.saveDayToHistory(currentDay);
      }

      // Create new day (this might take a moment as it needs prayer times)
      // We try to get cached prayer times first inside _createNewDay logic ideally,
      // but let's just call _createNewDay which calls getTodayPrayerTimes.
      currentDay = await _createNewDay();

      // Reload history to include the saved day
      final updatedHistory = await _storageService.loadHistory();

      final nextPrayer = currentDay.prayerTimes != null
          ? _prayerTimesService.getNextPrayer(currentDay.prayerTimes!)
          : null;

      emit(
        state.copyWith(
          status: SalatyStatus.success,
          currentDay: currentDay,
          history: updatedHistory,
          todayPrayerTimes: currentDay.prayerTimes,
          nextPrayer: nextPrayer,
        ),
      );

      // Trigger background update just in case
      _updatePrayerTimesInBackground();
    } catch (e) {
      emit(state.copyWith(status: SalatyStatus.failure, error: e.toString()));
    }
  }

  /// Update prayer times in background and refresh state if changed
  Future<void> _updatePrayerTimesInBackground() async {
    try {
      final newPrayerTimes = await _prayerTimesService.updatePrayerTimes();

      // Check if cubit was disposed during async operation
      if (_isDisposed || newPrayerTimes == null || state.currentDay == null) {
        return;
      }

      // Check if times actually changed to avoid unnecessary rebuilds
      final currentTimes = state.todayPrayerTimes;
      if (currentTimes != null &&
          currentTimes.fajr == newPrayerTimes.fajr &&
          currentTimes.dhuhr == newPrayerTimes.dhuhr &&
          currentTimes.asr == newPrayerTimes.asr &&
          currentTimes.maghrib == newPrayerTimes.maghrib &&
          currentTimes.isha == newPrayerTimes.isha &&
          currentTimes.locationName == newPrayerTimes.locationName) {
        return;
      }

      // Update state with new times
      final nextPrayer = _prayerTimesService.getNextPrayer(newPrayerTimes);

      // We also need to update the current day's prayer times if it was created today
      // Note: DailyTaskList doesn't have a copyWith for prayerTimes directly exposed easily
      // or we might need to recreate it.
      // However, DailyTaskList holds the prayer times.

      // Let's update the current day model with new prayer times
      // We need to recreate the tasks with new unlock times based on new prayer times
      final updatedDay = DailyTaskList.create(
        state.currentDay!.date,
        newPrayerTimes,
      );

      // Preserve completion status
      final preservedTasks = updatedDay.tasks.map((newTask) {
        final oldTask = state.currentDay!.tasks.firstWhere(
          (t) => t.id == newTask.id,
        );
        return newTask.copyWith(isCompleted: oldTask.isCompleted);
      }).toList();

      final finalDay = updatedDay.copyWith(tasks: preservedTasks);

      // Final check before emitting
      if (_isDisposed) return;

      emit(
        state.copyWith(
          todayPrayerTimes: newPrayerTimes,
          currentDay: finalDay,
          nextPrayer: nextPrayer,
        ),
      );

      await _storageService.saveCurrentDay(finalDay);
    } catch (e) {
      // Silent failure for background update
      if (!_isDisposed) {
        print('Background prayer time update failed: $e');
      }
    }
  }

  /// Create a new day with fresh tasks
  Future<DailyTaskList> _createNewDay() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Get prayer times
    final prayerTimes = await _prayerTimesService.getTodayPrayerTimes();

    if (prayerTimes == null) {
      throw Exception('Unable to get prayer times');
    }

    // Create new task list
    final newDay = DailyTaskList.create(todayDate, prayerTimes);

    // Save to storage
    await _storageService.saveCurrentDay(newDay);

    return newDay;
  }

  /// Update task lock states based on current time
  DailyTaskList _updateTaskLockStates(DailyTaskList taskList) {
    final now = DateTime.now();
    final updatedTasks = taskList.tasks.map((task) {
      if (task.isPrayer && task.unlockTime != null) {
        final shouldBeUnlocked = now.isAfter(task.unlockTime!);
        if (shouldBeUnlocked && task.isLocked) {
          return task.copyWith(isLocked: false);
        }
      }
      return task;
    }).toList();

    return taskList.copyWith(tasks: updatedTasks);
  }

  /// Toggle task completion
  Future<void> toggleTask(String taskId) async {
    if (state.currentDay == null) return;

    final updatedTasks = state.currentDay!.tasks.map((task) {
      if (task.id == taskId && !task.isLocked && task.isPrayer) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    final updatedDay = state.currentDay!.copyWith(tasks: updatedTasks);

    emit(state.copyWith(currentDay: updatedDay));

    // Save to storage
    await _storageService.saveCurrentDay(updatedDay);
  }

  /// Update Wird amount
  Future<void> updateWirdAmount(int amount) async {
    if (state.currentDay == null) return;

    final updatedTasks = state.currentDay!.tasks.map((task) {
      if (!task.isPrayer) {
        return task.copyWith(wirdAmount: amount, isCompleted: amount > 0);
      }
      return task;
    }).toList();

    final updatedDay = state.currentDay!.copyWith(tasks: updatedTasks);

    emit(state.copyWith(currentDay: updatedDay));

    // Save to storage
    await _storageService.saveCurrentDay(updatedDay);
  }

  /// Manually save current day to history
  Future<void> saveCurrentDayToHistory() async {
    if (state.currentDay == null) return;
    await _storageService.saveDayToHistory(state.currentDay!);
    await loadHistory(); // Reload history to reflect changes
  }

  /// Load history
  Future<void> loadHistory() async {
    final history = await _storageService.loadHistory();
    emit(state.copyWith(history: history));
  }

  /// Schedule midnight reset
  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    _midnightTimer = Timer(duration, () async {
      // Save current day to history
      if (state.currentDay != null) {
        await _storageService.saveDayToHistory(state.currentDay!);
      }

      // Create new day and reload
      await initialize();

      // Schedule next midnight reset
      _scheduleMidnightReset();
    });
  }

  /// Schedule periodic task unlock check (every minute)
  void _scheduleTaskUnlockCheck() {
    _unlockTimer?.cancel();

    _unlockTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (state.currentDay != null) {
        final updatedDay = _updateTaskLockStates(state.currentDay!);

        // Check if any task was unlocked
        var hasChanges = false;
        for (var i = 0; i < updatedDay.tasks.length; i++) {
          if (updatedDay.tasks[i].isLocked !=
              state.currentDay!.tasks[i].isLocked) {
            hasChanges = true;
            break;
          }
        }

        if (hasChanges) {
          emit(state.copyWith(currentDay: updatedDay));
          _storageService.saveCurrentDay(updatedDay);
        }

        // Update next prayer
        if (state.todayPrayerTimes != null) {
          final nextPrayer = _prayerTimesService.getNextPrayer(
            state.todayPrayerTimes!,
          );
          if (nextPrayer != state.nextPrayer) {
            emit(state.copyWith(nextPrayer: nextPrayer));
          }
        }
      }
    });
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    _midnightTimer?.cancel();
    _unlockTimer?.cancel();
    return super.close();
  }
}
