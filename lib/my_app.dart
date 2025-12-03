import 'package:flutter/material.dart';
import 'package:n3m_al3bd/core/theme/app_theme.dart';
import 'package:n3m_al3bd/core/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/features/nav/view/screens/nav_screen.dart';
import 'package:n3m_al3bd/features/quran/view/screens/quran_screen.dart';

class MyApp extends StatelessWidget {
  final ThemeMode? initialTheme;

  const MyApp({super.key, this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(initialTheme: initialTheme),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            routes: {
              'nav': (context) => const Nav(),
              'quran': (context) => const QuranScreen(),
            },
            title: 'نعم العبد',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const Nav(),
          );
        },
      ),
    );
  }
}
