import 'package:flutter/material.dart';
import 'package:n3m_al3bd/features/quran/model/mushaf_model.dart';

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
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: SizedBox(
            width: 120,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          const SizedBox(height: 45),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'سورة: ${mushaf.currentSurahIndex + 1}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withOpacity(isDark ? 0.1 : 0.6),
              width: 1.5,
            ),
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
