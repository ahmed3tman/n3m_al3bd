// import 'package:flutter/material.dart';

// class JadwaliScreen extends StatelessWidget {
//   const JadwaliScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('جدولي'),
//       ),
//       body: const Center(
//         child: Text(
//           'جدولي',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }









import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jalees/core/share/widgets/gradient_background.dart';

import '../../data/jadwal_model.dart';
import '../../cubit/jadwal_cubit.dart';
import '../../cubit/jadwal_state.dart';
import '../widgets/jadwal_card.dart';
import 'jadwal_detail_screen.dart';

class JadwaliScreen extends StatefulWidget {
  const JadwaliScreen({super.key});

  @override
  State<JadwaliScreen> createState() => _JadwaliScreenState();
}

class _JadwaliScreenState extends State<JadwaliScreen> {
  late final JadwalCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = JadwalCubit();
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _createTableDialog(BuildContext context, int existCount) async {
    final nameCtrl = TextEditingController(text: 'الجدول ${existCount + 1}');
    final rowsCtrl = TextEditingController(text: '7');
    final colsCtrl = TextEditingController(text: '5');

    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إنشاء جدول جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'اسم الجدول'),
              ),
              TextField(
                controller: rowsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'عدد الصفوف'),
              ),
              TextField(
                controller: colsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'عدد الأعمدة'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final rows = int.tryParse(rowsCtrl.text) ?? 7;
                final cols = int.tryParse(colsCtrl.text) ?? 5;
                final model = JadwalModel.empty(
                  name.isEmpty ? 'الجدول ${existCount + 1}' : name,
                  rows,
                  cols,
                );
                _cubit.addTable(model);
                Navigator.pop(ctx);
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameDialog(
    BuildContext context,
    int index,
    String current,
  ) async {
    final ctrl = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل اسم الجدول'),
          content: TextField(controller: ctrl, textAlign: TextAlign.right),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _cubit.renameTable(index, ctrl.text);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('حذف الجدول'),
              content: const Text('هل أنت متأكد من حذف هذا الجدول؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('حذف'),
                ),
              ],
            ),
          ),
        ) ??
        false;
    if (confirmed) _cubit.deleteTable(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text('جدولي'),
          actions: [
            BlocBuilder<JadwalCubit, JadwalState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () =>
                      _createTableDialog(context, state.tables.length),
                  icon: const Icon(Icons.add),
                );
              },
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                // small subtle gradient for depth
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface.withOpacity(0.01),
                    Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BlocBuilder<JadwalCubit, JadwalState>(
                builder: (context, state) {
                  if (state.status == JadwalStatus.loading ||
                      state.status == JadwalStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.tables.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'لا توجد جداول بعد',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _createTableDialog(context, 0),
                            child: const Text('إنشاء جدول'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.tables.length,
                    itemBuilder: (context, i) {
                      final model = state.tables[i];
                      return JadwalCard(
                        model: model,
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (routeCtx) => BlocProvider.value(
                                value: _cubit,
                                child: JadwalDetailScreen(
                                  model: model,
                                  index: i,
                                  onEditCell: (r, c, v) =>
                                      _cubit.editCell(i, r, c, v),
                                  onAddRow: () => _cubit.addRow(i),
                                  onAddRowAt: (at) => _cubit.addRowAt(i, at),
                                  onDeleteRow: (r) => _cubit.deleteRow(i, r),
                                  onAddColumnAt: (c) => _cubit.addColumn(i, c),
                                  onDeleteColumn: (c) =>
                                      _cubit.deleteColumn(i, c),
                                ),
                              ),
                            ),
                          );
                        },
                        onRename: () => _renameDialog(context, i, model.name),
                        onDelete: () => _confirmDelete(context, i),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
