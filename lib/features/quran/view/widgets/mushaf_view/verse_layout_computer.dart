import 'package:flutter/material.dart';
import 'package:n3m_al3bd/core/theme/app_fonts.dart';
import 'package:n3m_al3bd/core/utils/quran_verse_numbers.dart';
import 'package:n3m_al3bd/features/quran/model/quran_model.dart';
import 'package:n3m_al3bd/features/quran/view/widgets/mushaf_view/verse_layout_cache.dart';

/// Helper class to compute the layout (font size, spacing) for a Mushaf page.
/// This logic is expensive and should be cached.
class VerseLayoutComputer {
  static VerseLayoutData computeLayout({
    required int pageIndex,
    required List<List<Map<String, int>>> mappedTokens,
    required List<QuranSurah> allSurahs,
    required double availableWidth,
    required double availablePageHeight,
    required List<int?>? pageStartSurahIds,
    List<List<Map<String, int>>>? nextPageTokens, // NEW: For cross-page header
  }) {
    // Optimization: Create O(1) lookup for Surahs
    final Map<int, QuranSurah> surahMap = {for (var s in allSurahs) s.id: s};

    // Optimization: Cache split verse words to avoid repeated Regex splitting
    // Key: "sura:aya" -> List<String> words
    final Map<String, List<String>> verseWordsCache = {};

    List<String> getVerseWords(int sura, int aya) {
      final key = '$sura:$aya';
      if (verseWordsCache.containsKey(key)) {
        return verseWordsCache[key]!;
      }
      final surah = surahMap[sura];
      if (surah == null || aya < 1 || aya > surah.verses.length) {
        return const [];
      }
      final text = surah.verses[aya - 1].text.trim();
      final words = text.split(RegExp(r"\s+"));
      verseWordsCache[key] = words;
      return words;
    }

    // 1. Determine if we should center align (Fatiha or first page of Baqarah)
    final int? initialSurahId =
        (pageStartSurahIds != null && pageIndex < pageStartSurahIds.length)
        ? pageStartSurahIds[pageIndex]
        : null;
    final bool isFatihaFirstPage = initialSurahId == 1;
    final bool isBaqarahFirstPage = initialSurahId == 2;
    final bool shouldCenterText = isFatihaFirstPage || isBaqarahFirstPage;

    double fontSize = shouldCenterText ? 25.0 : 30.0;
    const double minFontSize = 12.0;
    const double maxFontSize = 46.0;

    // NEW: Constrain font size by available height to prevent clipping
    // We want (fontSize * 1.8) * 15 <= (availablePageHeight - 32)
    // So fontSize <= (availablePageHeight - 32) / 27.0
    final double maxFontSizeForHeight = (availablePageHeight - 32) / 27.0;
    if (fontSize > maxFontSizeForHeight) {
      fontSize = maxFontSizeForHeight;
    }

    double letterSpacing = -0.4;
    double wordSpacing = 0.0;

    // 2. Precompute the last token position for each (sura,aya)
    final Map<String, List<int>> lastAyahTokenPos =
        _computeLastTokenPositionsInternal(
          mappedTokens,
          surahMap,
          getVerseWords,
        );

    // Helper to build spans for measurement
    List<InlineSpan> buildLineSpans(int i) {
      return _buildLineSpansInternal(
        i,
        mappedTokens,
        surahMap,
        getVerseWords,
        lastAyahTokenPos,
        fontSize,
      );
    }

    // Helper to measure lines
    int lineCountFor(List<InlineSpan> spans, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(children: spans, style: style),
        textDirection: TextDirection.rtl,
        textAlign: shouldCenterText ? TextAlign.center : TextAlign.justify,
        textWidthBasis: TextWidthBasis.parent,
        maxLines: 3,
      );
      tp.layout(minWidth: 0, maxWidth: availableWidth);
      return tp.computeLineMetrics().length;
    }

    TextStyle baseStyle() => AppFonts.quranTextStyle(
      color: Colors.black, // Color doesn't matter for measurement
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

    // 3. Adjust font size
    int guard = 0;
    while (maxLinesUsed() > 1 && fontSize > minFontSize && guard < 200) {
      guard++;
      if (fontSize > minFontSize) {
        fontSize = (fontSize - 0.5).clamp(minFontSize, maxFontSize);
      }
    }

    // 4. Determine decorations (headers, basmalahs)
    final List<LineDeco> decos = List<LineDeco>.filled(15, LineDeco.none);
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

    // NEW: Check if we should place header for next page's surah on line 15
    // Only for Surahs 4 (An-Nisa) and 10 (Yunus)
    if (nextPageTokens != null && mappedTokens[14].isEmpty) {
      // Line 15 (index 14) is empty on current page
      // Check if next page starts with Surah 4 or 10
      for (int i = 0; i < nextPageTokens.length; i++) {
        if (nextPageTokens[i].isNotEmpty) {
          final firstToken = nextPageTokens[i].first;
          final nextPageSurahId = firstToken['sura_no'];
          final isNextPageSurahStart =
              firstToken['aya_no'] == 1 && firstToken['word_pos'] == 1;

          // Only apply to Surahs 4 (An-Nisa) and 10 (Yunus)
          if (isNextPageSurahStart &&
              (nextPageSurahId == 4 || nextPageSurahId == 10)) {
            // Place header on line 15 of current page
            decos[14] = LineDeco.header;
            decoSurahIds[14] = nextPageSurahId;
          }
          break;
        }
      }
    }

    int li = 0;
    while (li < 15) {
      // Skip if this line already has a decoration (e.g., from cross-page header)
      if (decos[li] != LineDeco.none) {
        li++;
        continue;
      }

      if (mappedTokens[li].isEmpty) {
        final k = nextNonEmptyFrom(li + 1);
        if (k != null && isSurahStartLine(k)) {
          final surahId = surahIdAtLine(k);
          final emptyCount = k - li;
          final bool basmalahAllowed =
              surahId != null && surahId != 1 && surahId != 9;

          // Track current empty line position for sequential assignment
          int currentEmptyLine = li;

          // Special handling for Surahs 4 and 10:
          // If only 1 empty line, header is on previous page, so only place basmalah
          final bool headerOnPreviousPage =
              (surahId == 4 || surahId == 10) && emptyCount == 1;

          // Place header on first empty line (unless it's on previous page)
          if (emptyCount >= 1 && !headerOnPreviousPage) {
            decos[currentEmptyLine] = LineDeco.header;
            decoSurahIds[currentEmptyLine] = surahId;
            currentEmptyLine++;
          }

          // Place basmalah
          if (basmalahAllowed) {
            if (headerOnPreviousPage && emptyCount >= 1) {
              // Header is on previous page, place basmalah on first empty line
              decos[currentEmptyLine] = LineDeco.basmalah;
              decoSurahIds[currentEmptyLine] = surahId;
              currentEmptyLine++;
            } else if (emptyCount >= 2 && currentEmptyLine < k) {
              // Normal case: place basmalah on second empty line
              decos[currentEmptyLine] = LineDeco.basmalah;
              decoSurahIds[currentEmptyLine] = surahId;
              currentEmptyLine++;
            }
          }

          // Mark any remaining empty lines as spacers
          for (int j = li; j < k; j++) {
            if (decos[j] == LineDeco.none) {
              decos[j] = LineDeco.spacer;
            }
          }
          li = k;
          continue;
        } else {
          decos[li] = LineDeco.spacer;
        }
      }
      li++;
    }

    // 5. Compute spacing
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
            count += '\u0020'.allMatches(sp.text!).length;
          }
        }
        return count;
      }

      for (int i = 0; i < 15; i++) {
        if (i >= mappedTokens.length) break;
        if (decos[i] != LineDeco.none) continue;

        final spans = buildLineSpans(i);
        if (spans.isEmpty) continue;
        final int gaps = spaceCountIn(spans);
        if (gaps <= 0) continue;

        final TextStyle base = AppFonts.quranTextStyle(
          color: Colors.black,
          fontSize: fontSize,
          height: 1.9,
          letterSpacing: letterSpacing,
        );

        final double w0 = lineWidthFor(spans, base);
        final double remaining0 = (availableWidth - w0);
        if (remaining0 <= 0.5) {
          perLineWordSpacing[i] = 0.0;
          continue;
        }

        // Optimization: Reduced iterations from 14 to 6.
        // 6 iterations gives precision of ~18/64 = 0.28px, which is sufficient.
        double lo = 0.0;
        double hi = 18.0;
        double best = 0.0;
        const int maxIter = 6;
        for (int it = 0; it < maxIter; it++) {
          final mid = (lo + hi) / 2.0;
          final styleMid = base.copyWith(wordSpacing: mid);
          final lines = lineCountFor(spans, styleMid);
          if (lines > 1) {
            hi = mid;
            continue;
          }
          final w = lineWidthFor(spans, styleMid);
          if (w <= availableWidth + 0.1) {
            best = mid;
            lo = mid;
          } else {
            hi = mid;
          }
        }
        perLineWordSpacing[i] = best;

        final TextStyle afterWord = base.copyWith(wordSpacing: best);
        final double wAfterWord = lineWidthFor(spans, afterWord);
        final double slack = availableWidth - wAfterWord;
        if (slack > 0.2) {
          double loLs = letterSpacing;
          double hiLs = letterSpacing + 2.0;
          double bestLs = loLs;
          for (int it = 0; it < maxIter; it++) {
            final midLs = (loLs + hiLs) / 2.0;
            final styleMidLs = afterWord.copyWith(letterSpacing: midLs);
            final lines = lineCountFor(spans, styleMidLs);
            if (lines > 1) {
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

    return VerseLayoutData(
      fontSize: fontSize,
      wordSpacing: perLineWordSpacing,
      letterSpacing: perLineLetterSpacing,
      lineDecos: decos,
      decoSurahIds: decoSurahIds,
      isCentered: shouldCenterText,
    );
  }

  // Public wrapper that builds the cache internally for the single call
  static Map<String, List<int>> computeLastTokenPositions(
    List<List<Map<String, int>>> mappedTokens,
    List<QuranSurah> allSurahs,
  ) {
    final Map<int, QuranSurah> surahMap = {for (var s in allSurahs) s.id: s};
    final Map<String, List<String>> verseWordsCache = {};

    List<String> getVerseWords(int sura, int aya) {
      final key = '$sura:$aya';
      if (verseWordsCache.containsKey(key)) {
        return verseWordsCache[key]!;
      }
      final surah = surahMap[sura];
      if (surah == null || aya < 1 || aya > surah.verses.length) {
        return const [];
      }
      final text = surah.verses[aya - 1].text.trim();
      final words = text.split(RegExp(r"\s+"));
      verseWordsCache[key] = words;
      return words;
    }

    return _computeLastTokenPositionsInternal(
      mappedTokens,
      surahMap,
      getVerseWords,
    );
  }

  // Internal optimized implementation
  static Map<String, List<int>> _computeLastTokenPositionsInternal(
    List<List<Map<String, int>>> mappedTokens,
    Map<int, QuranSurah> surahMap,
    List<String> Function(int, int) getVerseWords,
  ) {
    final Map<String, List<int>> lastAyahTokenPos = {};
    for (int li = 0; li < mappedTokens.length; li++) {
      final lineTokens = mappedTokens[li];
      for (int ti = 0; ti < lineTokens.length; ti++) {
        final t = lineTokens[ti];
        final suraNo = t['sura_no'];
        final ayaNo = t['aya_no'];
        final wordPos = t['word_pos'];
        if (suraNo == null || ayaNo == null || wordPos == null) continue;
        if (ayaNo == 0) continue;

        final words = getVerseWords(suraNo, ayaNo);
        if (wordPos > 0 && wordPos <= words.length) {
          lastAyahTokenPos['$suraNo:$ayaNo'] = [li, ti];
        }
      }
    }
    return lastAyahTokenPos;
  }

  // Public wrapper
  static List<InlineSpan> buildLineSpans(
    int i,
    List<List<Map<String, int>>> mappedTokens,
    List<QuranSurah> allSurahs,
    Map<String, List<int>> lastAyahTokenPos,
    double fontSize,
  ) {
    final Map<int, QuranSurah> surahMap = {for (var s in allSurahs) s.id: s};
    final Map<String, List<String>> verseWordsCache = {};

    List<String> getVerseWords(int sura, int aya) {
      final key = '$sura:$aya';
      if (verseWordsCache.containsKey(key)) {
        return verseWordsCache[key]!;
      }
      final surah = surahMap[sura];
      if (surah == null || aya < 1 || aya > surah.verses.length) {
        return const [];
      }
      final text = surah.verses[aya - 1].text.trim();
      final words = text.split(RegExp(r"\s+"));
      verseWordsCache[key] = words;
      return words;
    }

    return _buildLineSpansInternal(
      i,
      mappedTokens,
      surahMap,
      getVerseWords,
      lastAyahTokenPos,
      fontSize,
    );
  }

  // Internal optimized implementation
  static List<InlineSpan> _buildLineSpansInternal(
    int i,
    List<List<Map<String, int>>> mappedTokens,
    Map<int, QuranSurah> surahMap,
    List<String> Function(int, int) getVerseWords,
    Map<String, List<int>> lastAyahTokenPos,
    double fontSize,
  ) {
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

      final words = getVerseWords(suraNo, ayaNo);
      if (wordPos <= 0 || wordPos > words.length) continue;
      final word = words[wordPos - 1];

      if (spans.isNotEmpty) spans.add(const TextSpan(text: ' '));
      spans.add(TextSpan(text: word));

      // Check if last token
      final pos = lastAyahTokenPos['$suraNo:$ayaNo'];
      final isLast = pos != null && pos[0] == i && pos[1] == ti;

      if (isLast) {
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
}
