import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';

class JadwaliScreen extends StatefulWidget {
  const JadwaliScreen({super.key});

  @override
  State<JadwaliScreen> createState() => _JadwaliScreenState();
}

class _JadwaliScreenState extends State<JadwaliScreen> {
  // Data model: list of tables. Each table is a map with name, rows, cols and cells (2D list)
  List<Map<String, dynamic>> _tables = [];
  bool _loading = true;

  static const String _prefsKey = 'jadwal_tables_v1';

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      // Initialize with a default empty table
      _tables = [
        {
          'name': 'الجدول 1',
          'rows': 7,
          'cols': 5,
          'cells': List.generate(7, (_) => List.generate(5, (_) => '')),
        },
      ];
      await _saveTables();
    } else {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _tables = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        // Normalise cells to proper List<List<String>> if needed
        for (var t in _tables) {
          if (t['cells'] is List) {
            t['cells'] = (t['cells'] as List)
                .map((r) => List<String>.from(r as List))
                .toList();
          }
        }
      } catch (_) {
        _tables = [];
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveTables() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_tables));
  }

  Future<void> _createTableDialog() async {
    final nameCtrl = TextEditingController(
      text: 'الجدول ${_tables.length + 1}',
    );
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
                final table = {
                  'name': name.isEmpty ? 'الجدول ${_tables.length + 1}' : name,
                  'rows': rows,
                  'cols': cols,
                  'cells': List.generate(
                    rows,
                    (_) => List.generate(cols, (_) => ''),
                  ),
                };
                setState(() => _tables.add(table));
                _saveTables();
                Navigator.pop(ctx);
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCell(int tableIndex, int row, int col) async {
    final current = _tables[tableIndex]['cells'][row][col] as String? ?? '';
    final ctrl = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل الخانة'),
          content: TextField(
            controller: ctrl,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(hintText: 'اكتب هنا...'),
            autofocus: true,
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tables[tableIndex]['cells'][row][col] = ctrl.text;
                });
                _saveTables();
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameTable(int index) async {
    final ctrl = TextEditingController(text: _tables[index]['name'] as String);
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
                setState(() => _tables[index]['name'] = ctrl.text);
                _saveTables();
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTable(int index) async {
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
    if (confirmed) {
      setState(() => _tables.removeAt(index));
      _saveTables();
    }
  }

  void _addRow(int index) {
    setState(() {
      final table = _tables[index];
      final cols = table['cols'] as int;
      // ensure cells is a List<List<String>>
      final cells = table['cells'] as List;
      cells.add(List.generate(cols, (_) => ''));
      table['rows'] = (table['rows'] as int) + 1;
    });
    _saveTables();
  }
  // _addColumn removed — only add-row functionality is kept.

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('جدولي'),
        actions: [
          IconButton(
            onPressed: _createTableDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tables.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'لا توجد جداول بعد',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _createTableDialog,
                      child: const Text('إنشاء جدول'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _tables.length,
                itemBuilder: (context, tableIndex) {
                  final table = _tables[tableIndex];
                  final rows = table['rows'] as int;
                  final cols = table['cols'] as int;
                  final cells = table['cells'] as List<dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                table['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'أضف صف',
                                    onPressed: () => _addRow(tableIndex),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  IconButton(
                                    onPressed: () => _renameTable(tableIndex),
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteTable(tableIndex),
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              defaultColumnWidth: const IntrinsicColumnWidth(),
                              border: TableBorder.all(
                                color: Colors.grey.shade700,
                              ),
                              children: List.generate(rows, (r) {
                                return TableRow(
                                  children: List.generate(cols, (c) {
                                    final text =
                                        (cells[r] as List)[c] as String;
                                    return GestureDetector(
                                      onTap: () => _editCell(tableIndex, r, c),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 80,
                                          minHeight: 48,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        color: Colors.transparent,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            text.isEmpty
                                                ? 'اضغط للتعديل'
                                                : text,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: text.isEmpty
                                                  ? Colors.grey
                                                  : DefaultTextStyle.of(
                                                          context,
                                                        ).style.color ??
                                                        Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
