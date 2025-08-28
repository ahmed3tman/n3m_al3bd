class JadwalModel {
  String name;
  int rows;
  int cols;
  List<List<String>> cells;
  List<double>? colWidths;

  JadwalModel({
    required this.name,
    required this.rows,
    required this.cols,
    required this.cells,
    this.colWidths,
  });

  factory JadwalModel.empty(String name, int rows, int cols) {
    return JadwalModel(
      name: name,
      rows: rows,
      cols: cols,
      cells: List.generate(rows, (_) => List.generate(cols, (_) => '')),
      colWidths: List<double>.generate(cols, (_) => 120.0),
    );
  }

  factory JadwalModel.fromMap(Map<String, dynamic> m) {
    final rawCells = m['cells'] as List<dynamic>? ?? [];
    return JadwalModel(
      name: m['name'] as String? ?? '',
      rows: m['rows'] as int? ?? 0,
      cols: m['cols'] as int? ?? 0,
      cells: rawCells
          .map(
            (r) => List<String>.from(
              (r as List<dynamic>).map((e) => e?.toString() ?? ''),
            ),
          )
          .toList(),
      colWidths: (m['colWidths'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'rows': rows,
    'cols': cols,
    'cells': cells,
    'colWidths': colWidths,
  };
}
