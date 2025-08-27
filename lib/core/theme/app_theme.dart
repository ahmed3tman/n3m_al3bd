import 'package:flutter/material.dart';

class AppTheme {
  // ألوان مستوحاة من تدرجات شروق/غروب الشمس
  static const Color _darkPrimary = Color(0xFF073A47); // لون داكن أساسي
  static const Color _tealSecondary = Color(0xFF2A6668); // أزرق مخضر ثانوي
  static const Color _neutralBrown = Color.fromRGBO(165, 142, 111, 1); // محايد بني
  static const Color _warmAccent = Color(0xFFF07D42); // برتقالي دافئ
  static const Color _lightBackground = Color(0xFFFDB774); // مشمشي فاتح
  static const Color _lighterBackground = Color(
    0xFFFEE4A6,
  ); // مشمشي أفتح للتدرج
  static const Color _paperWhite = Color(0xFFFFFEF7); // أبيض ورقي

  // تدرج الخلفية الجميل
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _lighterBackground, // أفتح في الأعلى
      _lightBackground, // أغمق قليلاً في الأسفل
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
      backgroundColor: _darkPrimary,
      elevation: 2,
      shadowColor: Color(0x1A000000),
      iconTheme: IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'GeneralFont', // خط واضح ومقروء للعناوين
        letterSpacing: 0.8,
        height: 1.2,
      ),
      centerTitle: true,
      toolbarHeight: 60,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xBF073A47), // اللون الداكن الأساسي مع شفافية 75%
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
      color: _paperWhite,
      elevation: 3,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
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

  // Widget للخلفية المتدرجة
  static Widget buildGradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: child,
    );
  }

  // Widget للخلفية المتدرجة مع Scaffold
  static Widget buildGradientScaffold({
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}
