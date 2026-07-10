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

  group('parseIntSafely', () {
    test('a native JSON int passes through unchanged', () {
      expect(parseIntSafely(242), 242);
    });

    test('zero passes through unchanged, not treated as absent', () {
      expect(parseIntSafely(0), 0);
    });

    test('a numeric string is coerced to int', () {
      expect(parseIntSafely('242'), 242);
    });

    test('a JSON double is rounded to int', () {
      expect(parseIntSafely(242.0), 242);
    });

    test('null returns null', () {
      expect(parseIntSafely(null), isNull);
    });

    test('an empty string returns null', () {
      expect(parseIntSafely(''), isNull);
    });

    test('an unparseable string returns null, not a crash', () {
      expect(parseIntSafely('not-a-number'), isNull);
    });
  });
}
