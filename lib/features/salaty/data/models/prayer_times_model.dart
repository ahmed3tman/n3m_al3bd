enum DayColor {
  green,
  yellow,
  red;

  static DayColor calculate(int completedCount, int totalCount) {
    if (completedCount == totalCount) return DayColor.green;
    if (totalCount - completedCount <= 3) return DayColor.yellow;
    return DayColor.red;
  }
}

class PrayerTimes {
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;
  final String? locationName;

  const PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    this.locationName,
  });

  Map<String, dynamic> toMap() {
    return {
      'fajr': fajr.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'date': date.toIso8601String(),
      if (locationName != null) 'locationName': locationName,
    };
  }

  factory PrayerTimes.fromMap(Map<String, dynamic> map) {
    return PrayerTimes(
      fajr: DateTime.parse(map['fajr'] as String),
      dhuhr: DateTime.parse(map['dhuhr'] as String),
      asr: DateTime.parse(map['asr'] as String),
      maghrib: DateTime.parse(map['maghrib'] as String),
      isha: DateTime.parse(map['isha'] as String),
      date: DateTime.parse(map['date'] as String),
      locationName: map['locationName'] as String?,
    );
  }

  DateTime? getPrayerTime(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }
}
