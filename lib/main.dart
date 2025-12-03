import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n3m_al3bd/my_app.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Preload Theme
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme_mode');
  final themeMode = savedTheme != null
      ? _getThemeModeFromString(savedTheme)
      : ThemeMode.system;

  runApp(MyApp(initialTheme: themeMode));
}

ThemeMode _getThemeModeFromString(String themeString) {
  switch (themeString) {
    case 'ThemeMode.light':
      return ThemeMode.light;
    case 'ThemeMode.dark':
      return ThemeMode.dark;
    case 'ThemeMode.system':
    default:
      return ThemeMode.system;
  }
}
