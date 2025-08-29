import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/core/share/widgets/decorated_verse_number.dart';
import 'package:jalees/core/theme/app_fonts.dart';

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
                ),
                children: [
                  TextSpan(text: verse.text),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SizedBox(
                      width: 4,
                      child: UnicodeDecoratedVerseNumber(
                        verseNumber: verse.id,
                        fontSize: 20,
                      ),
                    ),
                  ),
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
