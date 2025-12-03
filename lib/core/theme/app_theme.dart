import 'package:flutter/material.dart';

class AppTheme {
  // ألوان مستوحاة من تدرجات شروق/غروب الشمس
  static const Color _darkPrimary = Color(0xFF555B6E); // لون داكن أساسي
  static const Color _tealSecondary = Color(0xFF89B0AE); // أزرق مخضر ثانوي
  static const Color _neutralBrown = Color.fromRGBO(
    165,
    142,
    111,
    1,
  ); // محايد بني
  static const Color _warmAccent = Color(0xFFFFD6BA); // برتقالي دافئ
  static const Color _lightBackground = Color(0xFFBEE3DB); // مشمشي فاتح جداً

  static const Color _paperWhite = Color(0xFFFAF9F9); // أبيض ورقي

  // تدرج الخلفية الجميل
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _lightBackground, // لون موحد
      _lightBackground, // لون موحد
    ],
    stops: [0.0, 1.0],
  );

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _tealSecondary,
      secondary: _warmAccent,
      background: _lightBackground,
      surface: _paperWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: _darkPrimary,
      onSurface: _darkPrimary,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent, // شفاف ليظهر التدرج
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: _darkPrimary, size: 24),
      titleTextStyle: TextStyle(
        color: _darkPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'GeneralFont', // خط واضح ومقروء للعناوين
        letterSpacing: 0.8,
        height: 1.2,
      ),
      centerTitle: true,
      toolbarHeight: 60,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _tealSecondary.withOpacity(0.95),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xBFFFFFFF), // أبيض مع شفافية
      type: BottomNavigationBarType.fixed,
      elevation: 0, // إزالة الظل لمظهر أنيق مع الشفافية
      selectedLabelStyle: TextStyle(
        fontFamily: 'GeneralFont',
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: 'GeneralFont'),
    ),
    cardTheme: CardThemeData(
      color: _paperWhite.withOpacity(0.9), // شفافية طفيفة
      elevation: 0, // تقليل الظل للتأثير الزجاجي
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
    ),
    fontFamily: 'GeneralFont', // الخط الأساسي للتطبيق
    textTheme: const TextTheme(
      // نصوص القرآن والأحاديث
      bodyLarge: TextStyle(
        fontFamily: 'UthmanicHafs',
        color: _darkPrimary,
        fontSize: 20.0,
        height: 1.8,
        letterSpacing: 0.3,
      ),
      // النصوص العادية
      bodyMedium: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkPrimary,
        fontSize: 16.0,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: _neutralBrown,
        fontSize: 14.0,
        height: 1.4,
      ),
      // عناوين السور والأقسام الرئيسية
      titleLarge: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        letterSpacing: 0.3,
      ),
      titleSmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: _warmAccent,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      // النصوص التوضيحية
      labelLarge: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      ),
      labelMedium: TextStyle(
        fontFamily: 'GeneralFont',
        color: _neutralBrown,
        fontSize: 12.0,
      ),
      labelSmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: Color(0xFF9E9E9E),
        fontSize: 11.0,
      ),
      // عناوين كبيرة
      headlineLarge: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 28.0,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        letterSpacing: 0.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _paperWhite,
      hintStyle: const TextStyle(
        color: _neutralBrown,
        fontFamily: 'GeneralFont',
      ),
      labelStyle: const TextStyle(
        color: _tealSecondary,
        fontFamily: 'GeneralFont',
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _neutralBrown),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _neutralBrown),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _tealSecondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tealSecondary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _tealSecondary,
        textStyle: const TextStyle(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _tealSecondary,
        textStyle: const TextStyle(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: _tealSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Dark Theme Colors
  static const Color _darkBackground = Color(
    0xFF121212,
  ); // Slightly darker than surface
  static const Color _darkSurface = Color(0xFF2C2C2C);
  static const Color _darkTextPrimary = Color(0xFFE0E0E0);
  static const Color _darkTextSecondary = Color(0xFFB0B0B0);

  // Dark Background Gradient
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_darkBackground, _darkBackground],
    stops: [0.0, 1.0],
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _tealSecondary,
      secondary: _warmAccent,
      background: _darkBackground,
      surface: _darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: _darkTextPrimary,
      onSurface: _darkTextPrimary,
      error: Color(0xFFCF6679),
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: _darkTextPrimary, size: 24),
      titleTextStyle: TextStyle(
        color: _darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'GeneralFont',
        letterSpacing: 0.8,
        height: 1.2,
      ),
      centerTitle: true,
      toolbarHeight: 60,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xE61E1E1E), // Darker background with opacity
      selectedItemColor: _tealSecondary,
      unselectedItemColor: Color(0xB3FFFFFF),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'GeneralFont',
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(fontFamily: 'GeneralFont'),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface.withOpacity(0.9),
      elevation: 0,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
    ),
    fontFamily: 'GeneralFont',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'UthmanicHafs',
        color: _darkTextPrimary,
        fontSize: 20.0,
        height: 1.8,
        letterSpacing: 0.3,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkTextPrimary,
        fontSize: 16.0,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkTextSecondary,
        fontSize: 14.0,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        letterSpacing: 0.3,
      ),
      titleSmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: _warmAccent,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      labelLarge: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      ),
      labelMedium: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkTextSecondary,
        fontSize: 12.0,
      ),
      labelSmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: Color(0xFFB0B0B0),
        fontSize: 11.0,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 28.0,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'SuraNameFont',
        color: _tealSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        letterSpacing: 0.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'GeneralFont',
        color: _darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      hintStyle: const TextStyle(
        color: _darkTextSecondary,
        fontFamily: 'GeneralFont',
      ),
      labelStyle: const TextStyle(
        color: _tealSecondary,
        fontFamily: 'GeneralFont',
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkTextSecondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkTextSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _tealSecondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _tealSecondary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _tealSecondary,
        textStyle: const TextStyle(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _tealSecondary,
        textStyle: const TextStyle(
          fontFamily: 'GeneralFont',
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: _tealSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Widget للخلفية المتدرجة
  static Widget buildGradientBackground({required Widget child}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: isDark ? darkBackgroundGradient : backgroundGradient,
          ),
          child: child,
        );
      },
    );
  }

  // Widget للخلفية المتدرجة مع Scaffold
  static Widget buildGradientScaffold({
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? drawer,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: isDark ? darkBackgroundGradient : backgroundGradient,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            drawer: drawer,
          ),
        );
      },
    );
  }
}
