import 'package:flutter/foundation.dart';

/// Decoration types for mapping-based 15-line rendering
enum LineDeco { none, header, basmalah, spacer }

/// Holds the pre-calculated layout configuration for a single Mushaf page.
/// This includes font size, spacing per line, and line decorations.
@immutable
class VerseLayoutData {
  final double fontSize;
  final List<double> wordSpacing;
  final List<double> letterSpacing;
  final List<LineDeco> lineDecos;
  final List<int?> decoSurahIds;
  final bool isCentered;

  const VerseLayoutData({
    required this.fontSize,
    required this.wordSpacing,
    required this.letterSpacing,
    required this.lineDecos,
    required this.decoSurahIds,
    this.isCentered = false,
  });
}

/// A simple in-memory cache for page layouts.
/// Keys are composite: "{pageIndex}_{width}".
class VerseLayoutCache {
  static final Map<String, VerseLayoutData> _cache = {};

  static String _key(int pageIndex, double width, double height) =>
      '${pageIndex}_${width.truncate()}_${height.truncate()}';

  static VerseLayoutData? get(int pageIndex, double width, double height) {
    return _cache[_key(pageIndex, width, height)];
  }

  static void set(
    int pageIndex,
    double width,
    double height,
    VerseLayoutData data,
  ) {
    _cache[_key(pageIndex, width, height)] = data;
  }

  static void clear() {
    _cache.clear();
  }
}
