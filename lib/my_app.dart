import 'package:flutter/material.dart';
import 'package:jalees/core/theme/app_theme.dart';
import 'package:jalees/features/nav/view/screens/nav_screen.dart';
import 'package:jalees/features/quran/view/screens/quran_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'nav': (context) => const Nav(),
        'quran': (context) => const QuranScreen(),
      },
      title: 'نعم العبد',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const Nav(),
    );
  }
}
