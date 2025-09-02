import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/core/utils/quran_verse_numbers.dart';
import 'package:jalees/core/theme/app_fonts.dart';

/// Page view that shows pages of verses. Expects pages as a list of verse lists.
class VersesPageView extends StatefulWidget {
  final List<List<QuranVerse>> pages;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double? pageHeight;
  final List<int?>? pageStartSurahIds;
  final List<QuranSurah>? allSurahs;

  // Lightweight cache to avoid repeating expensive TextPainter measurements
  // for the same page with the same width and header configuration.
  static final Map<String, _CachedSizing> _sizingCache = {};

  // Pre-compute and store sizing for a page so the first build is fast.
  static void prewarmSizingCache({
    required BuildContext context,
    required List<List<QuranVerse>> pages,
    required int pageIndex,
    required double availableWidth,
    required int availableLinesForVerses,
    required int headerLines,
    required bool isFatihaFirstPage,
    required bool isBaqarahFirstPage,
    required bool isBasmalahAllowedForSurah,
    required bool pageHasBasmalahAtTop,
  }) {
    if (pageIndex < 0 || pageIndex >= pages.length) return;
    final page = pages[pageIndex];
    final String cacheKey =
        '$pageIndex:${availableWidth.round()}:$availableLinesForVerses:$headerLines:${Theme.of(context).brightness}';
    if (_sizingCache.containsKey(cacheKey)) return; // already warmed

    // Rebuild measurement text for verses only (exclude header lines)
    String buildVersesMeasurementText(double fontSize) {
      final sb = StringBuffer();
      const String hairSpace = '\u200A';
      for (int i = 0; i < page.length; i++) {
        final verse = page[i];
        if (verse.id == 0) {
          if (i == 0 && !isBasmalahAllowedForSurah) {
            continue;
          }
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

    final bool useSlightlySmallerFont = isFatihaFirstPage || isBaqarahFirstPage;

    double computedFontSize = useSlightlySmallerFont ? 22.0 : 26.0;
    const double minFontSize = 14.0;
    const double maxFontSizeGlobal = 42.0;

    double computedWordSpacing = -0.2;
    double computedLetterSpacing = -0.2;
    const double minWordSpacing = -1.2;
    const double maxWordSpacing = 6.0;
    const double maxLetterSpacing = 1.5;

    final baseStyleTemplate = AppFonts.quranTextStyle(
      color: Theme.of(context).colorScheme.onBackground,
      fontSize: computedFontSize,
      height: 1.9,
      letterSpacing: computedLetterSpacing,
    );
    TextStyle baseStyle = baseStyleTemplate.copyWith(
      wordSpacing: computedWordSpacing,
    );

    String measureText = buildVersesMeasurementText(computedFontSize);
    int lines = measureLineCount(measureText, baseStyle);

    while (lines > availableLinesForVerses &&
        (computedWordSpacing > minWordSpacing ||
            computedFontSize > minFontSize)) {
      if (computedWordSpacing > minWordSpacing) {
        computedWordSpacing = (computedWordSpacing - 0.03).clamp(
          minWordSpacing,
          100.0,
        );
      } else if (computedFontSize > minFontSize) {
        computedFontSize = (computedFontSize - 0.3).clamp(minFontSize, 100.0);
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
    const maxIterations = 100;
    while (lines < availableLinesForVerses && iterations < maxIterations) {
      bool changed = false;
      iterations++;

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

      if (computedLetterSpacing < maxLetterSpacing) {
        final prevLs = computedLetterSpacing;
        computedLetterSpacing = (computedLetterSpacing + 0.015).clamp(
          -0.5,
          maxLetterSpacing,
        );
        baseStyle = baseStyle.copyWith(letterSpacing: computedLetterSpacing);
        measureText = buildVersesMeasurementText(computedFontSize);
        final nextLines = measureLineCount(measureText, baseStyle);
        if (nextLines > availableLinesForVerses) {
          computedLetterSpacing = prevLs;
          baseStyle = baseStyle.copyWith(letterSpacing: computedLetterSpacing);
        } else if (nextLines > lines) {
          lines = nextLines;
          changed = true;
          if (lines >= availableLinesForVerses) break;
        }
      }

      if (!changed) break;
    }

    _sizingCache[cacheKey] = _CachedSizing(
      fontSize: computedFontSize,
      wordSpacing: computedWordSpacing,
      letterSpacing: computedLetterSpacing,
    );
  }

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
  State<VersesPageView> createState() => _VersesPageViewState();
}

class _VersesPageViewState extends State<VersesPageView> {
  @override
  void initState() {
    super.initState();
    // Prewarm sizing cache for initial page and neighbors after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prewarmAroundIndex(_currentInitialPage());
    });
  }

  int _currentInitialPage() {
    try {
      if (widget.controller.hasClients && widget.controller.page != null) {
        return widget.controller.page!.round();
      }
      return widget.controller.initialPage;
    } catch (_) {
      return 0;
    }
  }

  void _prewarmAroundIndex(int index) {
    if (!mounted) return;
    final media = MediaQuery.of(context);
    final horizontalPadding = 4.0;
    final availableWidth = media.size.width - horizontalPadding * 2;

    void prewarmFor(int pageIndex) {
      if (pageIndex < 0 || pageIndex >= widget.pages.length) return;
      final page = widget.pages[pageIndex];

      // Determine header/surah context same as in build
      final headerStartSurahId =
          (widget.pageStartSurahIds != null &&
              pageIndex < widget.pageStartSurahIds!.length)
          ? widget.pageStartSurahIds![pageIndex]
          : null;

      bool pageHasBasmalahAtTop = false;
      if (headerStartSurahId != null) {
        const basmalahText = '﷽';
        pageHasBasmalahAtTop =
            page.isNotEmpty &&
            (page.first.id == 0 || page.first.text.trim() == basmalahText);
      }

      final bool isBasmalahAllowedForSurah =
          headerStartSurahId != null &&
          headerStartSurahId != 1 &&
          headerStartSurahId != 9;

      final headerLines = (headerStartSurahId != null)
          ? ((pageHasBasmalahAtTop || !isBasmalahAllowedForSurah) ? 1 : 2)
          : 0;
      final availableLinesForVerses = 15 - headerLines;

      final bool isFatihaFirstPage = headerStartSurahId == 1;
      final bool isBaqarahFirstPage = headerStartSurahId == 2;

      // Prewarm the cache for this page configuration
      VersesPageView.prewarmSizingCache(
        context: context,
        pages: widget.pages,
        pageIndex: pageIndex,
        availableWidth: availableWidth,
        availableLinesForVerses: availableLinesForVerses,
        headerLines: headerLines,
        isFatihaFirstPage: isFatihaFirstPage,
        isBaqarahFirstPage: isBaqarahFirstPage,
        isBasmalahAllowedForSurah: isBasmalahAllowedForSurah,
        pageHasBasmalahAtTop: pageHasBasmalahAtTop,
      );
    }

    // Prewarm current, previous, next and one more ahead
    for (final i in <int>{index - 1, index, index + 1, index + 2}) {
      prewarmFor(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.pages.length,
      onPageChanged: (i) {
        // Prewarm neighbors for smoother next swipes, then forward the event.
        _prewarmAroundIndex(i);
        widget.onPageChanged(i);
      },
      physics: const PageScrollPhysics(),
      allowImplicitScrolling: true,
      // Preload adjacent pages to reduce perceived latency when swiping.
      // Note: cacheExtent is ignored by PageView; prefetching is achieved by build of neighbors via PageView.
      itemBuilder: (context, pageIndex) {
        // Build the page content while enforcing exactly 15 visual lines.
        // Strategy:
        // 1. Create a plain measurement string representing the page (including verse numbers as plain Arabic numerals).
        // 2. Use TextPainter to measure how many lines the content occupies with the desired style and available width.
        // 3. If it exceeds 15 lines, reduce font size iteratively until it fits (down to a reasonable min).
        // 4. If it uses fewer than 15 lines, append blank lines to reach 15.
        // 5. Finally render the RichText with WidgetSpans for decorative verse numbers using the computed font size.

        final page = widget.pages[pageIndex];
        final horizontalPadding = 4.0; // matches container padding below
        final availableWidth =
            MediaQuery.of(context).size.width - horizontalPadding * 2;

        // Build plain text for measurement including inline SURAH headers and basmalah
        // so the total fits exactly 15 visual lines. The surah name header is inserted
        // at the exact boundary (before basmalah or before verse 1 if no basmalah).
        final int? initialSurahId =
            (widget.pageStartSurahIds != null &&
                pageIndex < widget.pageStartSurahIds!.length)
            ? widget.pageStartSurahIds![pageIndex]
            : null;
        String buildVersesMeasurementText(double fontSize) {
          final sb = StringBuffer();
          const String hairSpace = '\u200A';
          int? currentSurahId = initialSurahId;
          // Helper to get surah name by id
          String? surahName(int? id) {
            if (id == null || widget.allSurahs == null) return null;
            final s = widget.allSurahs!.firstWhere(
              (e) => e.id == id,
              orElse: () => QuranSurah(
                id: -1,
                name: '',
                transliteration: '',
                type: '',
                totalVerses: 0,
                verses: const [],
              ),
            );
            return s.id == -1 ? null : s.name;
          }

          int? inferSurahIdFromFirstVerse(String verse1Text) {
            if (widget.allSurahs == null) return null;
            final t = verse1Text.trim();
            for (final s in widget.allSurahs!) {
              final v1 = s.verses.where((v) => v.id == 1).toList();
              if (v1.isNotEmpty && v1.first.text.trim() == t) {
                return s.id;
              }
            }
            return null;
          }

          for (int i = 0; i < page.length; i++) {
            final verse = page[i];

            // Insert header at page start if it begins with new surah (basmalah or verse 1)
            if (i == 0 && (verse.id == 1 || verse.id == 0)) {
              // Use the page's starting surah id; if missing and verse is 1, infer by matching text
              int? surahIdForHeader = currentSurahId;
              if (surahIdForHeader == null && verse.id == 1) {
                surahIdForHeader = inferSurahIdFromFirstVerse(verse.text);
              }
              final name = surahName(surahIdForHeader);
              if (name != null && name.isNotEmpty) {
                sb.writeln(name);
              }
              // If it's basmalah at start, include basmalah for this surah (except 1 and 9) and do not advance id
              if (verse.id == 0) {
                if (surahIdForHeader != 1 && surahIdForHeader != 9) {
                  sb.writeln(verse.text);
                }
                // keep currentSurahId as surahIdForHeader
                currentSurahId = surahIdForHeader;
                continue;
              }
              // If page starts directly with verse 1, still show basmala for eligible surahs
              if (verse.id == 1 &&
                  surahIdForHeader != null &&
                  surahIdForHeader != 1 &&
                  surahIdForHeader != 9) {
                const basmalahText = '﷽';
                sb.writeln(basmalahText);
              }
              currentSurahId = surahIdForHeader;
            }

            if (i > 0 && verse.id == 0) {
              // Internal basmalah => next surah starts now. Determine the next surah id.
              int? nextSurahId = (currentSurahId != null)
                  ? currentSurahId + 1
                  : null;
              // If unknown, infer from the next verse text when available
              if (nextSurahId == null && i + 1 < page.length) {
                nextSurahId = inferSurahIdFromFirstVerse(page[i + 1].text);
              }
              final name = surahName(nextSurahId);
              if (name != null && name.isNotEmpty) {
                sb.writeln(name);
              }
              if (nextSurahId != 1 && nextSurahId != 9) {
                sb.writeln(verse.text);
              }
              currentSurahId = nextSurahId;
              continue;
            }

            // New surah without basmalah (e.g., Surah 9) appearing mid-page
            if (i > 0 && verse.id == 1 && page[i - 1].id != 0) {
              int? surahId = inferSurahIdFromFirstVerse(verse.text);
              if (surahId == null) {
                surahId = (currentSurahId != null) ? currentSurahId + 1 : null;
              }
              final name = surahName(surahId);
              if (name != null && name.isNotEmpty) {
                sb.writeln(name);
              }
              // Add basmala for eligible surahs
              if (surahId != null && surahId != 1 && surahId != 9) {
                const basmalahText = '﷽';
                sb.writeln(basmalahText);
              }
              currentSurahId = surahId;
            }

            // Append verse text and number
            sb.write(verse.text);
            sb.write(hairSpace);
            sb.write(
              QuranVerseNumbers.convertToArabicNumerals(verse.id.toString()),
            );
            sb.write(hairSpace);
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
        // based on the surah id at the first verse on this page.
        final headerStartSurahIdForSizing = initialSurahId;
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

        // Calculate inline headers: count surah names and basmalah that will appear
        int inlineHeaderLines = 0;
        int? currentSurahForCount = initialSurahId;

        // Count headers at page start
        if (page.isNotEmpty && (page.first.id == 1 || page.first.id == 0)) {
          int? surahIdForHeader = currentSurahForCount;
          if (surahIdForHeader == null && page.first.id == 1) {
            final matchingSurah = widget.allSurahs?.firstWhere(
              (s) => s.verses.any(
                (v) => v.id == 1 && v.text.trim() == page.first.text.trim(),
              ),
              orElse: () => QuranSurah(
                id: -1,
                name: '',
                transliteration: '',
                type: '',
                totalVerses: 0,
                verses: [],
              ),
            );
            surahIdForHeader = (matchingSurah?.id == -1)
                ? null
                : matchingSurah?.id;
          }
          if (surahIdForHeader != null) {
            inlineHeaderLines++; // surah name line
            if (page.first.id == 0) {
              // basmalah at start
              if (surahIdForHeader != 1 && surahIdForHeader != 9) {
                inlineHeaderLines++; // basmalah line
              }
            } else if (page.first.id == 1 &&
                surahIdForHeader != 1 &&
                surahIdForHeader != 9) {
              // verse 1 at start, add basmalah
              inlineHeaderLines++; // basmalah line
            }
          }
          currentSurahForCount = surahIdForHeader;
        }

        // Count mid-page headers
        for (int i = 1; i < page.length; i++) {
          final verse = page[i];
          if (verse.id == 0) {
            // Internal basmalah => next surah
            int? nextSurahId = (currentSurahForCount != null)
                ? currentSurahForCount + 1
                : null;
            if (nextSurahId != null) {
              inlineHeaderLines++; // surah name line
              if (nextSurahId != 1 && nextSurahId != 9) {
                inlineHeaderLines++; // basmalah line
              }
              currentSurahForCount = nextSurahId;
            }
          } else if (verse.id == 1 && page[i - 1].id != 0) {
            // New surah without basmalah (e.g., Surah 9)
            int? surahId = currentSurahForCount != null
                ? currentSurahForCount + 1
                : null;
            if (surahId != null) {
              inlineHeaderLines++; // surah name line
              if (surahId != 1 && surahId != 9) {
                inlineHeaderLines++; // basmalah line
              }
              currentSurahForCount = surahId;
            }
          }
        }

        // Available lines for verse text = 15 - inline headers
        final availableLinesForVerses = (15 - inlineHeaderLines).clamp(1, 15);

        // Measure verses only and fit them into availableLinesForVerses.
        // Use cache if available to avoid expensive TextPainter measurement that
        // can cause jank during quick page swipes. When cache is missing we
        // perform the measurement and then store the result for future builds.
        final String cacheKey =
            '$pageIndex:${availableWidth.round()}:$availableLinesForVerses:${Theme.of(context).brightness}';
        final _CachedSizing? cached = VersesPageView._sizingCache[cacheKey];
        if (cached != null) {
          computedFontSize = cached.fontSize;
          computedWordSpacing = cached.wordSpacing;
          computedLetterSpacing = cached.letterSpacing;
          baseStyle = baseStyleTemplate.copyWith(
            fontSize: computedFontSize,
            wordSpacing: computedWordSpacing,
            letterSpacing: computedLetterSpacing,
          );
        } else {
          String measureText = buildVersesMeasurementText(computedFontSize);
          int lines = measureLineCount(measureText, baseStyle);

          // First, try reducing spacing and font size if we have too many lines
          while (lines > availableLinesForVerses &&
              (computedWordSpacing > minWordSpacing ||
                  computedFontSize > minFontSize)) {
            if (computedWordSpacing > minWordSpacing) {
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
          const maxIterations = 100;
          while (lines < availableLinesForVerses &&
              iterations < maxIterations) {
            bool changed = false;
            iterations++;
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
                baseStyle = baseStyle.copyWith(
                  wordSpacing: computedWordSpacing,
                );
              } else if (nextLines > lines) {
                lines = nextLines;
                changed = true;
                if (lines >= availableLinesForVerses) break;
              }
            }
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
            if (!changed) break;
          }

          // Cache sizing for subsequent builds to avoid repeat work on UI thread
          VersesPageView._sizingCache[cacheKey] = _CachedSizing(
            fontSize: computedFontSize,
            wordSpacing: computedWordSpacing,
            letterSpacing: computedLetterSpacing,
          );
        }

        // Build BODY widgets with inline surah headers and basmalah
        final List<Widget> bodyWidgets = [];
        final List<InlineSpan> verseChunk = [];

        int? currentSurahId = initialSurahId;

        void flushChunk() {
          if (verseChunk.isEmpty) return;
          final bool shouldCenterText = isFatihaFirstPage || isBaqarahFirstPage;
          bodyWidgets.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: shouldCenterText
                    ? TextAlign.center
                    : TextAlign.justify,
                textWidthBasis: TextWidthBasis.parent,
                text: TextSpan(style: baseStyle, children: [...verseChunk]),
              ),
            ),
          );
          verseChunk.clear();
        }

        int? inferSurahIdFromFirstVerse(String verse1Text) {
          if (widget.allSurahs == null) return null;
          final t = verse1Text.trim();
          for (final s in widget.allSurahs!) {
            final v1 = s.verses.where((v) => v.id == 1).toList();
            if (v1.isNotEmpty && v1.first.text.trim() == t) {
              return s.id;
            }
          }
          return null;
        }

        Widget surahHeaderDecorated(int surahId) {
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
              // make full-width with smaller vertical footprint
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              decoration: BoxDecoration(
                // richer, slightly warmer gradient for an Islamic feel
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
                  // decorative left ornament
                  Text(
                    '❁',
                    style: TextStyle(fontSize: 20, color: AppFonts.brightGold),
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
                  // decorative right ornament
                  Text(
                    '❁',
                    style: TextStyle(fontSize: 20, color: AppFonts.brightGold),
                  ),
                ],
              ),
            ),
          );
        }

        for (int i = 0; i < page.length; i++) {
          final verse = page[i];

          // Insert header at page start for new surah
          if (i == 0 && (verse.id == 1 || verse.id == 0)) {
            int? surahIdForHeader = currentSurahId;
            if (surahIdForHeader == null && verse.id == 1) {
              surahIdForHeader = inferSurahIdFromFirstVerse(verse.text);
            }
            if (surahIdForHeader != null) {
              flushChunk();
              bodyWidgets.add(surahHeaderDecorated(surahIdForHeader));
              // If basmalah at start and allowed, show it and keep current surah id
              if (verse.id == 0 &&
                  surahIdForHeader != 1 &&
                  surahIdForHeader != 9) {
                bodyWidgets.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: computedFontSize * 1.0,
                      child: Center(
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
                );
                currentSurahId = surahIdForHeader;
                continue; // don't add basmalah again
              }
              // If page starts with verse 1, add basmala line for eligible surahs
              if (verse.id == 1 &&
                  surahIdForHeader != 1 &&
                  surahIdForHeader != 9) {
                bodyWidgets.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: computedFontSize * 1.0,
                      child: Center(
                        child: Text(
                          '﷽',
                          textAlign: TextAlign.center,
                          style: AppFonts.basmalahStyle(

                            color: Theme.of(context).colorScheme.primary,
                          ).copyWith(fontSize: computedFontSize - 4.5),
                        ),
                      ),
                    ),
                  ),
                );
              }
              currentSurahId = surahIdForHeader;
            }
          }

          if (i > 0 && verse.id == 0) {
            // Internal basmalah => transition to next surah
            int? nextSurahId = (currentSurahId != null)
                ? currentSurahId + 1
                : null;
            if (nextSurahId == null && i + 1 < page.length) {
              nextSurahId = inferSurahIdFromFirstVerse(page[i + 1].text);
            }
            if (nextSurahId != null) {
              flushChunk();
              bodyWidgets.add(surahHeaderDecorated(nextSurahId));
              if (nextSurahId != 1 && nextSurahId != 9) {
                bodyWidgets.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: computedFontSize * 1.0,
                      child: Center(
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
                );
              }
              currentSurahId = nextSurahId;
              continue;
            }
          }

          if (i > 0 && verse.id == 1 && page[i - 1].id != 0) {
            // New surah without basmalah (e.g., Surah 9)
            int? surahId = inferSurahIdFromFirstVerse(verse.text);
            if (surahId == null) {
              surahId = (currentSurahId != null) ? currentSurahId + 1 : null;
            }
            if (surahId != null) {
              flushChunk();
              bodyWidgets.add(surahHeaderDecorated(surahId));
              if (surahId != 1 && surahId != 9) {
                bodyWidgets.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: computedFontSize * 1.0,
                      child: Center(
                        child: Text(
                          '﷽',
                          textAlign: TextAlign.center,
                          style: AppFonts.basmalahStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ).copyWith(fontSize: computedFontSize - 2),
                        ),
                      ),
                    ),
                  ),
                );
              }
              currentSurahId = surahId;
            }
          }

          // Append verse text and number to the current chunk
          verseChunk.add(TextSpan(text: verse.text));
          final String rtlNumberCore =
              '\u061C${QuranVerseNumbers.getDecorativeVerseNumber(verse.id)}\u061C';
          final String rtlNumber = '\u200A' + rtlNumberCore + '\u200A';
          verseChunk.add(
            TextSpan(
              text: rtlNumber,
              style: AppFonts.verseNumberStyle(
                fontSize: computedFontSize + 6,
                color: AppFonts.brightGold,
              ).copyWith(fontFamily: AppFonts.versesFont, height: 1.0),
            ),
          );
        }

        // Flush remaining verses
        flushChunk();

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

        // Compute precise pixel heights: use computedFontSize and dynamic line height
        final double bodyLineHeightPx = computedFontSize * 1.9;
        final double bodyHeightPx = availableLinesForVerses * bodyLineHeightPx;

        // We'll compute the exact body area height and set a dynamic line-height
        // so the verses occupy the full area without leaving empty space.

        // Compute available page height (respecting safe areas) and scale the
        // combined header+body vertically if it would overflow the visible area.
        final double mediaTop = MediaQuery.of(context).padding.top;
        // Since we're using SafeArea with bottom: false, we don't subtract bottom padding
        final double availablePageHeight =
            (widget.pageHeight ??
            (MediaQuery.of(context).size.height - mediaTop));

        // Build a constrained page layout: fixed header height and an
        // Expanded body that fills remaining availablePageHeight. This
        // prevents vertical overflow by ensuring children cannot exceed
        // the page container's height.
        // No separate header widget; headers are inline in bodyWidgets

        // Build the body with a LayoutBuilder to know the exact remaining height
        // and then set the TextStyle.height accordingly to fill it.
        final Widget bodyWidget = LayoutBuilder(
          builder: (context, constraints) {
            final double availableBodyHeightPx = constraints.maxHeight;

            // Count fixed-height elements (surah headers and basmalah lines)
            int fixedLinesCount = 0;
            for (final w in bodyWidgets) {
              if (w is Directionality && w.child is SizedBox) {
                fixedLinesCount++; // Each SizedBox is one fixed line (surah name or basmalah)
              }
            }

            // Calculate available lines for RichText content
            final int availableLinesForText = (15 - fixedLinesCount).clamp(
              1,
              15,
            );

            // Reserve fixed height for headers/basmalah and use remainder for text
            final double fixedElementHeight =
                computedFontSize * 1.2; // height per fixed element
            final double totalFixedHeight =
                fixedLinesCount * fixedElementHeight;
            final double availableTextHeight =
                availableBodyHeightPx - totalFixedHeight;

            // Dynamic line-height for RichText content only
            final double dynamicLineHeight =
                availableLinesForText > 0 && computedFontSize > 0
                ? availableTextHeight /
                      (availableLinesForText * computedFontSize)
                : 1.9;

            // Clamp line height to reasonable bounds to maintain readability
            final double safeLineHeight = dynamicLineHeight.clamp(1.0, 2.8);

            // Update styles of the rich text(s) to use the dynamic line height
            final List<Widget> adjusted = [];
            for (final w in bodyWidgets) {
              if (w is Directionality && w.child is RichText) {
                final rich = (w.child as RichText);
                final ts = rich.text as TextSpan;
                final updated = TextSpan(
                  style: ts.style?.copyWith(height: safeLineHeight),
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
                // Header/basmalah lines: use fixed height (1 line equivalent)
                final sb = w.child as SizedBox;
                adjusted.add(
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: fixedElementHeight,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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

        // Wrap page in KeepAlive + RepaintBoundary to reduce rebuilds and repaints.
        return _KeepAliveWrap(child: RepaintBoundary(child: pageWidget));
      },
    );
  }
}

class _CachedSizing {
  final double fontSize;
  final double wordSpacing;
  final double letterSpacing;
  const _CachedSizing({
    required this.fontSize,
    required this.wordSpacing,
    required this.letterSpacing,
  });
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
