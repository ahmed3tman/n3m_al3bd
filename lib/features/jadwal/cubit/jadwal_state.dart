import '../data/jadwal_model.dart';

enum JadwalStatus { initial, loading, success, failure }

class JadwalState {
  final JadwalStatus status;
  final List<JadwalModel> tables;
  final String? error;

  const JadwalState({
    this.status = JadwalStatus.initial,
    this.tables = const [],
    this.error,
  });

  JadwalState copyWith({
    JadwalStatus? status,
    List<JadwalModel>? tables,
    String? error,
  }) {
    return JadwalState(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      error: error ?? this.error,
    );
  }
}
