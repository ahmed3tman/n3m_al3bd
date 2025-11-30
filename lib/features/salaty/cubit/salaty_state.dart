import '../data/models/daily_task_list_model.dart';
import '../data/models/prayer_times_model.dart';

enum SalatyStatus { initial, loading, success, failure }

class SalatyState {
  final SalatyStatus status;
  final DailyTaskList? currentDay;
  final List<DailyTaskList> history;
  final PrayerTimes? todayPrayerTimes;
  final String? error;
  final String? nextPrayer;

  const SalatyState({
    this.status = SalatyStatus.initial,
    this.currentDay,
    this.history = const [],
    this.todayPrayerTimes,
    this.error,
    this.nextPrayer,
  });

  SalatyState copyWith({
    SalatyStatus? status,
    DailyTaskList? currentDay,
    List<DailyTaskList>? history,
    PrayerTimes? todayPrayerTimes,
    String? error,
    String? nextPrayer,
  }) {
    return SalatyState(
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      history: history ?? this.history,
      todayPrayerTimes: todayPrayerTimes ?? this.todayPrayerTimes,
      error: error ?? this.error,
      nextPrayer: nextPrayer ?? this.nextPrayer,
    );
  }
}
