import 'package:flutter/material.dart';
import '../../data/models/prayer_times_model.dart';
import '../../../../core/utils/number_converter.dart';

class PrayerTimesWidget extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final String? nextPrayer;

  const PrayerTimesWidget({
    super.key,
    required this.prayerTimes,
    this.nextPrayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(
            theme.brightness == Brightness.dark ? 0.1 : 0.6,
          ),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_filled_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'مواقيت الصلاة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'GeneralFont',
                        fontSize: 14,
                      ),
                    ),
                    if (prayerTimes.locationName != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '- ${prayerTimes.locationName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                            fontFamily: 'GeneralFont',
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPrayerTimeRow(
            context,
            'الفجر',
            prayerTimes.fajr,
            isNext: nextPrayer == 'fajr',
          ),
          const SizedBox(height: 12),
          _buildPrayerTimeRow(
            context,
            'الظهر',
            prayerTimes.dhuhr,
            isNext: nextPrayer == 'dhuhr',
          ),
          const SizedBox(height: 12),
          _buildPrayerTimeRow(
            context,
            'العصر',
            prayerTimes.asr,
            isNext: nextPrayer == 'asr',
          ),
          const SizedBox(height: 12),
          _buildPrayerTimeRow(
            context,
            'المغرب',
            prayerTimes.maghrib,
            isNext: nextPrayer == 'maghrib',
          ),
          const SizedBox(height: 12),
          _buildPrayerTimeRow(
            context,
            'العشاء',
            prayerTimes.isha,
            isNext: nextPrayer == 'isha',
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(
    BuildContext context,
    String name,
    DateTime time, {
    bool isNext = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
            : theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              )
            : Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isNext)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                  ),
                Flexible(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isNext ? FontWeight.w400 : FontWeight.normal,
                      color: isNext ? theme.colorScheme.primary : null,
                      fontFamily: 'GeneralFont',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(time),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isNext ? FontWeight.w400 : FontWeight.normal,
              color: isNext ? theme.colorScheme.primary : null,
              fontFamily: 'GeneralFont',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period'.toArabicNumbers;
  }
}
