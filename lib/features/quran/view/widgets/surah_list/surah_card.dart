import 'package:flutter/material.dart';
import 'package:n3m_al3bd/features/quran/model/quran_model.dart';
import 'package:n3m_al3bd/features/quran/view/screens/surah_screen.dart';
import 'package:n3m_al3bd/core/theme/app_fonts.dart';

// helper: convert ASCII digits to Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩)
String _toArabicDigits(Object value) {
  final s = value.toString();
  const map = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return s.split('').map((c) => map[c] ?? c).join();
}

// NOTE: custom mapping/list removed — display surah name directly

class SurahCard extends StatelessWidget {
  const SurahCard({super.key, required this.sura});

  final QuranSurah sura;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AyatScreen(surah: sura)),
        );
      },
      child: Card(
        // reduce vertical margin to remove extra empty space under the card
        // reduce vertical margin to remove extra empty space under the card
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Remove elevation for flat glassy look
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.6,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            // reduce vertical padding to remove empty space under content
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 0,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                // make the leading circle clearly green as requested
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  // show Arabic-Indic digits (smaller)
                  _toArabicDigits(sura.id),
                  textAlign: TextAlign.center,
                  // use general (regular) font for numbering inside the circle (smaller)
                  style: AppFonts.generalTextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Title shows the surah name directly
            title: ArabicTextWidget(
              text: sura.name,
              style: AppFonts.suraNameStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            // Subtitle contains only the details row
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الآيات: ${sura.totalVerses.toString()} • ${sura.type == "meccan" ? "مكية" : "مدنية"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
