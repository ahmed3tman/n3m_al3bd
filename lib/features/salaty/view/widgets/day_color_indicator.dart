import 'package:flutter/material.dart';
import '../../data/models/prayer_times_model.dart';

class DayColorIndicator extends StatelessWidget {
  final DayColor color;
  final int completedCount;
  final int totalCount;
  final bool isCompact;

  const DayColorIndicator({
    super.key,
    required this.color,
    required this.completedCount,
    required this.totalCount,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _getColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getColor().withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$completedCount/$totalCount',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: _getColor(),
                fontFamily: 'NeoSansArabic',
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor().withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$completedCount/$totalCount',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: _getColor(),
              fontFamily: 'NeoSansArabic',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (color) {
      case DayColor.green:
        return Colors.green;
      case DayColor.yellow:
        return Colors.orange;
      case DayColor.red:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (color) {
      case DayColor.green:
        return 'ممتاز';
      case DayColor.yellow:
        return 'جيد';
      case DayColor.red:
        return 'يحتاج تحسين';
    }
  }
}
