import 'package:flutter/material.dart';
import '../../model/quran_model.dart';
import '../../model/mushaf_model.dart';
import 'package:jalees/features/quran/view/widgets/quran/widgets.dart'
    as quran_widgets;

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
  late List<int>
  _surahStartPositions; // cumulative mapping from verse index -> surah

  @override
  void initState() {
    super.initState();
    currentIndex = widget.mushaf.currentSurahIndex;
    currentPageIndex = widget.mushaf.currentPageIndex;
    pageController = PageController(initialPage: currentPageIndex);
    _surahStartPositions = [];
    // pages will be built in build() because it depends on screen size
  }

  /// Build continuous pages across the entire mushaf.
  void _buildPages(int versesPerPage) {
    final allVerses = <QuranVerse>[];
    _surahStartPositions = [];
    for (var s = 0; s < widget.allSurahs.length; s++) {
      final surah = widget.allSurahs[s];
      // record the start position (index) of this surah in the flat verses list
      _surahStartPositions.add(allVerses.length);
      // add basmalah at the start of the surah if required
      if (surah.id != 1 && surah.id != 9) {
        allVerses.add(
          QuranVerse(id: 0, text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
        );
      }
      allVerses.addAll(surah.verses);
    }

    pages = [];
    for (var i = 0; i < allVerses.length; i += versesPerPage) {
      final end = (i + versesPerPage < allVerses.length)
          ? i + versesPerPage
          : allVerses.length;
      pages.add(allVerses.sublist(i, end));
    }

    if (currentPageIndex >= pages.length) {
      currentPageIndex = pages.length - 1;
    }
  }

  // find current surah index based on flat verse index (index of first verse in page)
  int _surahIndexForPage(int pageIndex, int versesPerPage) {
    final firstVerseGlobalIndex = pageIndex * versesPerPage;
    // find largest surahStartPositions[i] <= firstVerseGlobalIndex
    var idx = 0;
    for (var i = 0; i < _surahStartPositions.length; i++) {
      if (_surahStartPositions[i] <= firstVerseGlobalIndex) {
        idx = i;
      } else {
        break;
      }
    }
    return idx.clamp(0, widget.allSurahs.length - 1);
  }

  void _updateAndSave() async {
    widget.mushaf.currentSurahIndex = currentIndex;
    widget.mushaf.currentPageIndex = currentPageIndex;
    await MushafStorage.updateMushaf(widget.mushaf);
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.allSurahs[currentIndex];
    // compute available height to decide verses per page
    final media = MediaQuery.of(context);
    const bottomBarHeight = 56.0;
    const topBarHeight = 44.0; // smaller app bar per user request
    final availableHeight =
        media.size.height -
        media.padding.top -
        topBarHeight -
        bottomBarHeight -
        24;
    // estimate verse height (approx)
    const estimatedVerseHeight = 72.0;
    final versesPerPage = (availableHeight / estimatedVerseHeight)
        .floor()
        .clamp(4, 30);

    _buildPages(versesPerPage);

    // ensure pageController position valid
    if (pageController.positions.isEmpty) {
      pageController = PageController(initialPage: currentPageIndex);
    } else if (pageController.page != null &&
        pageController.page! >= pages.length) {
      pageController.dispose();
      pageController = PageController(initialPage: currentPageIndex);
    }

    // derive current surah based on currentPageIndex
    if (_surahStartPositions.isNotEmpty) {
      currentIndex = _surahIndexForPage(currentPageIndex, versesPerPage);
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: topBarHeight,
        title: Text(
          widget.allSurahs[currentIndex].name,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // save current page and surah
              widget.mushaf.currentPageIndex = currentPageIndex;
              widget.mushaf.currentSurahIndex = currentIndex;
              _updateAndSave();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم حفظ العلامة')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // PageView for paginated verses (pages are built across the whole mushaf)
          Expanded(
            child: quran_widgets.VersesPageView(
              pages: pages.cast<List<QuranVerse>>(),
              controller: pageController,
              onPageChanged: (p) => setState(() {
                currentPageIndex = p;
                currentIndex = _surahIndexForPage(p, versesPerPage);
              }),
              pageHeight: availableHeight,
            ),
          ),
          // small page index at the bottom (single line)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'صفحة ${currentPageIndex + 1} / ${pages.length}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
