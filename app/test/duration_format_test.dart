import 'package:flutter_test/flutter_test.dart';
import 'package:medyo/utils/global_function.dart';

void main() {
  group('AppGLF.formatSecondsDuration', () {
    test('62 seconds formats as 01:02', () {
      expect(AppGLF.formatSecondsDuration(62), '01:02');
    });

    test('242 seconds formats as 04:02', () {
      expect(AppGLF.formatSecondsDuration(242), '04:02');
    });

    test('3662 seconds formats as 01:01:02', () {
      expect(AppGLF.formatSecondsDuration(3662), '01:01:02');
    });

    test('0 seconds formats as 00:00', () {
      expect(AppGLF.formatSecondsDuration(0), '00:00');
    });
  });

  group('AppGLF.formatTrackDuration', () {
    test('the canonical JSON integer seconds formats correctly', () {
      expect(AppGLF.formatTrackDuration(242), '04:02');
    });

    test('null returns an empty string, not a crash', () {
      expect(AppGLF.formatTrackDuration(null), '');
    });

    test('zero formats as 00:00, not an empty string', () {
      expect(AppGLF.formatTrackDuration(0), '00:00');
    });
  });
}
