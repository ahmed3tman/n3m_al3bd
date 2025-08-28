import 'package:flutter/material.dart';
import '../../model/quran_model.dart';
import '../../model/mushaf_model.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/share/widgets/decorated_verse_number.dart';

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
  late List<List> pages;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.mushaf.currentSurahIndex;
    currentPageIndex = widget.mushaf.currentPageIndex;
    pageController = PageController(initialPage: currentPageIndex);
    _buildPages();
  }

  void _buildPages() {
    final surah = widget.allSurahs[currentIndex];
    const versesPerPage = 7;
    pages = [];
    for (var i = 0; i < surah.verses.length; i += versesPerPage) {
      final end = (i + versesPerPage < surah.verses.length)
          ? i + versesPerPage
          : surah.verses.length;
      pages.add(surah.verses.sublist(i, end));
    }
    if (currentPageIndex >= pages.length) currentPageIndex = pages.length - 1;
  }

  void _updateAndSave() async {
    widget.mushaf.currentSurahIndex = currentIndex;
    widget.mushaf.currentPageIndex = currentPageIndex;
    await MushafStorage.updateMushaf(widget.mushaf);
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.allSurahs[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mushaf.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
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
          // PageView for paginated verses
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Center(
                    child: Text(
                      surah.name,
                      textAlign: TextAlign.center,
                      style: AppFonts.suraNameStyle(
                        fontSize: 26,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (surah.id != 1 && surah.id != 9)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: AppFonts.basmalahStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: pages.length,
                    onPageChanged: (p) {
                      setState(() => currentPageIndex = p);
                    },
                    itemBuilder: (context, pageIndex) {
                      final page = pages[pageIndex];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final verse in page) ...[
                                RichText(
                                  textAlign: TextAlign.justify,
                                  text: TextSpan(
                                    style: AppFonts.quranTextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                    ),
                                    children: [
                                      TextSpan(text: verse.text),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: UnicodeDecoratedVerseNumber(
                                            verseNumber: verse.id,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('صفحة ${currentPageIndex + 1} / ${pages.length}'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.navigate_before),
                  onPressed: currentIndex > 0
                      ? () => setState(() {
                          currentIndex--;
                          currentPageIndex = 0;
                          pageController.dispose();
                          pageController = PageController(initialPage: 0);
                          _buildPages();
                        })
                      : null,
                ),
                Text('${currentIndex + 1} / ${widget.allSurahs.length}'),
                IconButton(
                  icon: const Icon(Icons.navigate_next),
                  onPressed: currentIndex < widget.allSurahs.length - 1
                      ? () => setState(() {
                          currentIndex++;
                          currentPageIndex = 0;
                          pageController.dispose();
                          pageController = PageController(initialPage: 0);
                          _buildPages();
                        })
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
