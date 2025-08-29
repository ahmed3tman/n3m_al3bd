import 'package:flutter/material.dart';
import '../../../../core/share/widgets/decorated_verse_number.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../model/quran_model.dart';
import 'package:jalees/features/quran/view/widgets/surah/widgets.dart';

class AyatScreen extends StatelessWidget {
  final QuranSurah surah;
  const AyatScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          surah.name,
          style: AppFonts.suraNameStyle(
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        centerTitle: true,
      ),
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
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            textAlign: TextAlign.center,
                            style: AppFonts.basmalahStyle(
                              color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            children: [
                              for (final verse in surah.verses) ...[
                                TextSpan(text: verse.text),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: UnicodeDecoratedVerseNumber(
                                      verseNumber: verse.id,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' ',
                                ), // مسافة بعد رقم الآية
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
    );
  }
}
