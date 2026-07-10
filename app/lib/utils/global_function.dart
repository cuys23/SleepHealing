import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/features/core/models/play_list_model/albam.dart';
import 'package:medyo/features/core/models/user_model/data.dart' as us;
import 'package:medyo/utils/media_url.dart';

class AppGLF {
  AppGLF._();

  static void changeStatusBarColor({
    required Color color,
    Brightness? iconBrightness,
    Brightness? brightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color, //or set color with: Color(0xFF0000FF)
        statusBarIconBrightness:
            iconBrightness ?? Brightness.light, // For Android (dark icons)
        statusBarBrightness: brightness ?? Brightness.dark,
      ),
    );
  }

  static String format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  /// Formats a track's total duration for display, e.g. 62 -> "01:02",
  /// 3662 -> "01:01:02". Distinct from [format], which renders live
  /// playback position from a [Duration] and must stay untouched.
  static String formatSecondsDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }

  /// Formats the API's canonical duration field (whole seconds) for
  /// display. Returns an empty string for a null/absent value rather than
  /// throwing, so one track missing a duration never breaks its list row.
  static String formatTrackDuration(int? totalSeconds) {
    if (totalSeconds == null) return '';
    return formatSecondsDuration(totalSeconds);
  }

  static void updateUserData(us.Data data) {
    try{
      final Box userBox = Hive.box(
      AppHSC.userBox,
    );
    if (data.user != null) {
      debugPrint("----------------User data updated:");
      userBox.putAll(data.user!.toMap());
    }
    userBox.put(AppHSC.premium, data.hasSubscribed);
    }catch(e){
      debugPrint("Error updating user data: $e");
    }
  }

  static setMedia(AudioHandler audioHandler, AsyncSnapshot<MediaItem?> media,
      MusicTrack track) async {
    if (media.connectionState == ConnectionState.active && media.data == null) {
      await changeAndPlayMedia(audioHandler, track);
    } else {
      Future.delayed(const Duration(milliseconds: 10), () async {
        await setMedia(audioHandler, media, track);
      });
    }
  }

  static changeAndPlayMedia(AudioHandler audioHandler, MusicTrack track,
      {bool shouldPlay = false}) async {
    final apiDuration =
        track.duration != null ? Duration(seconds: track.duration!) : null;
    final audioUrl = normalizeMediaUrl(track.audio) ?? '';
    final thumbnailUrl = normalizeMediaUrl(track.thumbnail);
    final item = MediaItem(
      id: audioUrl,
      album: track.albam?.name ?? '',
      title: track.name ?? '',
      extras: {
        'isFav': track.isfavorite,
        'id': track.id.toString(),
        'album': track.albam?.id.toString(),
        'desc': track.description,
        'hasReadMore': track.hasReadMore,
        'thumbnail': thumbnailUrl,
      },
      artUri: thumbnailUrl != null ? Uri.parse(thumbnailUrl) : null,
      duration: apiDuration,
    );

    await audioHandler.updateMediaItem(item);
    if (shouldPlay) {
      audioHandler.play();
    }
  }

  static String getTimeOfDay() {
    var now = DateTime.now();
    var currentHour = now.hour;

    if (currentHour >= 5 && currentHour < 12) {
      return "Morning";
    } else if (currentHour >= 12 && currentHour < 17) {
      return "Afternoon";
    } else if (currentHour >= 17 && currentHour < 21) {
      return "Evening";
    } else {
      return "Night";
    }
  }
}
