import 'package:flutter/material.dart';

/// Bottom controls for navigating between surahs.
class SurahNavigationControls extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const SurahNavigationControls({
    super.key,
    required this.currentIndex,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: onPrev,
          ),
          Text('${currentIndex + 1} / $total'),
          IconButton(icon: const Icon(Icons.navigate_next), onPressed: onNext),
        ],
      ),
    );
  }
}
