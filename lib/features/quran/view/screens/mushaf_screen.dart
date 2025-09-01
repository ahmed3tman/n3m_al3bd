import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jalees/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import '../../model/quran_model.dart';
import '../../model/mushaf_model.dart';
import 'package:jalees/features/quran/view/widgets/mushaf_view/widgets.dart'
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
  late List<int?> pageStartSurahIds;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.mushaf.currentSurahIndex;
    currentPageIndex = widget.mushaf.currentPageIndex;
    pageController = PageController(initialPage: currentPageIndex);
    _pageMapping = {};
    pages = [];
    _isSaved =
        widget.mushaf.currentPageIndex == currentPageIndex &&
        widget.mushaf.currentSurahIndex == currentIndex;
    _loadPageMapping();
  }

  Future<void> _loadPageMapping() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/json/quran_page_mapping.json',
      );
      final Map<String, dynamic> decoded = jsonDecode(raw);
      _pageMapping = decoded.map(
        (k, v) => MapEntry(int.parse(k), List<Map<String, dynamic>>.from(v)),
      );
      _buildPagesFromMapping();
      // ensure currentPageIndex in range
      if (currentPageIndex >= pages.length) {
        currentPageIndex = pages.length - 1;
      }
      setState(() {});
    } catch (e) {
      debugPrint('Failed to load page mapping: $e');
    }
  }

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
    const bottomBarHeight = 30.0;
    const navBarHeight = 100.0;
    final availableHeight =
        media.size.height -
        media.padding.top -
        bottomBarHeight -
        navBarHeight -
        8;
    const estimatedVerseHeight = 84.0;
    final versesPerPage = (availableHeight / estimatedVerseHeight)
        .floor()
        .clamp(4, 30);

    if (pages.isEmpty) {
      if (pageController.positions.isEmpty) {
        pageController = PageController(initialPage: currentPageIndex);
      }
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (pageController.positions.isEmpty) {
      pageController = PageController(initialPage: currentPageIndex);
    } else if (pageController.page != null &&
        pageController.page! >= pages.length) {
      pageController.dispose();
      pageController = PageController(initialPage: currentPageIndex);
    }

    if (pages.isNotEmpty) {
      currentIndex = _surahIndexForPage(currentPageIndex);
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
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
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
                              size: 18,
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
                        fontSize: 30,
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
                            const SnackBar(content: Text('تم حفظ العلامة')),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 26,
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
              child: mushaf_view_widgets.VersesPageView(
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
                pageHeight: availableHeight,
                pageStartSurahIds: pageStartSurahIds,
                allSurahs: widget.allSurahs,
              ),
            ),
            SizedBox(
              height: bottomBarHeight,
              child: Text(
                'صفحة ${currentPageIndex + 1} / ${pages.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
