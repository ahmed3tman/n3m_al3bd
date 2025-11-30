import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import '../../cubit/salaty_cubit.dart';
import '../../cubit/salaty_state.dart';
import '../widgets/history_day_card.dart';
import '../../../../core/utils/number_converter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen opens
    context.read<SalatyCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('السجل'), centerTitle: true),
      body: BlocBuilder<SalatyCubit, SalatyState>(
        builder: (context, state) {
          if (state.status == SalatyStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد سجل بعد',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بإكمال مهامك اليومية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: CustomScrollView(
              slivers: [
                // Header with stats
                SliverToBoxAdapter(child: _buildStatsHeader(context, state)),

                // History List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final day = state.history[index];
                      return GestureDetector(
                        onTap: () => _showDayDetails(context, day),
                        child: HistoryDayCard(day: day),
                      );
                    }, childCount: state.history.length),
                  ),
                ),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, SalatyState state) {
    final theme = Theme.of(context);
    final totalDays = state.history.length;

    // Calculate Total Wird Pages
    final totalWirdPages = state.history.fold<int>(
      0,
      (sum, day) => sum + day.wirdScore,
    );

    // Calculate Average Score
    double totalScore = 0;
    for (final day in state.history) {
      final prayerScore = day.totalCount > 0
          ? day.completedCount / day.totalCount
          : 0.0;
      final wirdScore = day.wirdScore * 0.01; // 1% per page
      totalScore += (prayerScore + wirdScore);
    }

    final avgScore = totalDays > 0 ? (totalScore / totalDays * 100).toInt() : 0;

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
                children: [
                  // Verse Section
                  Container(
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
                    child: Column(
                      children: [
                        Text(
                          'وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'UthmanicHafs',
                            fontSize: 20,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildModernStatItem(
                        context,
                        'إجمالي الأيام',
                        totalDays.toString().toArabicNumbers,
                        Icons.calendar_today_rounded,
                        Colors.blue.shade700,
                      ),
                      _buildModernStatItem(
                        context,
                        'صفحات الورد',
                        totalWirdPages.toString().toArabicNumbers,
                        Icons.menu_book_rounded,
                        Colors.green.shade600,
                      ),
                      _buildModernStatItem(
                        context,
                        'متوسط الإنجاز',
                        '$avgScore%'.toArabicNumbers,
                        Icons.trending_up_rounded,
                        Colors.orange.shade700,
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

  Widget _buildModernStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, day) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تفاصيل ${_formatDate(day.date)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...day.tasks.map<Widget>((task) {
                if (!task.isPrayer) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: task.wirdAmount > 0
                              ? const Color.fromARGB(255, 98, 199, 102)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${task.nameAr}: ${task.wirdAmount} صفحة'
                              .toArabicNumbers,
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted ? Icons.check_circle : Icons.cancel,
                        color: task.isCompleted ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(task.nameAr),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}'.toArabicNumbers;
  }
}
