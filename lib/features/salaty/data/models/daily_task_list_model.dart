import 'daily_task_model.dart';
import 'prayer_times_model.dart';

class DailyTaskList {
  final DateTime date;
  final List<DailyTask> tasks;
  final PrayerTimes? prayerTimes;

  const DailyTaskList({
    required this.date,
    required this.tasks,
    this.prayerTimes,
  });

  int get completedCount =>
      tasks.where((t) => t.isPrayer && t.isCompleted).length;

  int get totalCount => tasks.where((t) => t.isPrayer).length;

  int get wirdScore {
    final wirdTask = tasks.firstWhere(
      (t) => !t.isPrayer,
      orElse: () => DailyTask(
        id: 'temp',
        type: TaskType.wird,
        isLocked: false,
        wirdAmount: 0,
      ),
    );
    return wirdTask.wirdAmount;
  }

  DayColor get color => DayColor.calculate(completedCount, totalCount);

  bool get isComplete => completedCount == totalCount;

  String get dateString {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DailyTaskList copyWith({
    DateTime? date,
    List<DailyTask>? tasks,
    PrayerTimes? prayerTimes,
  }) {
    return DailyTaskList(
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      prayerTimes: prayerTimes ?? this.prayerTimes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'prayerTimes': prayerTimes?.toMap(),
    };
  }

  factory DailyTaskList.fromMap(Map<String, dynamic> map) {
    return DailyTaskList(
      date: DateTime.parse(map['date'] as String),
      tasks: (map['tasks'] as List<dynamic>)
          .map((t) => DailyTask.fromMap(Map<String, dynamic>.from(t as Map)))
          .toList(),
      prayerTimes: map['prayerTimes'] != null
          ? PrayerTimes.fromMap(
              Map<String, dynamic>.from(map['prayerTimes'] as Map),
            )
          : null,
    );
  }

  /// Create a new task list for a given date with prayer times
  factory DailyTaskList.create(DateTime date, PrayerTimes prayerTimes) {
    final now = DateTime.now();

    return DailyTaskList(
      date: DateTime(date.year, date.month, date.day),
      prayerTimes: prayerTimes,
      tasks: [
        DailyTask(
          id: 'fajr_${date.toIso8601String()}',
          type: TaskType.fajr,
          isLocked: now.isBefore(prayerTimes.fajr),
          unlockTime: prayerTimes.fajr,
        ),
        DailyTask(
          id: 'dhuhr_${date.toIso8601String()}',
          type: TaskType.dhuhr,
          isLocked: now.isBefore(prayerTimes.dhuhr),
          unlockTime: prayerTimes.dhuhr,
        ),
        DailyTask(
          id: 'asr_${date.toIso8601String()}',
          type: TaskType.asr,
          isLocked: now.isBefore(prayerTimes.asr),
          unlockTime: prayerTimes.asr,
        ),
        DailyTask(
          id: 'maghrib_${date.toIso8601String()}',
          type: TaskType.maghrib,
          isLocked: now.isBefore(prayerTimes.maghrib),
          unlockTime: prayerTimes.maghrib,
        ),
        DailyTask(
          id: 'isha_${date.toIso8601String()}',
          type: TaskType.isha,
          isLocked: now.isBefore(prayerTimes.isha),
          unlockTime: prayerTimes.isha,
        ),
        DailyTask(
          id: 'wird_${date.toIso8601String()}',
          type: TaskType.wird,
          isLocked: false, // Wird is always unlocked
          unlockTime: null,
        ),
      ],
    );
  }
}
