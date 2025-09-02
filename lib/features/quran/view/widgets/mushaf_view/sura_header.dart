import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/quran_model.dart';
import 'package:jalees/core/theme/app_fonts.dart';

/// Header that shows the surah name and optional basmalah.
class SuraHeader extends StatelessWidget {
  final QuranSurah surah;

  const SuraHeader({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            child: Text(
              surah.name,
              textAlign: TextAlign.center,
              style: AppFonts.suraNameStyle(
                fontSize: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        if (surah.id != 1 && surah.id != 9)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '﷽',
              textAlign: TextAlign.center,
              style: AppFonts.basmalahStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
