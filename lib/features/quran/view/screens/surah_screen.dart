import 'package:flutter/material.dart';
import 'package:n3m_al3bd/core/utils/quran_verse_numbers.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../model/quran_model.dart';
import 'package:n3m_al3bd/features/quran/view/widgets/surah_list/widgets.dart';

class AyatScreen extends StatelessWidget {
  final QuranSurah surah;
  const AyatScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header row same as MushafScreen (without bookmark icon)
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 4,
                right: 4,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Icon(
                              // Same flipped logic as MushafScreen
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      surah.name,
                      style: AppFonts.suraNameStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Placeholder to keep the title centered (was bookmark on MushafScreen)
                  const SizedBox(width: 48, height: 36),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                child: Column(
                  children: [
                    // نص السورة
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // بسملة مزخرفة
                            if (surah.id != 1 &&
                                surah.id != 9) // ليس الفاتحة أو التوبة
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '﷽',
                                  textAlign: TextAlign.center,
                                  style: AppFonts.basmalahStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  style: AppFonts.quranTextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onBackground,
                                  ),
                                  children: [
                                    for (final verse in surah.verses) ...[
                                      TextSpan(text: verse.text),
                                      TextSpan(
                                        text:
                                            '\u2009\u061C${QuranVerseNumbers.getDecorativeVerseNumber(verse.id)}\u061C\u2009',
                                        style:
                                            AppFonts.verseNumberStyle(
                                              fontSize: 30,
                                              color: AppFonts.brightGold,
                                            ).copyWith(
                                              fontFamily: AppFonts.versesFont,
                                              height: 1.0,
                                            ),
                                      ),
                                      // No extra trailing space; spacing is symmetric
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // معلومات السورة في الأسفل
                    SurahInfoPanel(
                      versesCount: surah.totalVerses.toString(),
                      type: surah.type == "meccan" ? "مكية" : "مدنية",
                      surahNumber: surah.id.toString(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
