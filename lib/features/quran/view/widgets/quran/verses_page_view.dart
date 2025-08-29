import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/core/share/widgets/decorated_verse_number.dart';
import 'package:jalees/core/theme/app_fonts.dart';

/// Page view that shows pages of verses. Expects pages as a list of verse lists.
class VersesPageView extends StatelessWidget {
  final List<List<QuranVerse>> pages;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final double? pageHeight;

  const VersesPageView({
    super.key,
    required this.pages,
    required this.controller,
    required this.onPageChanged,
    this.pageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: pages.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, pageIndex) {
        final page = pages[pageIndex];

        // Build the page content to visually match the Surah ayat screen:
        // - Basmalah shown as a centered decorated line
        // - Ayat rendered inside a RichText with UnicodeDecoratedVerseNumber
        List<InlineSpan> spans = [];
        final List<Widget> segments = [];

        void flushSpans() {
          if (spans.isEmpty) return;
          segments.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: TextAlign.justify,
                textWidthBasis: TextWidthBasis.parent,
                text: TextSpan(
                  style: AppFonts.quranTextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  children: List<InlineSpan>.from(spans),
                ),
              ),
            ),
          );
          // No extra vertical spacing between text blocks to maximize page capacity
          spans.clear();
        }

        for (final verse in page) {
          if (verse.id == 0) {
            // Basmalah marker: flush accumulated ayat then add a centered basmalah line
            flushSpans();
            segments.add(
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: AppFonts.basmalahStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          } else {
            spans.add(TextSpan(text: verse.text));
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: UnicodeDecoratedVerseNumber(
                    verseNumber: verse.id,
                    fontSize: 30, // match Surah page visual size
                  ),
                ),
              ),
            );
            spans.add(const TextSpan(text: ' '));
          }
        }

        // Flush any remaining spans at end of page
        flushSpans();

        // Render a fixed-height page (no internal scroll). Parent provides available height.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SizedBox(
              height: pageHeight ?? MediaQuery.of(context).size.height,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: segments,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
