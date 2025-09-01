import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
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
        final horizontalPadding = 4.0; // matches container padding below
        final availableWidth =
            MediaQuery.of(context).size.width - horizontalPadding * 2;

        // Build plain text used for measurement for verses only (exclude header lines)
        // Skip top basmalah in measurement for Surah Al-Fatiha (1) and At-Tawbah (9)
        // to keep measurement consistent with rendering.
        final headerStartSurahIdForMeasure =
            (pageStartSurahIds != null && pageIndex < pageStartSurahIds!.length)
            ? pageStartSurahIds![pageIndex]
            : null;
        final bool isBasmalahAllowedForSurahForMeasure =
            headerStartSurahIdForMeasure != null &&
            headerStartSurahIdForMeasure != 1 &&
            headerStartSurahIdForMeasure != 9;

        String buildVersesMeasurementText(double fontSize) {
          final sb = StringBuffer();
          // Use hair space (U+200A) as a very small symmetric space around numbers
          const String hairSpace = '\u200A';
          for (int i = 0; i < page.length; i++) {
            final verse = page[i];
            if (verse.id == 0) {
              if (i == 0 && !isBasmalahAllowedForSurahForMeasure) {
                // skip measuring basmalah at top for surahs without header basmalah
                continue;
              }
              // basmalah as its own line in verses area
              sb.writeln(verse.text);
            } else {
              sb.write(verse.text);
              sb.write(hairSpace);
              sb.write(
                QuranVerseNumbers.convertToArabicNumerals(verse.id.toString()),
              );
              sb.write(hairSpace);
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

        // Decide if this page is Surah Al-Fatiha (1) or the FIRST page of Al-Baqarah (2)
        // We can check using pageStartSurahIds which is only non-null on the first page of a surah.
        final headerStartSurahIdForSizing =
            (pageStartSurahIds != null && pageIndex < pageStartSurahIds!.length)
            ? pageStartSurahIds![pageIndex]
            : null;
        final bool isFatihaFirstPage = headerStartSurahIdForSizing == 1;
        final bool isBaqarahFirstPage = headerStartSurahIdForSizing == 2;
        final bool useSlightlySmallerFont =
            isFatihaFirstPage || isBaqarahFirstPage;

        // Start with base font size and try to fit verses into the available lines after header
        double computedFontSize = useSlightlySmallerFont ? 22.0 : 26.0;
        const double minFontSize = 14.0;
        const double maxFontSizeGlobal = 42.0;

        // Start with a tighter word spacing and allow slight negative spacing
        // to reduce gaps between Arabic words. Step down in smaller increments
        // for finer control when fitting lines.
        double computedWordSpacing = -0.2;
        double computedLetterSpacing = -0.2;
        const double minWordSpacing = -1.2;
        const double maxWordSpacing = 6.0;
        const double maxLetterSpacing = 1.5;

        final baseStyleTemplate = AppFonts.quranTextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: computedFontSize,
          height:
              1.9, // match actual verse line height to keep totals consistent
          letterSpacing: computedLetterSpacing,
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
        // Basmalah should be shown for all surahs except Al-Fatiha (1) and At-Tawbah (9)
        final bool isBasmalahAllowedForSurah =
            headerStartSurahId != null &&
            headerStartSurahId != 1 &&
            headerStartSurahId != 9;

        final headerLines = (headerStartSurahId != null)
            ? ((pageHasBasmalahAtTop || !isBasmalahAllowedForSurah) ? 1 : 2)
            : 0;
        final availableLinesForVerses = 15 - headerLines;

        // Measure verses only and fit them into availableLinesForVerses.
        String measureText = buildVersesMeasurementText(computedFontSize);
        int lines = measureLineCount(measureText, baseStyle);

        // First, try reducing spacing and font size if we have too many lines
        while (lines > availableLinesForVerses &&
            (computedWordSpacing > minWordSpacing ||
                computedFontSize > minFontSize)) {
          if (computedWordSpacing > minWordSpacing) {
            // reduce in smaller steps for smoother visual adjustments
            computedWordSpacing = (computedWordSpacing - 0.03).clamp(
              minWordSpacing,
              100.0,
            );
          } else if (computedFontSize > minFontSize) {
            computedFontSize = (computedFontSize - 0.3).clamp(
              minFontSize,
              100.0,
            );
          }
          baseStyle = baseStyleTemplate.copyWith(
            fontSize: computedFontSize,
            wordSpacing: computedWordSpacing,
            letterSpacing: computedLetterSpacing,
          );
          measureText = buildVersesMeasurementText(computedFontSize);
          lines = measureLineCount(measureText, baseStyle);
        }
        int iterations = 0;
        const maxIterations = 100; // Prevent infinite loops

        while (lines < availableLinesForVerses && iterations < maxIterations) {
          bool changed = false;
          iterations++;

          // 1. First try increasing font size (but be careful with special pages)
          if (computedFontSize < maxFontSizeGlobal) {
            double increment = useSlightlySmallerFont ? 0.05 : 0.1;
            final prevFont = computedFontSize;
            computedFontSize = (computedFontSize + increment).clamp(
              0.0,
              maxFontSizeGlobal,
            );

            baseStyle = baseStyle.copyWith(fontSize: computedFontSize);
            measureText = buildVersesMeasurementText(computedFontSize);
            final nextLines = measureLineCount(measureText, baseStyle);

            if (nextLines > availableLinesForVerses) {
              computedFontSize = prevFont;
              baseStyle = baseStyle.copyWith(fontSize: computedFontSize);
            } else if (nextLines > lines) {
              lines = nextLines;
              changed = true;
              if (lines >= availableLinesForVerses) break;
            }
          }

          // 2. Try increasing word spacing
          if (computedWordSpacing < maxWordSpacing) {
            final prevWs = computedWordSpacing;
            computedWordSpacing = (computedWordSpacing + 0.03).clamp(
              minWordSpacing,
              maxWordSpacing,
            );

            baseStyle = baseStyle.copyWith(wordSpacing: computedWordSpacing);
            measureText = buildVersesMeasurementText(computedFontSize);
            final nextLines = measureLineCount(measureText, baseStyle);

            if (nextLines > availableLinesForVerses) {
              computedWordSpacing = prevWs;
              baseStyle = baseStyle.copyWith(wordSpacing: computedWordSpacing);
            } else if (nextLines > lines) {
              lines = nextLines;
              changed = true;
              if (lines >= availableLinesForVerses) break;
            }
          }

          // 3. Try increasing letter spacing
          if (computedLetterSpacing < maxLetterSpacing) {
            final prevLs = computedLetterSpacing;
            computedLetterSpacing = (computedLetterSpacing + 0.015).clamp(
              -0.5,
              maxLetterSpacing,
            );

            baseStyle = baseStyle.copyWith(
              letterSpacing: computedLetterSpacing,
            );
            measureText = buildVersesMeasurementText(computedFontSize);
            final nextLines = measureLineCount(measureText, baseStyle);

            if (nextLines > availableLinesForVerses) {
              computedLetterSpacing = prevLs;
              baseStyle = baseStyle.copyWith(
                letterSpacing: computedLetterSpacing,
              );
            } else if (nextLines > lines) {
              lines = nextLines;
              changed = true;
              if (lines >= availableLinesForVerses) break;
            }
          }

          // If no changes were made, break to avoid infinite loop
          if (!changed) {
            break;
          }
        } // Now build header section and body widgets separately.
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
                    vertical: 0, // further reduced vertical padding
                    horizontal: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 0), // remove extra gap
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
                            // Slightly larger surah name in header for better readability
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
                if (!pageHasBasmalahAtTop && isBasmalahAllowedForSurah)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: AppFonts.basmalahStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ).copyWith(fontSize: computedFontSize - 2, height: 1.5),
                      ),
                    ),
                  ),
              ],
            );
          }
        }

        // build verse spans
        for (int i = 0; i < page.length; i++) {
          final verse = page[i];
          if (verse.id == 0) {
            // If the page starts with Surah 1 or 9, skip showing basmalah at the top
            if (i == 0 &&
                headerStartSurahId != null &&
                (headerStartSurahId == 1 || headerStartSurahId == 9)) {
              continue;
            }
            // basmalah inside body: allocate a taller slot so it has comfortable
            // vertical spacing without changing the 15-line counting logic.
            bodyWidgets.add(
              Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  height:
                      computedFontSize * 1.5, // allow a bit of inner padding
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        verse.text,
                        textAlign: TextAlign.center,
                        style: AppFonts.basmalahStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ).copyWith(fontSize: computedFontSize - 2),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            // Add verse text then the number as a TextSpan instead of WidgetSpan.
            // Wrapping the number with Arabic Letter Mark (U+061C) on both sides
            // forces correct RTL behavior when multiple numbers share one line.
            verseSpans.add(TextSpan(text: verse.text));
            // Wrap number with hair spaces (U+200A) on both sides for balanced spacing
            final String rtlNumberCore =
                '\u061C${QuranVerseNumbers.getDecorativeVerseNumber(verse.id)}\u061C';
            final String rtlNumber = '\u200A' + rtlNumberCore + '\u200A';
            verseSpans.add(
              TextSpan(
                text: rtlNumber,
                style: AppFonts.verseNumberStyle(
                  fontSize: computedFontSize + 6,
                  color: AppFonts.brightGold,
                ).copyWith(fontFamily: AppFonts.versesFont, height: 1.0),
              ),
            );
            // No extra trailing space; spacing is symmetric now.
          }
        }

        // add the combined RichText for verses if any
        if (verseSpans.isNotEmpty) {
          // Use center alignment for Surah Al-Fatiha and first page of Al-Baqarah
          final bool shouldCenterText = isFatihaFirstPage || isBaqarahFirstPage;

          bodyWidgets.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: shouldCenterText
                    ? TextAlign.center
                    : TextAlign.justify,
                textWidthBasis: TextWidthBasis.parent,
                text: TextSpan(
                  // We'll override "height" below based on available page height
                  // to make the body occupy exactly the remaining space.
                  style: baseStyle,
                  children: List<InlineSpan>.from(verseSpans),
                ),
              ),
            ),
          );
        }

        // We'll add a pixel-precise spacer later based on the exact remaining height.

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
        // Account for surah name rendered at (computedFontSize + 4) and add a small safety buffer
        final double surahHeaderFontSize = computedFontSize + 4;
        final double surahLineHeightPx = surahHeaderFontSize * 1.25 + 2.0;
        final double basmalahHeaderLineHeightPx =
            computedFontSize * 1.6 + 4.0; // account for small vertical padding
        const double headerBufferPx =
            6.0; // safety buffer to avoid 1-2px overflow
        final double headerHeightPx = (headerStartSurahId != null)
            ? ((pageHasBasmalahAtTop || !isBasmalahAllowedForSurah)
                  ? (surahLineHeightPx + headerBufferPx)
                  : (surahLineHeightPx +
                        basmalahHeaderLineHeightPx +
                        headerBufferPx))
            : 0.0;
        final double bodyHeightPx = availableLinesForVerses * bodyLineHeightPx;

        // We'll compute the exact body area height and set a dynamic line-height
        // so the verses occupy the full area without leaving empty space.

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

        // Build the body with a LayoutBuilder to know the exact remaining height
        // and then set the TextStyle.height accordingly to fill it.
        final Widget bodyWidget = LayoutBuilder(
          builder: (context, constraints) {
            final double availableBodyHeightPx = constraints.maxHeight;
            final int desiredLines = availableLinesForVerses;
            // Dynamic line-height so N lines exactly fill the available body height
            final double dynamicLineHeight =
                (desiredLines > 0 && computedFontSize > 0)
                ? availableBodyHeightPx / (desiredLines * computedFontSize)
                : 1.9;

            // Update styles of the rich text(s) to use the dynamic line height
            final List<Widget> adjusted = [];
            for (final w in bodyWidgets) {
              if (w is Directionality && w.child is RichText) {
                final rich = (w.child as RichText);
                final ts = rich.text as TextSpan;
                final updated = TextSpan(
                  style: ts.style?.copyWith(height: dynamicLineHeight),
                  children: ts.children,
                  text: ts.text,
                );

                // Use center alignment for Surah Al-Fatiha and first page of Al-Baqarah
                final bool shouldCenterText =
                    isFatihaFirstPage || isBaqarahFirstPage;

                adjusted.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: RichText(
                      textAlign: shouldCenterText
                          ? TextAlign.center
                          : TextAlign.justify,
                      textWidthBasis: TextWidthBasis.parent,
                      text: updated,
                    ),
                  ),
                );
              } else if (w is Directionality && w.child is SizedBox) {
                // Basmalah inside the body: make it occupy exactly one line height
                final sb = w.child as SizedBox;
                adjusted.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: computedFontSize * dynamicLineHeight,
                      child: (sb.child is Center)
                          ? Center(child: (sb.child as Center).child)
                          : sb.child,
                    ),
                  ),
                );
              } else {
                adjusted.add(w);
              }
            }

            // No bottom spacer: the text itself has been expanded to occupy all 15 lines.

            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: adjusted,
                ),
              ),
            );
          },
        );

        return SafeArea(
          bottom: false,
          top: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: availablePageHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
