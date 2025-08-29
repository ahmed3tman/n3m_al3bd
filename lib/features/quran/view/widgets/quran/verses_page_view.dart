import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/core/share/widgets/decorated_verse_number.dart';
import 'package:jalees/core/utils/quran_verse_numbers.dart';
import 'package:jalees/core/theme/app_fonts.dart';

/// Page view that shows pages of verses. Expects pages as a list of verse lists.
class VersesPageView extends StatelessWidget {
  final List<List<QuranVerse>> pages;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double? pageHeight;
  final List<int?>? pageStartSurahIds;
  final List<QuranSurah>? allSurahs;

  const VersesPageView({
    super.key,
    required this.pages,
    required this.controller,
    required this.onPageChanged,
    this.pageHeight,
    this.pageStartSurahIds,
    this.allSurahs,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, pageIndex) {
        // Build the page content while enforcing exactly 15 visual lines.
        // Strategy:
        // 1. Create a plain measurement string representing the page (including verse numbers as plain Arabic numerals).
        // 2. Use TextPainter to measure how many lines the content occupies with the desired style and available width.
        // 3. If it exceeds 15 lines, reduce font size iteratively until it fits (down to a reasonable min).
        // 4. If it uses fewer than 15 lines, append blank lines to reach 15.
        // 5. Finally render the RichText with WidgetSpans for decorative verse numbers using the computed font size.

        final page = pages[pageIndex];
        final horizontalPadding = 8.0; // matches container padding below
        final availableWidth =
            MediaQuery.of(context).size.width - horizontalPadding * 2;

        // Build plain text used for measurement for verses only (exclude header lines)
        String buildVersesMeasurementText(double fontSize) {
          final sb = StringBuffer();
          for (final verse in page) {
            if (verse.id == 0) {
              // basmalah as its own line in verses area
              sb.writeln(verse.text);
            } else {
              sb.write(verse.text);
              sb.write(' ');
              sb.write(
                QuranVerseNumbers.convertToArabicNumerals(verse.id.toString()),
              );
              sb.write(' ');
            }
          }
          return sb.toString();
        }

        int measureLineCount(String text, TextStyle style) {
          final tp = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            textWidthBasis: TextWidthBasis.parent,
            maxLines: 1000,
          );
          tp.layout(minWidth: 0, maxWidth: availableWidth);
          return tp.computeLineMetrics().length;
        }

        // Start with base font size and try to fit verses into the available lines after header
        double computedFontSize = 22.0;
        const double minFontSize = 14.0;
        // start with a tighter word spacing and allow slight negative spacing
        // to reduce gaps between Arabic words. Step down in smaller increments
        // for finer control when fitting lines.
        double computedWordSpacing = 0.0;
        const double minWordSpacing = -0.4;
        final baseStyleTemplate = AppFonts.quranTextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: computedFontSize,
          height: 2.2, // increased line spacing
          letterSpacing: -0.6,
        );
        TextStyle baseStyle = baseStyleTemplate.copyWith(
          wordSpacing: computedWordSpacing,
        );

        // Determine header lines count (surah name always 1 line when present, basmalah 1 line unless already present as first verse)
        final headerStartSurahId =
            (pageStartSurahIds != null && pageIndex < pageStartSurahIds!.length)
            ? pageStartSurahIds![pageIndex]
            : null;
        bool pageHasBasmalahAtTop = false;
        if (headerStartSurahId != null) {
          const basmalahText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
          pageHasBasmalahAtTop =
              page.isNotEmpty &&
              (page.first.id == 0 || page.first.text.trim() == basmalahText);
        }

        final headerLines = (headerStartSurahId != null)
            ? (pageHasBasmalahAtTop ? 1 : 2)
            : 0;
        final availableLinesForVerses = 15 - headerLines;

        // Measure verses only and fit them into availableLinesForVerses.
        String measureText = buildVersesMeasurementText(computedFontSize);
        int lines = measureLineCount(measureText, baseStyle);
        // Try reducing word spacing first, then font size, to make text fit available lines
        while (lines > availableLinesForVerses &&
            (computedWordSpacing > minWordSpacing ||
                computedFontSize > minFontSize)) {
          if (computedWordSpacing > minWordSpacing) {
            // reduce in smaller steps for smoother visual adjustments
            computedWordSpacing = (computedWordSpacing - 0.05).clamp(
              minWordSpacing,
              100.0,
            );
          } else if (computedFontSize > minFontSize) {
            computedFontSize -= 0.5;
          }
          baseStyle = baseStyleTemplate.copyWith(
            fontSize: computedFontSize,
            wordSpacing: computedWordSpacing,
          );
          measureText = buildVersesMeasurementText(computedFontSize);
          lines = measureLineCount(measureText, baseStyle);
        }

        final neededBlankLines = (lines < availableLinesForVerses)
            ? (availableLinesForVerses - lines)
            : 0;

        // Now build header section and body widgets separately.
        // We'll compute exact pixel heights so header + body == 15 lines.
        final List<Widget> bodyWidgets = [];
        final List<InlineSpan> verseSpans = [];

        Widget? headerSection;
        if (headerStartSurahId != null && allSurahs != null) {
          final surah = allSurahs!.firstWhere(
            (s) => s.id == headerStartSurahId,
            orElse: () => QuranSurah(
              id: -1,
              name: '',
              transliteration: '',
              type: '',
              totalVerses: 0,
              verses: [],
            ),
          );
          if (surah.id != -1) {
            // Decorative framed header (compact vertical padding to keep heights predictable)
            headerSection = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 2, // reduced vertical padding
                    horizontal: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 2), // reduced margin
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.10),
                        Theme.of(context).colorScheme.primary.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.9),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '۞',
                        style: AppFonts.quranTextStyle(
                          fontSize: computedFontSize,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          surah.name,
                          textAlign: TextAlign.center,
                          style: AppFonts.quranTextStyle(
                            fontSize: computedFontSize + 4,
                            height: 1.0,
                          ).copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '۞',
                        style: AppFonts.quranTextStyle(
                          fontSize: computedFontSize,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!pageHasBasmalahAtTop)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: AppFonts.basmalahStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ).copyWith(fontSize: computedFontSize, height: 0.95),
                    ),
                  ),
              ],
            );
          }
        }

        // build verse spans
        for (final verse in page) {
          if (verse.id == 0) {
            // basmalah inside body: allocate a taller slot so it has comfortable
            // vertical spacing without changing the 15-line counting logic.
            bodyWidgets.add(
              Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  height:
                      computedFontSize * 1.6, // slightly reduced vertical slot
                  child: Center(
                    child: Text(
                      verse.text,
                      textAlign: TextAlign.center,
                      style: AppFonts.basmalahStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ).copyWith(fontSize: computedFontSize),
                    ),
                  ),
                ),
              ),
            );
          } else {
            verseSpans.add(TextSpan(text: verse.text));
            verseSpans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  // slightly smaller gap before the decorative verse number
                  padding: const EdgeInsetsDirectional.only(start: 1),
                  child: UnicodeDecoratedVerseNumber(
                    verseNumber: verse.id,
                    fontSize: computedFontSize + 6,
                  ),
                ),
              ),
            );
          }
        }

        // add the combined RichText for verses if any
        if (verseSpans.isNotEmpty) {
          bodyWidgets.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: TextAlign.justify,
                textWidthBasis: TextWidthBasis.parent,
                text: TextSpan(
                  style: AppFonts.quranTextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: computedFontSize,
                    height: 1.9,
                  ).copyWith(wordSpacing: computedWordSpacing),
                  children: List<InlineSpan>.from(verseSpans),
                ),
              ),
            ),
          );
        }

        // append blank lines to body if needed
        if (neededBlankLines > 0) {
          final blanks = List.filled(neededBlankLines, '').join('\n');
          bodyWidgets.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                blanks,
                style: AppFonts.quranTextStyle(
                  fontSize: computedFontSize,
                  height: 2.2,
                ).copyWith(wordSpacing: computedWordSpacing),
              ),
            ),
          );
        }

        // if still overflowing beyond availableLinesForVerses at min font size, scale body vertically
        double verticalScale = 1.0;
        if (lines > availableLinesForVerses &&
            computedFontSize <= minFontSize) {
          verticalScale = availableLinesForVerses / lines;
        }

        final bodyColumn = Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: false,
            physics: const NeverScrollableScrollPhysics(),
            children: bodyWidgets,
          ),
        );

        // Compute precise pixel heights: use computedFontSize and line-height multipliers
        final double bodyLineHeightPx = computedFontSize * 1.9;
        // surah line uses normal line height; basmalah gets extra vertical space
        final double surahLineHeightPx = computedFontSize * 1.0;
        final double basmalahHeaderLineHeightPx = computedFontSize * 2.0;
        final double headerHeightPx = (headerStartSurahId != null)
            ? (pageHasBasmalahAtTop
                  ? surahLineHeightPx
                  : (surahLineHeightPx + basmalahHeaderLineHeightPx))
            : 0.0;
        final double bodyHeightPx = availableLinesForVerses * bodyLineHeightPx;

        // sizedBody no longer forces a fixed height; Expanded will provide
        // the available height and ensure the content cannot overflow.
        final Widget sizedBody = ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: (verticalScale < 1.0)
                ? Transform(
                    transform: Matrix4.diagonal3Values(1.0, verticalScale, 1.0),
                    alignment: Alignment.topCenter,
                    child: bodyColumn,
                  )
                : bodyColumn,
          ),
        );

        // Compute available page height (respecting safe areas) and scale the
        // combined header+body vertically if it would overflow the visible area.
        final double mediaTop = MediaQuery.of(context).padding.top;
        // Since we're using SafeArea with bottom: false, we don't subtract bottom padding
        final double availablePageHeight =
            (pageHeight ?? (MediaQuery.of(context).size.height - mediaTop));

        // Build a constrained page layout: fixed header height and an
        // Expanded body that fills remaining availablePageHeight. This
        // prevents vertical overflow by ensuring children cannot exceed
        // the page container's height.
        final Widget headerWidget = (headerSection != null)
            ? SizedBox(
                height: headerHeightPx,
                child: ClipRect(child: Center(child: headerSection)),
              )
            : const SizedBox.shrink();

        final Widget bodyWidget = SizedBox(
          width: double.infinity,
          // The body will be placed inside Expanded below so it never
          // exceeds the remaining space.
          child: sizedBody,
        );

        return SafeArea(
          bottom: false,
          top: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: SizedBox(
                height: availablePageHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (headerSection != null) headerWidget,
                      // Expanded ensures the body will fit the remaining
                      // vertical space and cannot overflow the page.
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: bodyWidget,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
