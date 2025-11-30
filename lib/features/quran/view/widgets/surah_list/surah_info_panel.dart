import 'package:flutter/material.dart';
import 'package:jalees/core/theme/app_fonts.dart';

class SurahInfoPanel extends StatelessWidget {
  final String versesCount;
  final String type;
  final String surahNumber;

  const SurahInfoPanel({
    super.key,
    required this.versesCount,
    required this.type,
    required this.surahNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _infoColumn(context, 'عدد الآيات', versesCount),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          _infoColumn(context, 'النوع', type),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          _infoColumn(context, 'رقم السورة', surahNumber),
        ],
      ),
    );
  }

  Widget _infoColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFonts.captionStyle(
            fontSize: 12,
            color: AppFonts.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppFonts.generalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
