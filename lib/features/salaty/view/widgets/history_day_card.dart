import 'package:flutter/material.dart';
import '../../data/models/daily_task_list_model.dart';
import '../../data/models/prayer_times_model.dart';
import '../../../../core/utils/number_converter.dart';

class HistoryDayCard extends StatelessWidget {
  final DailyTaskList day;

  const HistoryDayCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = day.isComplete;
    final prayerCount = day.completedCount;
    final totalPrayers = day.totalCount;
    final wirdPages = day.wirdScore;
    final dayColor = _getColor(day.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored Strip Indicator
              Container(width: 6, color: dayColor),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Date and Islamic Phrase
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(day.date),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: dayColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getIslamicPhrase(day.color),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: dayColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Stats Row (Compact)
                      Row(
                        children: [
                          _buildCompactStat(
                            context,
                            Icons.mosque_outlined,
                            '$prayerCount صلوات'.toArabicNumbers,
                            theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          _buildCompactStat(
                            context,
                            Icons.menu_book_rounded,
                            wirdPages > 0
                                ? '$wirdPages صفحة'.toArabicNumbers
                                : 'لا يوجد ورد',
                            theme.colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Color _getColor(DayColor dayColor) {
    switch (dayColor) {
      case DayColor.green:
        return const Color.fromARGB(164, 76, 175, 79);
      case DayColor.yellow:
        return const Color.fromARGB(181, 255, 153, 0);
      case DayColor.red:
        return const Color.fromARGB(180, 244, 67, 54);
    }
  }

  String _getIslamicPhrase(DayColor dayColor) {
    switch (dayColor) {
      case DayColor.green:
        return 'اللهم ثبّتني على طاعتك';
      case DayColor.yellow:
        return 'اللهم أعني على التقوى';
      case DayColor.red:
        return 'اللهم قوِّ عزيمتي';
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday، ${date.day} $month ${date.year}'.toArabicNumbers;
  }
}
