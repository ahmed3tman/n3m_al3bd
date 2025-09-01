import 'package:flutter/material.dart';
import '../../utils/quran_verse_numbers.dart';
import '../../theme/app_fonts.dart';

// class DecoratedVerseNumber extends StatelessWidget {
//   final int verseNumber;
//   final double? fontSize;
//   final Color? color;
//   final Color? backgroundColor;
//   final Color? borderColor;
//   final double? borderWidth;

//   const DecoratedVerseNumber({
//     super.key,
//     required this.verseNumber,
//     this.fontSize = 20,
//     this.color,
//     this.backgroundColor,
//     this.borderColor,
//     this.borderWidth = 2.5,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 2),
//       width: 48,
//       height: 48,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: backgroundColor ?? const Color(0xFFFFF8DC), // ذهبي فاتح
//         border: Border.all(
//           color: borderColor ?? Theme.of(context).colorScheme.secondary,
//           width: borderWidth!,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Directionality(
//           textDirection: TextDirection.rtl,
//           child: FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               QuranVerseNumbers.convertToArabicNumerals(verseNumber.toString()),
//               textAlign: TextAlign.center,
//               style: AppFonts.verseNumberStyle(
//                 fontSize: fontSize! + 6,
//                 color: color ?? Theme.of(context).colorScheme.onBackground,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Widget بديل للأرقام المزخرفة بدون دائرة
class UnicodeDecoratedVerseNumber extends StatelessWidget {
  final int verseNumber;
  final double? fontSize;
  final Color? color;

  const UnicodeDecoratedVerseNumber({
    super.key,
    required this.verseNumber,
    this.fontSize = 34,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          QuranVerseNumbers.getDecorativeVerseNumber(verseNumber),
          textAlign: TextAlign.center,
          style:
              AppFonts.verseNumberStyle(
                fontSize: fontSize!,
                color: color ?? AppFonts.brightGold,
              ).copyWith(
                // Prefer the 'Verses' font if registered in pubspec; otherwise fallback remains
                fontFamily: AppFonts.versesFont,
              ),
        ),
      ),
    );
  }
}
