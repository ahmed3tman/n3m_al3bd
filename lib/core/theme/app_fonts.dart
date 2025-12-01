import 'package:flutter/material.dart';

class AppFonts {
  // أسماء الخطوط
  static const String uthmanicHafs = 'UthmanicHafs';
  static const String suraNameFont = 'SuraNameFont';
  static const String generalFont = 'GeneralFont';
  static const String basmalahFont = 'BasmalahFont';
  // Custom font for verse numbers (to be added by the user in pubspec/fonts)
  static const String versesFont = 'Verses';

  // أحجام الخطوط المختلفة للتصميم الإسلامي
  static const double verseTextSize = 25.0;
  static const double hadithTextSize = 18.0;
  static const double azkarTextSize = 18.0;
  static const double titleSize = 24.0;
  static const double subtitleSize = 16.0;
  static const double captionSize = 14.0;

  // ألوان النصوص بتدرجات شروق/غروب
  static const Color primaryTextColor = Color(0xFF073A47); // داكن أساسي
  static const Color secondaryTextColor = Color(0xFF2A6668); // أزرق مخضر
  static const Color goldTextColor = Color.fromARGB(
    255,
    13,
    6,
    3,
  ); // برتقالي دافئ (غامق)
  // ذهبى واضح ومشرق لأرقام الآيات
  static const Color brightGold = Color.fromARGB(255, 193, 67, 0);
  static const Color mutedTextColor = Color.fromARGB(
    255,
    234,
    207,
    172,
  ); // محايد بني

  // أساليب النصوص الجاهزة

  /// نمط نص القرآن الكريم
  static TextStyle quranTextStyle({
    double fontSize = verseTextSize,
    Color? color,
    double height = 2.0,
    double letterSpacing = 0.5,
  }) {
    return TextStyle(
      fontFamily: uthmanicHafs,
      fontSize: fontSize,
      color: color ?? primaryTextColor,
      height: height,
      letterSpacing: letterSpacing,
      // wordSpacing: 0.1,
      fontWeight: FontWeight.w400,
    );
  }

  /// نمط نص الحديث الشريف
  static TextStyle hadithTextStyle({
    double fontSize = hadithTextSize,
    Color? color,
    double height = 1.8,
  }) {
    return TextStyle(
      fontFamily: uthmanicHafs,
      fontSize: fontSize,
      color: color ?? primaryTextColor,
      height: height,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    );
  }

  /// نمط نص الأذكار
  static TextStyle azkarTextStyle({
    double fontSize = azkarTextSize,
    Color? color,
    double height = 1.8,
  }) {
    return TextStyle(
      fontFamily: uthmanicHafs,
      fontSize: fontSize,
      color: color ?? primaryTextColor,
      height: height,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    );
  }

  /// عناوين السور والأقسام
  static TextStyle suraNameStyle({
    double fontSize = titleSize,
    Color? color,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontFamily: suraNameFont,
      fontSize: fontSize,
      color: color ?? const Color.fromARGB(255, 5, 90, 95),
      fontWeight: fontWeight,
      letterSpacing: 0.5,
    );
  }

  /// نمط النصوص العامة
  static TextStyle generalTextStyle({
    double fontSize = subtitleSize,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontFamily: generalFont,
      fontSize: fontSize,
      color: color ?? primaryTextColor,
      fontWeight: fontWeight,
      height: 1.5,
    );
  }

  /// نمط النصوص التوضيحية
  static TextStyle captionStyle({
    double fontSize = captionSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: generalFont,
      fontSize: fontSize,
      color: color ?? mutedTextColor,
      fontWeight: fontWeight,
      height: 1.4,
    );
  }

  /// نمط البسملة المزخرفة
  static TextStyle basmalahStyle({double fontSize = 24.0, Color? color}) {
    return TextStyle(
      fontFamily: basmalahFont,
      fontSize: fontSize,
      color: color ?? secondaryTextColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      height: 1.5,
    );
  }

  /// نمط أرقام الآيات
  static TextStyle verseNumberStyle({double fontSize = 16.0, Color? color}) {
    return TextStyle(
      // Default to UthmanicHafs; widgets can override with versesFont when available
      fontFamily: uthmanicHafs,
      fontSize: fontSize,
      // Verse numbers should use the bright/gold color by default
      color: color ?? brightGold,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    );
  }

  /// نمط أزرار الإجراءات
  static TextStyle buttonTextStyle({
    double fontSize = 16.0,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: generalFont,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  /// تطبيق الظلال الذهبية للنصوص المهمة
  static List<Shadow> goldShadows({
    Color shadowColor = goldTextColor,
    double blurRadius = 2.0,
    Offset offset = const Offset(0.8, 1.0),
  }) {
    return [Shadow(color: shadowColor, blurRadius: blurRadius, offset: offset)];
  }
}

/// مساعد لتطبيق اتجاه النص العربي
class ArabicTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ArabicTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.right,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
