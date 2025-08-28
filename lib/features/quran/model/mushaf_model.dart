import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Mushaf {
  final String id;
  final String name;
  int currentSurahIndex;
  int currentPageIndex;

  Mushaf({
    required this.id,
    required this.name,
    this.currentSurahIndex = 0,
    this.currentPageIndex = 0,
  });

  factory Mushaf.fromJson(Map<String, dynamic> json) => Mushaf(
    id: json['id'],
    name: json['name'],
    currentSurahIndex: json['currentSurahIndex'] ?? 0,
    currentPageIndex: json['currentPageIndex'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currentSurahIndex': currentSurahIndex,
    'currentPageIndex': currentPageIndex,
  };
}

class MushafStorage {
  static const _key = 'mushafs_v1';

  static Future<List<Mushaf>> loadMushafs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> data = jsonDecode(raw);
    return data.map((e) => Mushaf.fromJson(e)).toList();
  }

  static Future<void> saveMushafs(List<Mushaf> mushafs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(mushafs.map((m) => m.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<Mushaf> addMushaf(String name) async {
    final list = await loadMushafs();
    final m = Mushaf(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      currentSurahIndex: 0,
      currentPageIndex: 0,
    );
    list.insert(0, m);
    await saveMushafs(list);
    return m;
  }

  static Future<void> updateMushaf(Mushaf mushaf) async {
    final list = await loadMushafs();
    final idx = list.indexWhere((m) => m.id == mushaf.id);
    if (idx >= 0) {
      list[idx] = mushaf;
      await saveMushafs(list);
    }
  }

  static Future<void> removeMushaf(String id) async {
    final list = await loadMushafs();
    list.removeWhere((m) => m.id == id);
    await saveMushafs(list);
  }
}
