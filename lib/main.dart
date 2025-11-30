import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n3m_al3bd/my_app.dart';
import 'package:n3m_al3bd/features/quran/data/page_mapping_repository.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Preload Quran mapping data
  try {
    await PageMappingRepository.ensureLoaded();
  } catch (_) {
    // ignore non-fatal preload errors; app can still start
  }

  runApp(const MyApp());
}
