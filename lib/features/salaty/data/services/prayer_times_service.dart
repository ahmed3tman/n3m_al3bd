import 'package:adhan/adhan.dart' as adhan;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  static const String _latKey = 'prayer_times_latitude';
  static const String _lonKey = 'prayer_times_longitude';
  static const String _cachedTimesKey = 'cached_prayer_times';

  /// Get prayer times for the current date based on user location
  Future<PrayerTimes?> getTodayPrayerTimes() async {
    try {
      // 1. Try to return cached prayer times first (Offline-first)
      final cached = await _getCachedPrayerTimes();
      if (cached != null) return cached;

      // 2. If no cache, try to get location and calculate
      return await updatePrayerTimes();
    } catch (e) {
      // In case of any error, return cached times or fallback
      final cached = await _getCachedPrayerTimes();
      if (cached != null) return cached;

      return _calculatePrayerTimes(30.0444, 31.2357);
    }
  }

  /// Force update prayer times by fetching fresh location
  Future<PrayerTimes?> updatePrayerTimes() async {
    try {
      // First try to get location
      final position = await _getLocation();
      if (position != null) {
        return _calculatePrayerTimes(position.latitude, position.longitude);
      }

      // If location not available, try cached location
      final cachedPosition = await _getCachedLocation();
      if (cachedPosition != null) {
        return _calculatePrayerTimes(
          cachedPosition['lat']!,
          cachedPosition['lon']!,
        );
      }

      // Fallback to default location (Cairo)
      return _calculatePrayerTimes(30.0444, 31.2357);
    } catch (e) {
      return null;
    }
  }

  /// Get user's current location with permission handling
  Future<Position?> _getLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permission status
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied || permission.isDenied) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Cache the location
      await _cacheLocation(position.latitude, position.longitude);

      return position;
    } catch (e) {
      return null;
    }
  }

  /// Calculate prayer times using Adhan package
  PrayerTimes _calculatePrayerTimes(double latitude, double longitude) {
    final today = DateTime.now();
    final coordinates = adhan.Coordinates(latitude, longitude);

    // Using Egyptian General Authority of Survey
    final params = adhan.CalculationMethod.egyptian.getParameters();
    params.madhab = adhan.Madhab.shafi; // Shafi madhab for Asr time

    final adhanPrayerTimes = adhan.PrayerTimes.today(coordinates, params);

    final result = PrayerTimes(
      fajr: adhanPrayerTimes.fajr,
      dhuhr: adhanPrayerTimes.dhuhr,
      asr: adhanPrayerTimes.asr,
      maghrib: adhanPrayerTimes.maghrib,
      isha: adhanPrayerTimes.isha,
      date: DateTime(today.year, today.month, today.day),
    );

    // Cache the calculated times
    _cachePrayerTimes(result);

    return result;
  }

  /// Cache location to SharedPreferences
  Future<void> _cacheLocation(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lonKey, lon);
  }

  /// Get cached location from SharedPreferences
  Future<Map<String, double>?> _getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);

    if (lat != null && lon != null) {
      return {'lat': lat, 'lon': lon};
    }
    return null;
  }

  /// Cache prayer times to SharedPreferences
  Future<void> _cachePrayerTimes(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cachedTimesKey,
      '${times.fajr.toIso8601String()},'
      '${times.dhuhr.toIso8601String()},'
      '${times.asr.toIso8601String()},'
      '${times.maghrib.toIso8601String()},'
      '${times.isha.toIso8601String()},'
      '${times.date.toIso8601String()}',
    );
  }

  /// Get cached prayer times from SharedPreferences
  Future<PrayerTimes?> _getCachedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cachedTimesKey);

      if (cached == null) return null;

      final parts = cached.split(',');
      if (parts.length != 6) return null;

      final times = PrayerTimes(
        fajr: DateTime.parse(parts[0]),
        dhuhr: DateTime.parse(parts[1]),
        asr: DateTime.parse(parts[2]),
        maghrib: DateTime.parse(parts[3]),
        isha: DateTime.parse(parts[4]),
        date: DateTime.parse(parts[5]),
      );

      // Only return if it's for today
      final today = DateTime.now();
      if (times.date.year == today.year &&
          times.date.month == today.month &&
          times.date.day == today.day) {
        return times;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the next prayer time from current time
  String? getNextPrayer(PrayerTimes times) {
    final now = DateTime.now();

    if (now.isBefore(times.fajr)) return 'fajr';
    if (now.isBefore(times.dhuhr)) return 'dhuhr';
    if (now.isBefore(times.asr)) return 'asr';
    if (now.isBefore(times.maghrib)) return 'maghrib';
    if (now.isBefore(times.isha)) return 'isha';

    return null; // All prayers have passed
  }
}
