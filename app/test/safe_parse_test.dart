import 'package:flutter_test/flutter_test.dart';
import 'package:medyo/utils/safe_parse.dart';

void main() {
  test('parses every well-formed item', () {
    final raw = [
      {'id': 1},
      {'id': 2},
      {'id': 3},
    ];
    final result = parseListSafely(raw, (m) => m['id'] as int);
    expect(result, [1, 2, 3]);
  });

  test('a single malformed item is skipped, valid items survive', () {
    final raw = [
      {'id': 1},
      {'id': 'not-an-int'}, // will throw on the cast below
      {'id': 3},
    ];
    final result = parseListSafely(raw, (m) => m['id'] as int);
    expect(result, [1, 3]);
  });

  test('null input returns an empty list, not null', () {
    expect(parseListSafely(null, (m) => m['id'] as int), <int>[]);
  });

  test('empty input returns an empty list', () {
    expect(parseListSafely(const [], (m) => m['id'] as int), <int>[]);
  });
}
