import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:n3m_al3bd/features/azkar/cubit/azkar_state.dart';
import 'package:n3m_al3bd/features/azkar/model/azkar_model.dart';

class AzkarCubit extends Cubit<AzkarState> {
  AzkarCubit() : super(AzkarInitial());

  static AzkarCubit get(context) => BlocProvider.of(context);

  List<AzkarModel> azkar = [];
  // Keeps remaining repeats per item for current session (clears on reload)
  final Map<String, int> _remainingByKey = {};
  int resetEpoch = 0; // increments when all counters are reset

  String _keyFor(AzkarModel m) =>
      '${m.category ?? ''}|${m.zekr ?? ''}|${m.count ?? ''}';

  int getRemainingFor(AzkarModel m) {
    final total = (m.count == null || m.count == 0) ? 1 : m.count!;
    final k = _keyFor(m);
    return _remainingByKey[k] ?? total;
  }

  Future<void> _loadPersistedCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapString = prefs.getString('azkar_remaining');
      if (mapString != null) {
        final decoded = json.decode(mapString) as Map<String, dynamic>;
        _remainingByKey.clear();
        decoded.forEach((k, v) {
          if (v is int) _remainingByKey[k] = v;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _persistCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('azkar_remaining', json.encode(_remainingByKey));
    } catch (_) {
      // ignore
    }
  }

  Future<void> setRemainingFor(AzkarModel m, int value) async {
    _remainingByKey[_keyFor(m)] = value;
    await _persistCounters();
    // Emit success state to trigger UI rebuilds (e.g. for sorting)
    emit(GetAzkarSuccessState());
  }

  Future<void> resetCategory(String category) async {
    final keysToRemove = <String>[];
    _remainingByKey.forEach((key, _) {
      // Key format: category|zekr|count
      if (key.startsWith('$category|')) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _remainingByKey.remove(key);
    }

    await _persistCounters();
    resetEpoch++;
    emit(GetAzkarSuccessState());
  }

  Future<void> clearAllRemaining() async {
    _remainingByKey.clear();
    await _persistCounters();
    resetEpoch++;
    // Notify listeners that counters changed
    emit(GetAzkarSuccessState());
  }

  Future<void> getAzkar() async {
    emit(GetAzkarLoadingState());
    try {
      await _loadPersistedCounters();
      final response = await rootBundle.loadString('assets/json/azkar.json');
      final data = json.decode(response) as Map<String, dynamic>;
      final columns = (data['columns'] as List)
          .map((c) => c['name'] as String)
          .toList();
      final rows = data['rows'] as List;

      azkar = rows.map((row) {
        final rowMap = Map.fromIterables(columns, row);
        return AzkarModel.fromJson(rowMap);
      }).toList();

      emit(GetAzkarSuccessState());
    } catch (e) {
      emit(GetAzkarErrorState(e.toString()));
    }
  }
}
