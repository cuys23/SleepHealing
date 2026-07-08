import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/features/core/models/play_list_model/albam.dart';
import 'package:medyo/features/core/models/user_model/data.dart' as us;

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

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.trim().split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
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
    Duration? apiDuration;
    if (track.duration != null && track.duration!.isNotEmpty) {
      try {
        apiDuration = parseDuration(track.duration!);
      } catch (e) {
        debugPrint('[Audio] parseDuration failed for "${track.duration}": $e');
      }
    }
    final item = MediaItem(
      id: track.audio.toString(),
      album: track.albam?.name ?? '',
      title: track.name ?? '',
      extras: {
        'isFav': track.isfavorite,
        'id': track.id.toString(),
        'album': track.albam?.id.toString(),
        'desc': track.description,
        'hasReadMore': track.hasReadMore,
        'thumbnail': track.thumbnail,
      },
      artUri: Uri.parse(track.thumbnail ?? ''),
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
