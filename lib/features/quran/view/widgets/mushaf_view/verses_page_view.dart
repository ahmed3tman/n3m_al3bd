import 'package:flutter/material.dart';
import 'package:n3m_al3bd/features/quran/model/quran_model.dart';

import 'package:n3m_al3bd/features/quran/view/widgets/mushaf_view/mushaf_page.dart';
import 'package:n3m_al3bd/features/quran/view/widgets/mushaf_view/verse_layout_cache.dart';
import 'package:n3m_al3bd/features/quran/view/widgets/mushaf_view/verse_layout_computer.dart';
import 'dart:async';

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
        // Trigger pre-calculation for neighbors in background
        _precacheNeighbors(i);
      },
      physics: const PageScrollPhysics(),
      allowImplicitScrolling: true,
      itemBuilder: (context, pageIndex) {
        final int pageNumber = pageIndex + 1;
        final List<List<Map<String, int>>>? mappedTokens =
            widget.lineMappingByPageTokens != null
            ? widget.lineMappingByPageTokens![pageNumber]
            : null;

        if (mappedTokens != null && mappedTokens.isNotEmpty) {
          final horizontalPadding = 5.0; // Increased text padding for gap
          final borderPadding = 1.0; // Border padding
          final media = MediaQuery.of(context);
          final availableWidth = media.size.width - horizontalPadding * 2;
          final double mediaTop = media.padding.top;
          final double availablePageHeight =
              (widget.pageHeight ?? (media.size.height - mediaTop));

          // NEW: Get next page tokens for cross-page header logic
          final int nextPageNumber = pageNumber + 1;
          final List<List<Map<String, int>>>? nextPageTokens =
              widget.lineMappingByPageTokens != null
              ? widget.lineMappingByPageTokens![nextPageNumber]
              : null;

          // Trigger pre-calculation for this page if not cached (redundant but safe)
          // and neighbors.
          if (pageIndex == widget.controller.initialPage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _precacheNeighbors(pageIndex);
            });
          }

          return _KeepAliveWrap(
            child: RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: MushafPage(
                      pageIndex: pageIndex,
                      mappedTokens: mappedTokens,
                      allSurahs: widget.allSurahs!,
                      availableWidth: availableWidth,
                      availablePageHeight: availablePageHeight,
                      pageStartSurahIds: widget.pageStartSurahIds,
                      nextPageTokens: nextPageTokens,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 0.3,
                          left: 0.3,
                          top: 6,
                          bottom: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Mapping not ready yet
        final media = MediaQuery.of(context);
        final double mediaTop = media.padding.top;
        final double availablePageHeight =
            (widget.pageHeight ?? (media.size.height - mediaTop));
        return _KeepAliveWrap(
          child: RepaintBoundary(
            child: SafeArea(
              bottom: false,
              top: false,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: availablePageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: const SizedBox.expand(),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.5),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _precacheNeighbors(int currentPageIndex) {
    if (widget.lineMappingByPageTokens == null) return;

    final media = MediaQuery.of(context);
    final horizontalPadding = 5.0;
    final availableWidth = media.size.width - horizontalPadding * 2;
    final double mediaTop = media.padding.top;
    final double availablePageHeight =
        (widget.pageHeight ?? (media.size.height - mediaTop));

    // Pre-calculate next 2 and prev 1 pages
    final pagesToCache = [
      currentPageIndex + 1,
      currentPageIndex + 2,
      currentPageIndex - 1,
    ];

    for (final pIndex in pagesToCache) {
      if (pIndex >= 0 && pIndex < widget.pages.length) {
        final pageNum = pIndex + 1;
        final tokens = widget.lineMappingByPageTokens![pageNum];
        if (tokens != null && tokens.isNotEmpty) {
          // Check cache first to avoid redundant work
          if (VerseLayoutCache.get(
                pIndex,
                availableWidth,
                availablePageHeight,
              ) ==
              null) {
            // NEW: Get next page tokens for cross-page header logic
            final nextPageNum = pageNum + 1;
            final nextTokens = widget.lineMappingByPageTokens![nextPageNum];

            // Compute in background (microtask or just sync in post frame)
            // Since this is called from onPageChanged or postFrame, it's okay to be sync
            // if it's not too heavy, but better to schedule it.
            // Ideally we'd use compute() isolate, but we can't use TextPainter there.
            // So we rely on the fact that this happens when the user is idle reading the verse.
            Future.microtask(() {
              VerseLayoutComputer.computeLayout(
                pageIndex: pIndex,
                mappedTokens: tokens,
                allSurahs: widget.allSurahs!,
                availableWidth: availableWidth,
                availablePageHeight: availablePageHeight,
                pageStartSurahIds: widget.pageStartSurahIds,
                nextPageTokens: nextTokens, // NEW
              );
              // Result is cached inside computeLayout if we modify it,
              // but currently computeLayout returns data and we must cache it.
              // Wait, VerseLayoutComputer.computeLayout returns data, it doesn't cache it.
              // I need to cache it here.
              final data = VerseLayoutComputer.computeLayout(
                pageIndex: pIndex,
                mappedTokens: tokens,
                allSurahs: widget.allSurahs!,
                availableWidth: availableWidth,
                availablePageHeight: availablePageHeight,
                pageStartSurahIds: widget.pageStartSurahIds,
                nextPageTokens: nextTokens, // NEW
              );
              VerseLayoutCache.set(
                pIndex,
                availableWidth,
                availablePageHeight,
                data,
              );
            });
          }
        }
      }
    }
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
