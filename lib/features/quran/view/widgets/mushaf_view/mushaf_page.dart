import 'package:flutter/material.dart';
import 'package:jalees/core/theme/app_fonts.dart';

import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/features/quran/view/widgets/mushaf_view/verse_layout_cache.dart';
import 'package:jalees/features/quran/view/widgets/mushaf_view/verse_layout_computer.dart';

class MushafPage extends StatelessWidget {
  final int pageIndex;
  final List<List<Map<String, int>>> mappedTokens;
  final List<QuranSurah> allSurahs;
  final double availableWidth;
  final double availablePageHeight;
  final List<int?>? pageStartSurahIds;
  final List<List<Map<String, int>>>?
  nextPageTokens; // NEW: For cross-page header

  const MushafPage({
    super.key,
    required this.pageIndex,
    required this.mappedTokens,
    required this.allSurahs,
    required this.availableWidth,
    required this.availablePageHeight,
    this.pageStartSurahIds,
    this.nextPageTokens, // NEW
  });

  @override
  Widget build(BuildContext context) {
    // 1. Try to get cached layout
    VerseLayoutData? layoutData = VerseLayoutCache.get(
      pageIndex,
      availableWidth,
      availablePageHeight,
    );

    // 2. If not cached, compute and cache it (Synchronous on UI thread)
    //    This might cause a frame drop on the very first render of a page,
    //    but subsequent renders/scrolls will be instant.
    //    Pre-caching in parent widget can mitigate the first-render jank.
    if (layoutData == null) {
      layoutData = VerseLayoutComputer.computeLayout(
        pageIndex: pageIndex,
        mappedTokens: mappedTokens,
        allSurahs: allSurahs,
        availableWidth: availableWidth,
        availablePageHeight: availablePageHeight,
        pageStartSurahIds: pageStartSurahIds,
        nextPageTokens: nextPageTokens, // NEW: Pass next page tokens
      );
      VerseLayoutCache.set(
        pageIndex,
        availableWidth,
        availablePageHeight,
        layoutData,
      );
    }

    // 3. Render using layoutData
    final double dynamicLineHeightMap = (15 > 0 && layoutData.fontSize > 0)
        ? (availablePageHeight / (15 * layoutData.fontSize))
        : 1.9;
    final double safeLineHeightMap = dynamicLineHeightMap.clamp(1.2, 2.8);
    final double fixedLineHeightPx = layoutData.fontSize * safeLineHeightMap;

    // 4. Precompute last token positions for this page (cheap)
    final lastAyahTokenPos = VerseLayoutComputer.computeLastTokenPositions(
      mappedTokens,
      allSurahs,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 15,
        itemBuilder: (context, i) {
          switch (layoutData!.lineDecos[i]) {
            case LineDeco.header:
              final sid = layoutData.decoSurahIds[i] ?? 0;
              return SizedBox(
                height: fixedLineHeightPx,
                child: Center(
                  child: _SurahHeaderDecorated(
                    surahId: sid,
                    allSurahs: allSurahs,
                  ),
                ),
              );
            case LineDeco.basmalah:
              return SizedBox(
                height: fixedLineHeightPx,
                child: Center(
                  child: Text(
                    '﷽',
                    textAlign: TextAlign.center,
                    style: AppFonts.basmalahStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ).copyWith(fontSize: layoutData.fontSize - 2),
                  ),
                ),
              );
            case LineDeco.spacer:
              return SizedBox(height: fixedLineHeightPx);
            case LineDeco.none:
              break;
          }

          final spans = VerseLayoutComputer.buildLineSpans(
            i,
            mappedTokens,
            allSurahs,
            lastAyahTokenPos,
            layoutData.fontSize,
          );
          return RichText(
            textAlign:
                (layoutData.fontSize == 25.0) // heuristic for centered
                ? TextAlign.center
                : TextAlign.justify,
            textWidthBasis: TextWidthBasis.parent,
            text: TextSpan(
              style: AppFonts.quranTextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: layoutData.fontSize,
                height: safeLineHeightMap,
                letterSpacing: layoutData.letterSpacing[i],
              ).copyWith(wordSpacing: layoutData.wordSpacing[i]),
              children: spans,
            ),
          );
        },
      ),
    );
  }
}

class _SurahHeaderDecorated extends StatelessWidget {
  final int surahId;
  final List<QuranSurah> allSurahs;

  const _SurahHeaderDecorated({required this.surahId, required this.allSurahs});

  @override
  Widget build(BuildContext context) {
    final s = allSurahs.firstWhere(
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
    final display = (s.id == -1) ? '' : s.name;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
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
            style: TextStyle(fontSize: 20, color: theme.colorScheme.secondary),
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
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '❁',
            style: TextStyle(fontSize: 20, color: theme.colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}
