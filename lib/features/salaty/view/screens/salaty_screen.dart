import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import '../../cubit/salaty_cubit.dart';
import '../../cubit/salaty_state.dart';
import '../../data/models/prayer_times_model.dart';

import '../widgets/task_item_widget.dart';
import '../widgets/prayer_times_widget.dart';
import '../widgets/day_color_indicator.dart';
import '../widgets/wird_input_dialog.dart';
import 'history_screen.dart';
import '../../../../core/utils/number_converter.dart';

class SalatyScreen extends StatefulWidget {
  const SalatyScreen({super.key});

  @override
  State<SalatyScreen> createState() => _SalatyScreenState();
}

class _SalatyScreenState extends State<SalatyScreen> {
  late final SalatyCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SalatyCubit();
    _cubit.initialize();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: GradientScaffold(
        appBar: AppBar(
          title: Image.asset('assets/logo.PNG', height: 70),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 8,
                top: 8,
                bottom: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.history),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'السجل',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (routeContext) => BlocProvider.value(
                          value: _cubit,
                          child: const HistoryScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<SalatyCubit, SalatyState>(
          builder: (context, state) {
            if (state.status == SalatyStatus.loading ||
                state.status == SalatyStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SalatyStatus.failure) {
              return Center(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error ?? 'خطأ غير معروف',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _cubit.initialize(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.currentDay == null) {
              return const Center(child: Text('لا توجد بيانات'));
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
                slivers: [
                  // Header with date and progress
                  SliverToBoxAdapter(child: _buildHeader(context, state)),

                  // Tasks List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: state.currentDay!.tasks
                            .map(
                              (task) => TaskItemWidget(
                                task: task,
                                onToggle: () {
                                  if (task.isPrayer) {
                                    _cubit.toggleTask(task.id);
                                  } else {
                                    _showWirdDialog(context, task.wirdAmount);
                                  }
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  // Save Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _cubit.saveCurrentDayToHistory();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Center(child: Text('تم اضافة انجاز اليوم الي السجل')),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'حفظ الإنجاز في السجل',
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Prayer Times Widget
                  if (state.todayPrayerTimes != null)
                    SliverToBoxAdapter(
                      child: PrayerTimesWidget(
                        prayerTimes: state.todayPrayerTimes!,
                        nextPrayer: state.nextPrayer,
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SalatyState state) {
    final theme = Theme.of(context);
    final currentDay = state.currentDay!;

    // Calculate progress
    // Base: 5 prayers = 100%
    // Wird: Each page adds 1% (or user defined logic, here assuming 1 page = 1%)
    // But user said "1005%" if read page. Maybe they meant 100% + 5%?
    // Let's assume 1 page = 1% for now to be safe, or maybe 5% per page?
    // User said "1005 مثلا اذا قرأ صفحة". 1005 seems like a typo for 105 or 100.5.
    // Let's assume 1 page = 5% extra.

    final prayerProgress =
        currentDay.completedCount / currentDay.totalCount; // 0.0 to 1.0
    final wirdProgress = currentDay.wirdScore * 0.01; // 1% per page
    final totalProgress = prayerProgress + wirdProgress;
    final percentage = (totalProgress * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quranic Verse
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'مَا يَلْفِظُ مِن قَوْلٍ إِلَّا لَدَيْهِ رَقِيبٌ عَتِيدٌ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'UthmanicHafs',
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'اليوم',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          DayColorIndicator(
                            color: currentDay.color,
                            completedCount: currentDay.completedCount,
                            totalCount: currentDay.totalCount,
                            isCompact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _formatDate(currentDay.date),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التقدم اليومي',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '$percentage%'.toArabicNumbers,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: _getProgressColor(currentDay.color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: totalProgress > 1.0 ? 1.0 : totalProgress,
                          minHeight: 16, // زيادة السمك
                          backgroundColor: theme.colorScheme.onSurface
                              .withOpacity(0.2), // جعل الخط الخلفي أكثر وضوحاً
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(currentDay.color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWirdDialog(BuildContext context, int currentAmount) {
    showDialog(
      context: context,
      builder: (context) => WirdInputDialog(
        currentAmount: currentAmount,
        onSave: (amount) {
          _cubit.updateWirdAmount(amount);
        },
      ),
    );
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

    return '$weekday، ${date.day} $month'.toArabicNumbers;
  }

  Color _getProgressColor(color) {
    switch (color) {
      case DayColor.green:
        return const Color.fromARGB(181, 76, 175, 79);
      case DayColor.yellow:
        return const Color.fromARGB(175, 255, 153, 0);
      case DayColor.red:
        return const Color.fromARGB(184, 244, 67, 54);
      default:
        return Colors.grey;
    }
  }
}
