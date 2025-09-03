import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Loads and caches the line-based Mushaf layout from assets/json/line_mapping.json.
/// The JSON structure is a map of line numbers ("1".."15") to arrays of entries, each
/// entry containing: { "page": <int>, "suraAya": "<sura>:<aya>", "wordPos": <int>, "text": "<glyph>" }.
///
/// We aggregate these into a per-page mapping of 15 lines, where each line is an ordered
/// list of tokens pointing to the actual Quran text: {sura_no, aya_no, word_pos}.
/// This allows the UI to reconstruct lines from the real text in quran.json instead of the glyphs.
class LineMappingRepository {
  // page -> list of 15 lines -> list of tokens per line
  // token: { 'sura_no': int, 'aya_no': int, 'word_pos': int }
  static Map<int, List<List<Map<String, int>>>>? _cache;
  static Future<Map<int, List<List<Map<String, int>>>>>? _loading;

  static Map<int, List<List<Map<String, int>>>>? get cache => _cache;

  static Future<Map<int, List<List<Map<String, int>>>>> ensureLoaded() {
    if (_cache != null) {
      return SynchronousFuture(_cache!);
    }
    if (_loading != null) {
      return _loading!;
    }
    _loading = _load();
    return _loading!;
  }

  static Future<Map<int, List<List<Map<String, int>>>>> _load() async {
    final raw = await rootBundle.loadString('assets/json/line_mapping.json');
    final parsed =
        await compute<String, Map<int, List<List<Map<String, int>>>>>(
          _parseLineMappingFromRaw,
          raw,
        );
    _cache = parsed;
    return parsed;
  }
}

// Top-level function for compute() to parse on a background isolate.
Map<int, List<List<Map<String, int>>>> _parseLineMappingFromRaw(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;

  // Aggregate into page -> lineNo -> list of token maps
  final Map<int, List<List<Map<String, int>>>> tokensByPage = {};

  for (int lineNo = 1; lineNo <= 15; lineNo++) {
    final key = lineNo.toString();
    final list = decoded[key];
    if (list is List) {
      for (final entry in list) {
        if (entry is Map<String, dynamic>) {
          final page = entry['page'];
          final suraAya = entry['suraAya'];
          final wordPos = entry['wordPos'];
          if (page is int && suraAya is String && wordPos is int) {
            final parts = suraAya.split(':');
            if (parts.length == 2) {
              final suraNo = int.tryParse(parts[0]);
              final ayaNo = int.tryParse(parts[1]);
              if (suraNo != null && ayaNo != null) {
                final pageLines = tokensByPage.putIfAbsent(
                  page,
                  () => List<List<Map<String, int>>>.generate(
                    15,
                    (_) => <Map<String, int>>[],
                  ),
                );
                pageLines[lineNo - 1].add({
                  'sura_no': suraNo,
                  'aya_no': ayaNo,
                  'word_pos': wordPos,
                });
              }
            }
          }
        }
      }
    }
  }

  return tokensByPage;
}
