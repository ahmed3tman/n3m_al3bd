import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jalees/core/share/widgets/custom_search_bar.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';
import 'package:jalees/features/quran/view/widgets/mushaf/widgets.dart'
    as mushaf_widgets;
import 'package:jalees/features/quran/view/widgets/surah/widgets.dart'
    as surah_widgets;
import '../../cubit/quran_cubit.dart';
import '../../cubit/quran_state.dart';
import '../screens/mushaf_screen.dart';
import '../../model/mushaf_model.dart';
import '../../model/quran_model.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String search = '';
  List<Mushaf> mushafs = [];

  @override
  void initState() {
    super.initState();
    _loadMushafs();
  }

  Future<void> _loadMushafs() async {
    mushafs = await MushafStorage.loadMushafs();
    setState(() {});
  }

  Future<void> _createMushafDialog(List surahs) async {
    final controller = TextEditingController(
      text: 'ختمة ${DateTime.now().month}',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('إضافة ختمة'),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(hintText: 'اسم المصحف'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      final m = await MushafStorage.addMushaf(name.trim());
      setState(() => mushafs.insert(0, m));
      // open immediately
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MushafScreen(mushaf: m, allSurahs: List<QuranSurah>.from(surahs)),
        ),
      ).then((_) => _loadMushafs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuranCubit()..loadQuran(),
      child: GradientScaffold(
        appBar: AppBar(title: const Text('القرآن الكريم')),
        body: Column(
          children: [
            // match hadith screen: top fixed search bar with default look
            CustomSearchBar(
              hintText: 'ابحث عن سورة...',
              onChanged: (val) => setState(() => search = val),
            ),
            // content scrolls under the search bar
            Expanded(
              child: BlocBuilder<QuranCubit, QuranState>(
                builder: (context, state) {
                  if (state is QuranLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is QuranError) {
                    return Center(child: Text('حدث خطأ: ${state.message}'));
                  } else if (state is QuranLoaded) {
                    final surahs = state.surahs
                        .where((s) => s.name.contains(search))
                        .toList();
                    if (surahs.isEmpty) {
                      return const Center(child: Text('لا توجد نتائج'));
                    }
                    // Single scrollable list where first item is horizontal mushaf
                    return ListView.builder(
                      itemCount: 1 + surahs.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return SizedBox(
                            height: 220,
                            child: FutureBuilder<List<Mushaf>>(
                              future: MushafStorage.loadMushafs(),
                              builder: (context, snap) {
                                final items = snap.data ?? <Mushaf>[];
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  itemCount: items.length + 1,
                                  itemBuilder: (context, idx) {
                                    if (idx == 0) {
                                      return mushaf_widgets.NewMushafCard(
                                        onTap: () async {
                                          final navigatorContext = context;
                                          final cubit = context
                                              .read<QuranCubit>();
                                          final localState = cubit.state;
                                          if (localState is QuranLoaded) {
                                            await _createMushafDialog(
                                              localState.surahs,
                                            );
                                          } else {
                                            await cubit.loadQuran();
                                            final s2 = cubit.state;
                                            if (!mounted) return;
                                            if (s2 is QuranLoaded) {
                                              await _createMushafDialog(
                                                s2.surahs,
                                              );
                                            }
                                          }
                                        },
                                      );
                                    }
                                    final m = items[idx - 1];
                                    return mushaf_widgets.MushafCard(
                                      mushaf: m,
                                      onTap: () async {
                                        final navigatorContext = context;
                                        final cubit = context
                                            .read<QuranCubit>();
                                        final state = cubit.state;
                                        if (state is QuranLoaded) {
                                          if (!mounted) return;
                                          Navigator.push(
                                            navigatorContext,
                                            MaterialPageRoute(
                                              builder: (_) => MushafScreen(
                                                mushaf: m,
                                                allSurahs:
                                                    List<QuranSurah>.from(
                                                      state.surahs,
                                                    ),
                                              ),
                                            ),
                                          ).then((_) => _loadMushafs());
                                        }
                                      },
                                      onDelete: () async {
                                        await MushafStorage.removeMushaf(m.id);
                                        setState(() {});
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return surah_widgets.SuraCard(sura: surahs[index - 1]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
