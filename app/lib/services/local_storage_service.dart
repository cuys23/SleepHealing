import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/hive_contants.dart';

/// Local-only persistence for Recently Played, Continue Listening and the
/// last-picked sleep timer duration. Backed entirely by Hive - no backend
/// or database involved.
class LocalStorageService {
  LocalStorageService._();

  static const int maxRecentlyPlayed = 10;
  static const double continueListeningNearEndRatio = 0.95;

  static Box get _recentBox => Hive.box(AppHSC.recentlyPlayedBox);
  static Box get _continueBox => Hive.box(AppHSC.continueListeningBox);
  static Box get _prefsBox => Hive.box(AppHSC.playerPrefsBox);

  static Map<String, dynamic> _mapFromMediaItem(MediaItem item) => {
        'id': item.extras?['id']?.toString(),
        'albumId': item.extras?['album']?.toString(),
        'title': item.title,
        'albumName': item.album,
        'thumbnail':
            item.extras?['thumbnail']?.toString() ?? item.artUri?.toString(),
        'audio': item.id,
        'desc': item.extras?['desc'],
        'hasReadMore': item.extras?['hasReadMore'],
        'isFav': item.extras?['isFav'],
      };

  static void addRecentlyPlayed(MediaItem item) {
    final id = item.extras?['id']?.toString();
    if (id == null || id.isEmpty || item.id.isEmpty) return;

    final entry = _mapFromMediaItem(item)
      ..['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    final list = List<Map>.from(
        (_recentBox.get('items', defaultValue: []) as List).cast<Map>());
    list.removeWhere((e) => e['id']?.toString() == id);
    list.insert(0, entry);
    if (list.length > maxRecentlyPlayed) {
      list.removeRange(maxRecentlyPlayed, list.length);
    }
    _recentBox.put('items', list);
  }

  static List<Map> getRecentlyPlayed() {
    return List<Map>.from(
        (_recentBox.get('items', defaultValue: []) as List).cast<Map>());
  }

  static void saveContinueListening({
    required MediaItem item,
    required Duration position,
    required Duration? duration,
  }) {
    final id = item.extras?['id']?.toString();
    if (id == null || id.isEmpty || item.id.isEmpty) return;

    if (duration != null && duration.inMilliseconds > 0) {
      final ratio = position.inMilliseconds / duration.inMilliseconds;
      if (ratio >= continueListeningNearEndRatio) {
        _continueBox.delete('item');
        return;
      }
    }
    if (position.inMilliseconds < 3000) return;

    final entry = _mapFromMediaItem(item)
      ..['position'] = position.inMilliseconds
      ..['duration'] = duration?.inMilliseconds
      ..['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    _continueBox.put('item', entry);
  }

  static Map<String, dynamic>? getContinueListening() {
    final data = _continueBox.get('item');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  static void clearContinueListening() => _continueBox.delete('item');

  static void saveLastSleepTimerMinutes(int minutes) {
    _prefsBox.put('sleep_timer_minutes', minutes);
  }

  static int? getLastSleepTimerMinutes() {
    return _prefsBox.get('sleep_timer_minutes') as int?;
  }
}
