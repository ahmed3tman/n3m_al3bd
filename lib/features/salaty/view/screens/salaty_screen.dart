import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/core/share/widgets/gradient_background.dart';
import '../../cubit/salaty_cubit.dart';
import '../../cubit/salaty_state.dart';
import '../../../../core/share/widgets/custom_drawer.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/prayer_times_widget.dart';
import '../widgets/wird_input_dialog.dart';
import '../widgets/salaty_header.dart';
import '../../../../core/share/widgets/custom_edge_button.dart';
import 'history_screen.dart';

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
          leadingWidth: 70, // Give enough space for the tab
          leading: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
            ), // Remove horizontal padding to touch edge
            child: CustomEdgeButton(
              onTap: () {
                OpenDrawerNotification().dispatch(context);
              },
              icon: Icons.menu_rounded,
              isLeading: true,
            ),
          ),
          title: Image.asset('assets/logo.PNG', height: 70),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
              ), // Remove horizontal padding to touch edge
              child: CustomEdgeButton(
                onTap: () {
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
                icon: Icons.history,
                isLeading: false,
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
                  SliverToBoxAdapter(child: SalatyHeader(state: state)),

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
                              content: Center(
                                child: Text('تم اضافة انجاز اليوم الي السجل'),
                              ),
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
}
