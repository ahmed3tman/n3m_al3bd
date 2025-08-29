import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/features/quran/view/widgets/quran/verse_row.dart';

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
        // Render a fixed-height page (no internal scroll). Parent provides available height.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SizedBox(
              height: pageHeight ?? MediaQuery.of(context).size.height,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                // distribute verses to fill available vertical space and avoid trailing blank areas
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final verse in page) VerseRow(verse: verse)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
