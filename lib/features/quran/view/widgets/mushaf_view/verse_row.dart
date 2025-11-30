import 'package:flutter/material.dart';
import 'package:n3m_al3bd/features/quran/model/quran_model.dart';
import 'package:n3m_al3bd/core/utils/quran_verse_numbers.dart';
import 'package:n3m_al3bd/core/theme/app_fonts.dart';

/// Single verse row using RichText and the decorated verse number.
class VerseRow extends StatelessWidget {
  final QuranVerse verse;

  const VerseRow({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (verse.id == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                verse.text,
                textAlign: TextAlign.center,
                style: AppFonts.basmalahStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              textAlign: TextAlign.justify,
              textWidthBasis: TextWidthBasis.parent,
              text: TextSpan(
                style: AppFonts.quranTextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ).copyWith(wordSpacing: -0.3, letterSpacing: -0.3),
                children: [
                  TextSpan(text: verse.text),
                  // Add the verse number with symmetric thin spaces to balance spacing.
                  TextSpan(
                    text:
                        '\u2009\u061C${QuranVerseNumbers.getDecorativeVerseNumber(verse.id)}\u061C\u2009',
                    style:
                        AppFonts.verseNumberStyle(
                          fontSize: 20,
                          color: AppFonts.brightGold,
                        ).copyWith(
                          fontFamily: AppFonts.versesFont,
                          height: 1.0,
                          // shadows: AppFonts.goldShadows(),
                        ),
                  ),
                  // No extra trailing space; spacing is symmetric now.
                ],
              ),
            ),
          ),
        // minimal gap to avoid large empty lines
        const SizedBox(height: 2),
      ],
    );
  }
}
