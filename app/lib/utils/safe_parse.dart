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
