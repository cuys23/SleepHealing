import 'package:flutter_test/flutter_test.dart';
import 'package:medyo/features/core/models/play_list_model/albam.dart';
import 'package:medyo/features/core/models/play_list_model/data.dart' as pl;

void main() {
  group('MusicTrack.fromMap', () {
    test('parses a complete song record', () {
      final track = MusicTrack.fromMap({
        'id': 79,
        'name': 'E2E QA Song',
        'description': 'a test track',
        'duration': '3:30',
        'thumbnail': 'http://localhost:9080/storage/images/playlist/x.png',
        'audio': 'http://localhost:9080/storage/audio/playlist/x.mp3',
        'is_favorite': false,
        'is_paid': false,
        'albam': null,
        'has_readmore': false,
      });

      expect(track.id, 79);
      expect(track.name, 'E2E QA Song');
      expect(track.duration, '3:30');
      expect(track.thumbnail, isNotNull);
      expect(track.audio, isNotNull);
    });

    test('a null image/audio does not throw and yields null fields', () {
      final track = MusicTrack.fromMap({
        'id': 1,
        'name': 'No media yet',
        'duration': null,
        'thumbnail': null,
        'audio': null,
      });

      expect(track.id, 1);
      expect(track.thumbnail, isNull);
      expect(track.audio, isNull);
      expect(track.duration, isNull);
    });

    test('duration arrives as the API-native numeric string, e.g. "3:30"', () {
      final track = MusicTrack.fromMap({'id': 1, 'duration': '3:30'});
      expect(track.duration, isA<String>());
      expect(track.duration, '3:30');
    });
  });

  group('PlayList.fromMap list resilience', () {
    test('one malformed track does not drop the rest of the list', () {
      final playList = pl.PlayList.fromMap({
        'albams': [
          {'id': 1, 'name': 'Good track A'},
          {'id': 'not-an-int', 'name': 'Malformed track'}, // id cast throws
          {'id': 3, 'name': 'Good track B'},
        ],
      });

      expect(playList.albams, isNotNull);
      expect(playList.albams!.length, 2);
      expect(playList.albams!.map((t) => t.id), [1, 3]);
    });

    test('missing albams key yields an empty list, not null crash', () {
      final playList = pl.PlayList.fromMap(<String, dynamic>{});
      expect(playList.albams, <MusicTrack>[]);
    });
  });
}
