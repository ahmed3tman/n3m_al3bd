import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/core/utils/quran_verse_numbers.dart';
import 'package:jalees/core/theme/app_fonts.dart';

// Decoration types for mapping-based 15-line rendering
enum _LineDeco { none, header, basmalah, spacer }

/// Page view that shows pages of verses. Expects pages as a list of verse lists.
class VersesPageView extends StatefulWidget {
  final List<List<QuranVerse>> pages;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double? pageHeight;
  final List<int?>? pageStartSurahIds;
  final List<QuranSurah>? allSurahs;
  // Optional: per-page 15-line mapping (tokens) loaded from line_mapping.json
  // pageNumber (1-based) -> 15 lines -> list of tokens per line
  // token map keys: 'sura_no', 'aya_no', 'word_pos'
  final Map<int, List<List<Map<String, int>>>>? lineMappingByPageTokens;

  // Lightweight cache to avoid repeating expensive TextPainter measurements
  // for the same page with the same width and header configuration.

  const VersesPageView({
    super.key,
    required this.pages,
    required this.controller,
    required this.onPageChanged,
    this.pageHeight,
    this.pageStartSurahIds,
    this.allSurahs,
    this.lineMappingByPageTokens,
  });

  @override
  State<VersesPageView> createState() => _VersesPageViewState();
}

class _VersesPageViewState extends State<VersesPageView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.pages.length,
      onPageChanged: (i) {
        widget.onPageChanged(i);
      },
      physics: const PageScrollPhysics(),
      allowImplicitScrolling: true,
      // Preload adjacent pages to reduce perceived latency when swiping.
      // Note: cacheExtent is ignored by PageView; prefetching is achieved by build of neighbors via PageView.
      itemBuilder: (context, pageIndex) {
        // If line mapping is provided, render exactly 15 lines from the mapping
        // for the given 1-based page number. This acts as the authoritative
        // source for the Mushaf 15-line layout.
        final int pageNumber = pageIndex + 1;
        final List<List<Map<String, int>>>? mappedTokens =
            widget.lineMappingByPageTokens != null
            ? widget.lineMappingByPageTokens![pageNumber]
            : null;
        if (mappedTokens != null && mappedTokens.isNotEmpty) {
          final horizontalPadding = 4.0;
          final media = MediaQuery.of(context);
          final availableWidth = media.size.width - horizontalPadding * 2;
          final double mediaTop = media.padding.top;
          final double availablePageHeight =
              (widget.pageHeight ?? (media.size.height - mediaTop));

          // Determine if we should center align (Fatiha first page or first page of Baqarah)
          final int? initialSurahId =
              (widget.pageStartSurahIds != null &&
                  pageIndex < (widget.pageStartSurahIds!.length))
              ? widget.pageStartSurahIds![pageIndex]
              : null;
          final bool isFatihaFirstPage = initialSurahId == 1;
          final bool isBaqarahFirstPage = initialSurahId == 2;
          final bool shouldCenterText = isFatihaFirstPage || isBaqarahFirstPage;

          double fontSize = shouldCenterText ? 25.0 : 30.0;
          const double minFontSize = 12.0;
          const double maxFontSize = 46.0;
          double letterSpacing = -0.4;
          double wordSpacing = 0.0;

          // Precompute the last token position for each (sura,aya) across the page
          // so we can append the verse number exactly at the true end of the ayah
          // even if token word counts differ from quran.json splits.
          final Map<String, List<int>> lastAyahTokenPos = {};
          for (int li = 0; li < mappedTokens.length; li++) {
            final lineTokens = mappedTokens[li];
            for (int ti = 0; ti < lineTokens.length; ti++) {
              final t = lineTokens[ti];
              final suraNo = t['sura_no'];
              final ayaNo = t['aya_no'];
              final wordPos = t['word_pos'];
              if (suraNo == null || ayaNo == null || wordPos == null) continue;
              if (ayaNo == 0) continue; // Don't process basmalah for numbering

              // Pre-validate that this token is valid against quran.json
              final verseText = widget.allSurahs!
                  .firstWhere((s) => s.id == suraNo)
                  .verses[ayaNo - 1]
                  .text
                  .trim();
              final words = verseText.split(RegExp(r"\s+"));
              if (wordPos > 0 && wordPos <= words.length) {
                // Only valid tokens can be the last token.
                lastAyahTokenPos['$suraNo:$ayaNo'] = [li, ti];
              }
            }
          }

          bool isLastTokenOfAyah(
            int lineIndex,
            int tokenIndex,
            int suraNo,
            int ayaNo,
          ) {
            final pos = lastAyahTokenPos['$suraNo:$ayaNo'];
            if (pos == null) return false;
            return pos[0] == lineIndex && pos[1] == tokenIndex;
          }

          // Build InlineSpans for a line including decorative verse numbers
          List<InlineSpan> buildLineSpans(int i) {
            final tokens = (i >= 0 && i < mappedTokens.length)
                ? mappedTokens[i]
                : const <Map<String, int>>[];
            final List<InlineSpan> spans = [];
            for (int ti = 0; ti < tokens.length; ti++) {
              final t = tokens[ti];
              final suraNo = t['sura_no'];
              final ayaNo = t['aya_no'];
              final wordPos = t['word_pos'];
              if (suraNo == null || ayaNo == null || wordPos == null) continue;
              final verseText = widget.allSurahs!
                  .firstWhere((s) => s.id == suraNo)
                  .verses[ayaNo - 1]
                  .text
                  .trim();
              final words = verseText.split(RegExp(r"\s+"));
              if (wordPos <= 0 || wordPos > words.length) continue;
              final word = words[wordPos - 1];
              if (spans.isNotEmpty) spans.add(const TextSpan(text: ' '));
              spans.add(TextSpan(text: word));
              // Append verse number at the actual last token of the ayah on this page
              if (isLastTokenOfAyah(i, ti, suraNo, ayaNo)) {
                final String rtlNumberCore =
                    '\u061C${QuranVerseNumbers.getDecorativeVerseNumber(ayaNo)}\u061C';
                final String rtlNumber = '\u200A' + rtlNumberCore + '\u200A';
                spans.add(
                  TextSpan(
                    text: rtlNumber,
                    style: AppFonts.verseNumberStyle(
                      fontSize: fontSize + 6,
                      color: AppFonts.brightGold,
                    ).copyWith(fontFamily: AppFonts.versesFont, height: 1.0),
                  ),
                );
              }
            }
            return spans;
          }

          int lineCountFor(List<InlineSpan> spans, TextStyle style) {
            final tp = TextPainter(
              text: TextSpan(children: spans, style: style),
              textDirection: TextDirection.rtl,
              textAlign: shouldCenterText
                  ? TextAlign.center
                  : TextAlign.justify,
              textWidthBasis: TextWidthBasis.parent,
              maxLines: 3,
            );
            tp.layout(minWidth: 0, maxWidth: availableWidth);
            return tp.computeLineMetrics().length;
          }

          // Adjust font size down until all lines fit on a single line each.
          TextStyle baseStyle() => AppFonts.quranTextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: fontSize,
            height: 1.9,
            letterSpacing: letterSpacing,
          ).copyWith(wordSpacing: wordSpacing);

          int maxLinesUsed() {
            int maxUsed = 1;
            final style = baseStyle();
            for (int i = 0; i < 15; i++) {
              final used = lineCountFor(buildLineSpans(i), style);
              if (used > maxUsed) maxUsed = used;
              if (maxUsed > 1) break;
            }
            return maxUsed;
          }

          int guard = 0;
          while (maxLinesUsed() > 1 && fontSize > minFontSize && guard < 200) {
            guard++;
            if (fontSize > minFontSize) {
              fontSize = (fontSize - 0.5).clamp(minFontSize, maxFontSize);
            }
          }

          // Decide where to place surah header/basmalah: use empty lines just before
          // a new surah start (aya=1, word_pos=1) when available.
          final List<_LineDeco> decos = List<_LineDeco>.filled(
            15,
            _LineDeco.none,
          );
          final List<int?> decoSurahIds = List<int?>.filled(15, null);

          int? nextNonEmptyFrom(int idx) {
            for (int i = idx; i < mappedTokens.length; i++) {
              if (mappedTokens[i].isNotEmpty) return i;
            }
            return null;
          }

          int? surahIdAtLine(int k) {
            if (k < 0 || k >= mappedTokens.length) return null;
            if (mappedTokens[k].isEmpty) return null;
            return mappedTokens[k].first['sura_no'];
          }

          bool isSurahStartLine(int k) {
            if (k < 0 || k >= mappedTokens.length) return false;
            if (mappedTokens[k].isEmpty) return false;
            return mappedTokens[k].first['aya_no'] == 1 &&
                mappedTokens[k].first['word_pos'] == 1;
          }

          int li = 0;
          while (li < 15) {
            if (mappedTokens[li].isEmpty) {
              final k = nextNonEmptyFrom(li + 1);
              if (k != null && isSurahStartLine(k)) {
                final surahId = surahIdAtLine(k);
                final emptyCount = k - li;
                final bool basmalahAllowed =
                    surahId != null && surahId != 1 && surahId != 9;
                if (emptyCount >= 1) {
                  decos[li] = _LineDeco.header;
                  decoSurahIds[li] = surahId;
                }
                if (emptyCount >= 2 && basmalahAllowed) {
                  decos[li + 1] = _LineDeco.basmalah;
                  decoSurahIds[li + 1] = surahId;
                }
                // Any remaining empties stay spacers
                for (int j = li; j < k; j++) {
                  if (decos[j] == _LineDeco.none) decos[j] = _LineDeco.spacer;
                }
                li = k;
                continue;
              } else {
                decos[li] = _LineDeco.spacer;
              }
            }
            li++;
          }

          // Compute per-line spacing to stretch lines to the full width without wrapping.
          // - First, find the maximum safe wordSpacing per line.
          // - Then, add letterSpacing per line to consume any remaining slack.
          // Skip centered pages (Fatiha and first page of Baqarah) and non-text lines.
          final List<double> perLineWordSpacing = List<double>.filled(15, 0.0);
          final List<double> perLineLetterSpacing = List<double>.filled(
            15,
            letterSpacing,
          );
          if (!shouldCenterText) {
            double lineWidthFor(List<InlineSpan> spans, TextStyle style) {
              final tp = TextPainter(
                text: TextSpan(children: spans, style: style),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                textWidthBasis: TextWidthBasis.parent,
                maxLines: 1,
              );
              tp.layout(minWidth: 0, maxWidth: availableWidth);
              final metrics = tp.computeLineMetrics();
              return metrics.isEmpty ? 0.0 : metrics.first.width;
            }

            int spaceCountIn(List<InlineSpan> spans) {
              int count = 0;
              for (final sp in spans) {
                if (sp is TextSpan && sp.text != null) {
                  // Count regular ASCII spaces only; hair spaces used around numbers are ignored
                  count += '\u0020'.allMatches(sp.text!).length;
                }
              }
              return count;
            }

            for (int i = 0; i < 15; i++) {
              if (i >= mappedTokens.length) break;
              if (decos[i] != _LineDeco.none) {
                continue; // skip header/basmalah/spacer
              }
              final spans = buildLineSpans(i);
              if (spans.isEmpty) continue;
              final int gaps = spaceCountIn(spans);
              if (gaps <= 0) continue; // nothing to stretch

              final TextStyle base = AppFonts.quranTextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: fontSize,
                height: 1.9,
                letterSpacing: letterSpacing,
              );

              // Early exit: already close to full width
              final double w0 = lineWidthFor(spans, base);
              final double remaining0 = (availableWidth - w0);
              if (remaining0 <= 0.5) {
                perLineWordSpacing[i] = 0.0;
                continue;
              }

              // Binary search for the largest wordSpacing that still fits on one line
              double lo = 0.0;
              double hi = 18.0; // per-space cap to avoid ugly gaps
              double best = 0.0;
              const int maxIter = 14;
              for (int it = 0; it < maxIter; it++) {
                final mid = (lo + hi) / 2.0;
                final styleMid = base.copyWith(wordSpacing: mid);
                final lines = lineCountFor(spans, styleMid);
                if (lines > 1) {
                  // Too wide; reduce spacing
                  hi = mid;
                  continue;
                }
                final w = lineWidthFor(spans, styleMid);
                if (w <= availableWidth + 0.1) {
                  // Fits; try more spacing
                  best = mid;
                  lo = mid;
                } else {
                  // Overflow; reduce spacing
                  hi = mid;
                }
              }
              perLineWordSpacing[i] = best;

              // Add per-line letterSpacing to consume remaining slack if needed
              final TextStyle afterWord = base.copyWith(wordSpacing: best);
              final double wAfterWord = lineWidthFor(spans, afterWord);
              final double slack = availableWidth - wAfterWord;
              if (slack > 0.2) {
                double loLs = letterSpacing; // start from base
                double hiLs = letterSpacing + 2.0; // cap to keep aesthetics
                double bestLs = loLs;
                for (int it = 0; it < maxIter; it++) {
                  final midLs = (loLs + hiLs) / 2.0;
                  final styleMidLs = afterWord.copyWith(letterSpacing: midLs);
                  final lines = lineCountFor(spans, styleMidLs);
                  if (lines > 1) {
                    // Wrap occurred; reduce letter spacing
                    hiLs = midLs;
                    continue;
                  }
                  final w = lineWidthFor(spans, styleMidLs);
                  if (w <= availableWidth + 0.1) {
                    bestLs = midLs;
                    loLs = midLs;
                  } else {
                    hiLs = midLs;
                  }
                }
                perLineLetterSpacing[i] = bestLs;
              } else {
                perLineLetterSpacing[i] = letterSpacing;
              }
            }
          }

          Widget surahHeaderDecorated2(int surahId) {
            final s = widget.allSurahs?.firstWhere(
              (e) => e.id == surahId,
              orElse: () => QuranSurah(
                id: -1,
                name: '',
                transliteration: '',
                type: '',
                totalVerses: 0,
                verses: const [],
              ),
            );
            final display = (s == null || s.id == -1) ? '' : s.name;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 204, 165),
                      Color(0xFFeed8b3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF8a5a34), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '❁',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppFonts.brightGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(
                          display,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.suraNameStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8a5a34),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '❁',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppFonts.brightGold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // buildLineSpans is defined above for reuse in measuring and rendering

          final double dynamicLineHeightMap = (15 > 0 && fontSize > 0)
              ? (availablePageHeight / (15 * fontSize))
              : 1.9;
          final double safeLineHeightMap = dynamicLineHeightMap.clamp(1.2, 2.8);
          final double fixedLineHeightPx = fontSize * safeLineHeightMap;

          final Widget body = Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 15,
              itemBuilder: (context, i) {
                // Decorated header/basmalah/spacer lines
                switch (decos[i]) {
                  case _LineDeco.header:
                    final sid =
                        decoSurahIds[i] ??
                        surahIdAtLine(nextNonEmptyFrom(i + 1) ?? i) ??
                        0;
                    return SizedBox(
                      height: fixedLineHeightPx,
                      child: Center(child: surahHeaderDecorated2(sid)),
                    );
                  case _LineDeco.basmalah:
                    return SizedBox(
                      height: fixedLineHeightPx,
                      child: Center(
                        child: Text(
                          '﷽',
                          textAlign: TextAlign.center,
                          style: AppFonts.basmalahStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ).copyWith(fontSize: fontSize - 2),
                        ),
                      ),
                    );
                  case _LineDeco.spacer:
                    return SizedBox(height: fixedLineHeightPx);
                  case _LineDeco.none:
                    break;
                }

                // Regular text line with verse numbers
                final spans = buildLineSpans(i);
                return RichText(
                  textAlign: shouldCenterText
                      ? TextAlign.center
                      : TextAlign.justify,
                  textWidthBasis: TextWidthBasis.parent,
                  text: TextSpan(
                    style: AppFonts.quranTextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: fontSize,
                      height: safeLineHeightMap,
                      letterSpacing: perLineLetterSpacing[i],
                    ).copyWith(wordSpacing: perLineWordSpacing[i]),
                    children: spans,
                  ),
                );
              },
            ),
          );

          final pageWidget = SafeArea(
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
                    child: body,
                  ),
                ),
              ),
            ),
          );

          return _KeepAliveWrap(child: RepaintBoundary(child: pageWidget));
        }

        // Mapping not ready yet: render a neutral placeholder to avoid flashing old layout
        final media = MediaQuery.of(context);
        final double mediaTop = media.padding.top;
        final double availablePageHeight =
            (widget.pageHeight ?? (media.size.height - mediaTop));
        final placeholder = SafeArea(
          bottom: false,
          top: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: availablePageHeight,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
        return _KeepAliveWrap(child: RepaintBoundary(child: placeholder));
      },
    );
  }
}

class _KeepAliveWrap extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrap({required this.child});

  @override
  State<_KeepAliveWrap> createState() => _KeepAliveWrapState();
}

class _KeepAliveWrapState extends State<_KeepAliveWrap>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
