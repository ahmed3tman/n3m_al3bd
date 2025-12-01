import 'package:flutter/material.dart';
import 'package:n3m_al3bd/core/theme/app_fonts.dart';
import 'package:n3m_al3bd/core/utils/quran_verse_numbers.dart';
import 'package:n3m_al3bd/features/quran/data/page_mapping_repository.dart';
import 'package:n3m_al3bd/features/quran/data/line_mapping_repository.dart';
import '../../model/quran_model.dart';
import '../../model/mushaf_model.dart';
import 'package:n3m_al3bd/features/quran/view/widgets/mushaf_view/widgets.dart'
    as mushaf_view_widgets;

class MushafScreen extends StatefulWidget {
  final Mushaf mushaf;
  final List<QuranSurah> allSurahs;

  const MushafScreen({
    super.key,
    required this.mushaf,
    required this.allSurahs,
  });

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late int currentIndex;
  late int currentPageIndex;
  late PageController pageController;
  late List<List<QuranVerse>> pages;
  late Map<int, List<Map<String, dynamic>>> _pageMapping;
  Map<int, List<List<Map<String, int>>>> _lineMapping = const {};
  late List<int?> pageStartSurahIds;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.mushaf.currentSurahIndex;
    currentPageIndex = widget.mushaf.currentPageIndex;
    pageController = PageController(
      initialPage: currentPageIndex,
      viewportFraction: 1.0, // explicit
    );
    _pageMapping = {};
    pages = [];
    _isSaved =
        widget.mushaf.currentPageIndex == currentPageIndex &&
        widget.mushaf.currentSurahIndex == currentIndex;
    // If mapping is already cached, build pages immediately to avoid any delay.
    final cached = PageMappingRepository.cache;
    if (cached != null && cached.isNotEmpty) {
      _pageMapping = cached;
      _buildPagesFromMapping();
      // clamp current page
      if (currentPageIndex >= pages.length) {
        currentPageIndex = pages.isNotEmpty ? pages.length - 1 : 0;
      }
      // no setState here; first build will use the prepared data
      // Also, prewarm in background for neighbors
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // ensure futures stay warm
        PageMappingRepository.ensureLoaded();
        // Load line mapping in background as well
        final lm = await LineMappingRepository.ensureLoaded();
        if (mounted) {
          setState(() {
            _lineMapping = lm;
          });
        }
      });
    } else {
      // Kick off loading in background, but render instantly without spinner.
      PageMappingRepository.ensureLoaded().then((map) async {
        if (!mounted) return;
        _pageMapping = map;
        _buildPagesFromMapping();
        if (currentPageIndex >= pages.length) {
          currentPageIndex = pages.isNotEmpty ? pages.length - 1 : 0;
        }
        if (mounted) setState(() {}); // Fix: Ensure UI rebuilds after loading
        // Load line mapping in parallel
        try {
          final lm = await LineMappingRepository.ensureLoaded();
          if (mounted) {
            setState(() {
              _lineMapping = lm;
            });
          }
        } catch (_) {
          if (mounted) setState(() {});
        }
      });
    }
  }

  Future<void> _loadPageMapping() async {
    try {
      final parsed = await PageMappingRepository.ensureLoaded();
      _pageMapping = parsed;
      _buildPagesFromMapping();
      if (currentPageIndex >= pages.length) {
        currentPageIndex = pages.isNotEmpty ? pages.length - 1 : 0;
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to load page mapping: $e');
    }
  }

  // Parsing handled centrally in PageMappingRepository.

  void _buildPagesFromMapping() {
    pages = [];
    pageStartSurahIds = [];
    if (_pageMapping.isEmpty) return;
    final maxPage = _pageMapping.keys.reduce((a, b) => a > b ? a : b);
    for (var p = 1; p <= maxPage; p++) {
      final entries = _pageMapping[p] ?? [];
      final pageVerses = <QuranVerse>[];
      int? startSurahId;
      for (var e in entries) {
        final suraNo = e['sura_no'] as int;
        final ayaNo = e['aya_no'] as int;
        if (startSurahId == null && ayaNo == 1) {
          startSurahId = suraNo;
        }
        final surah = widget.allSurahs.firstWhere(
          (s) => s.id == suraNo,
          orElse: () => QuranSurah(
            id: -1,
            name: '',
            transliteration: '',
            type: '',
            totalVerses: 0,
            verses: [],
          ),
        );
        if (surah.id == -1) continue;
        if (ayaNo <= 0 || ayaNo > surah.verses.length) continue;
        pageVerses.add(surah.verses[ayaNo - 1]);
      }
      pageStartSurahIds.add(startSurahId);
      pages.add(pageVerses);
    }
  }

  int _surahIndexForPage(int pageIndex) {
    if (pages.isEmpty || pageIndex < 0 || pageIndex >= pages.length) return 0;
    final first = pages[pageIndex].isNotEmpty ? pages[pageIndex].first : null;
    if (first == null) return 0;
    for (var i = 0; i < widget.allSurahs.length; i++) {
      if (widget.allSurahs[i].verses.isNotEmpty &&
          widget.allSurahs[i].verses.contains(first)) {
        return i;
      }
    }
    return 0;
  }

  int firstPageForSurah(int surahId) {
    for (var p = 0; p < pages.length; p++) {
      for (var v in pages[p]) {
        final surah = widget.allSurahs.firstWhere(
          (s) => s.verses.contains(v),
          orElse: () => QuranSurah(
            id: -1,
            name: '',
            transliteration: '',
            type: '',
            totalVerses: 0,
            verses: [],
          ),
        );
        if (surah.id == surahId) return p;
      }
    }
    return 0;
  }

  Future<void> _updateAndSave() async {
    widget.mushaf.currentSurahIndex = currentIndex;
    widget.mushaf.currentPageIndex = currentPageIndex;
    await MushafStorage.updateMushaf(widget.mushaf);
  }

  Future<void> goToPageNumber(int pageNumber) async {
    if (_pageMapping.isEmpty) await _loadPageMapping();
    if (pages.isEmpty) return;
    final idx = (pageNumber - 1).clamp(0, pages.length - 1);
    setState(() {
      currentPageIndex = idx;
      currentIndex = _surahIndexForPage(currentPageIndex);
    });
    try {
      await pageController.animateToPage(
        currentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      pageController = PageController(initialPage: currentPageIndex);
    }
    _updateAndSave();
  }

  Future<void> goToSurah(int surahId) async {
    if (_pageMapping.isEmpty) await _loadPageMapping();
    if (pages.isEmpty) return;
    final p = firstPageForSurah(surahId);
    await goToPageNumber(p + 1);
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.allSurahs[currentIndex];
    final media = MediaQuery.of(context);
    // slightly taller bottom bar for better tap/visibility
    const bottomBarHeight = 36.0;
    const navBarHeight = 100.0;
    // Removed manual availableHeight calculation

    // Even if pages aren't ready yet, render an instant, lightweight skeleton
    // that looks like a blank page to avoid any perceived delay.
    final bool pagesReady = pages.isNotEmpty;
    if (!pagesReady) {
      if (pageController.positions.isEmpty) {
        pageController = PageController(
          initialPage: currentPageIndex,
          viewportFraction: 1.0,
        );
      }
      return Scaffold(
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
              const SizedBox(height: 56),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    if (pageController.positions.isEmpty) {
      pageController = PageController(
        initialPage: currentPageIndex,
        viewportFraction: 1.0,
      );
    } else if (pageController.page != null &&
        pageController.page! >= pages.length) {
      pageController.dispose();
      pageController = PageController(
        initialPage: currentPageIndex,
        viewportFraction: 1.0,
      );
    }

    if (pages.isNotEmpty) {
      currentIndex = _surahIndexForPage(currentPageIndex);
    }

    // Removed prewarm sizing cache; mapping-based renderer handles layout directly.

    return Scaffold(
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
            Padding(
              padding: EdgeInsets.only(
                top: media.padding.top + 8,
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
                              // Flip the direction compared to previous behavior
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.allSurahs[currentIndex].name,
                      style: AppFonts.suraNameStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Tooltip(
                    message: 'حفظ العلامة',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        widget.mushaf.currentPageIndex = currentPageIndex;
                        widget.mushaf.currentSurahIndex = currentIndex;
                        await _updateAndSave();
                        if (mounted) {
                          setState(() {
                            _isSaved = true;
                          });
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Center(child: Text('تم حفظ العلامة')),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 30,
                          color: _isSaved
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView for paginated verses (pages are built across the whole mushaf)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return mushaf_view_widgets.VersesPageView(
                    pages: pages.cast<List<QuranVerse>>(),
                    controller: pageController,
                    onPageChanged: (p) => setState(() {
                      currentPageIndex = p;
                      currentIndex = _surahIndexForPage(p);
                      // update local saved indicator to reflect whether this page is the saved one
                      _isSaved =
                          widget.mushaf.currentPageIndex == currentPageIndex &&
                          widget.mushaf.currentSurahIndex == currentIndex;
                    }),
                    pageHeight: constraints.maxHeight,
                    pageStartSurahIds: pageStartSurahIds,
                    allSurahs: widget.allSurahs,
                    lineMappingByPageTokens: _lineMapping,
                  );
                },
              ),
            ),

            Center(
              child: Container(
                width: 200,
                // reduce bottom margin so it doesn't eat into content height
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 25),
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.08),
                ),
                alignment: Alignment.center,
                child: Text(
                  'صفحة ${QuranVerseNumbers.convertToArabicNumerals((currentPageIndex + 1).toString())} / ${QuranVerseNumbers.convertToArabicNumerals(pages.length.toString())}',
                  style: AppFonts.generalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
