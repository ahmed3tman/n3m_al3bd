import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/jadwal_model.dart';
import 'jadwal_state.dart';

class JadwalCubit extends Cubit<JadwalState> {
  static const String _prefsKey = 'jadwal_tables_v1';
  JadwalCubit() : super(const JadwalState());

  Future<void> load() async {
    emit(state.copyWith(status: JadwalStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) {
        final initial = [JadwalModel.empty('الجدول 1', 7, 5)];
        await prefs.setString(
          _prefsKey,
          jsonEncode(initial.map((e) => e.toMap()).toList()),
        );
        emit(state.copyWith(status: JadwalStatus.success, tables: initial));
        return;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      final tables = decoded
          .map((e) => JadwalModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      emit(state.copyWith(status: JadwalStatus.success, tables: tables));
    } catch (e) {
      emit(state.copyWith(status: JadwalStatus.failure, error: e.toString()));
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.tables.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> addTable(JadwalModel model) async {
    final newList = List<JadwalModel>.from(state.tables)..add(model);
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> renameTable(int index, String newName) async {
    final newList = List<JadwalModel>.from(state.tables);
    newList[index].name = newName;
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> deleteTable(int index) async {
    final newList = List<JadwalModel>.from(state.tables)..removeAt(index);
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> addRow(int index) async {
    final newList = List<JadwalModel>.from(state.tables);
    final table = newList[index];
    table.cells.add(List.generate(table.cols, (_) => ''));
    table.rows += 1;
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> addRowAt(int tableIndex, int atIndex) async {
    final newList = List<JadwalModel>.from(state.tables);
    final table = newList[tableIndex];
    final cols = table.cols;
    table.cells.insert(atIndex, List.generate(cols, (_) => ''));
    table.rows += 1;
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> deleteRow(int tableIndex, int rowIndex) async {
    final newList = List<JadwalModel>.from(state.tables);
    final table = newList[tableIndex];
    if (table.rows <= 1) return; // keep at least one row
    table.cells.removeAt(rowIndex);
    table.rows -= 1;
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> addColumn(int tableIndex, int atIndex) async {
    final newList = List<JadwalModel>.from(state.tables);
    final table = newList[tableIndex];
    for (var r = 0; r < table.rows; r++) {
      (table.cells[r] as List).insert(atIndex, '');
    }
    table.cols += 1;
    emit(state.copyWith(tables: newList));
    save();
  }

  Future<void> deleteColumn(int tableIndex, int colIndex) async {
    final newList = List<JadwalModel>.from(state.tables);
    final table = newList[tableIndex];
    if (table.cols <= 1) return; // keep at least one column
    for (var r = 0; r < table.rows; r++) {
      (table.cells[r] as List).removeAt(colIndex);
    }
    table.cols -= 1;
    emit(state.copyWith(tables: newList));
    save();
  }

  /// Update stored column width for a table (persist in background).
  void updateColumnWidth(int tableIndex, int colIndex, double width) {
    final newList = List<JadwalModel>.from(state.tables);
    final table = newList[tableIndex];
    table.colWidths ??= List<double>.filled(table.cols, 120.0);
    if (colIndex >= 0 && colIndex < table.colWidths!.length) {
      table.colWidths![colIndex] = width;
      emit(state.copyWith(tables: newList));
      save();
    }
  }

  Future<void> editCell(int tableIndex, int row, int col, String value) async {
    final newList = List<JadwalModel>.from(state.tables);
    newList[tableIndex].cells[row][col] = value;
    emit(state.copyWith(tables: newList));
    // Save in background to avoid blocking UI during rapid edits.
    save();
  }
}
