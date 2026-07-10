import 'package:flutter/foundation.dart';

/// Parses a raw JSON list into typed items, skipping any entry that fails to
/// parse instead of letting one malformed record wipe out the whole list.
List<T> parseListSafely<T>(
  List<dynamic>? raw,
  T Function(Map<String, dynamic>) fromMap, {
  String? debugLabel,
}) {
  if (raw == null) return <T>[];
  final items = <T>[];
  for (final entry in raw) {
    try {
      items.add(fromMap(entry as Map<String, dynamic>));
    } catch (e) {
      debugPrint('[parseListSafely]${debugLabel != null ? ' $debugLabel:' : ''} '
          'skipped malformed item: $e');
    }
  }
  return items;
}

/// Coerces a JSON value into an int, accepting the canonical native number
/// as well as a numeric string (e.g. a stale cached response) so a backend
/// transition doesn't crash on mixed data. Returns null for null/empty/
/// unparseable input rather than throwing.
int? parseIntSafely(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is double) return raw.round();
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.round();
  }
  return null;
}
