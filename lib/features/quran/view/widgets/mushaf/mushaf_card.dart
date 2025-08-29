import 'package:flutter/material.dart';
import 'package:jalees/features/quran/model/mushaf_model.dart';

/// Unified Mushaf card file combining existing MushafCard and NewMushafCard
/// - MushafCard: rich visual with background image, gradient overlay, centered Arabic title, and delete button
/// - NewMushafCard: simple add-card variant (Arabic label)

class MushafCard extends StatelessWidget {
  final Mushaf mushaf;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MushafCard({
    super.key,
    required this.mushaf,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 120,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Background image from assets
                  Positioned.fill(
                    child: Image.asset('assets/mushaf.jpeg', fit: BoxFit.cover),
                  ),

                  // Subtle gradient to improve text contrast
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Centered content overlay (texts)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            mushaf.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontFamily: 'UthmanicHafs',
                                  color: Colors.white,
                                  fontSize: 20,
                                  shadows: [
                                    const Shadow(
                                      blurRadius: 4,
                                      color: Colors.black45,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 35),
                          Text(
                            'سورة: ${mushaf.currentSurahIndex + 1}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Prominent delete button at bottom-left
                  Positioned(
                    bottom: 7,
                    left: 5,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 29,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 20,
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
    );
  }
}

class NewMushafCard extends StatelessWidget {
  final VoidCallback? onTap;

  const NewMushafCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 120,
            height: 200,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                SizedBox(height: 8),
                Text('ختمة جديدة'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
