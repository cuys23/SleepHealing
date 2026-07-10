import 'dart:convert';

import 'package:medyo/utils/safe_parse.dart';

import 'albam.dart';

class PlayList {
  List<MusicTrack>? albams;

  PlayList({this.albams});

  factory PlayList.fromMap(Map<String, dynamic> data) => PlayList(
        albams: parseListSafely(
          data['albams'] as List<dynamic>?,
          MusicTrack.fromMap,
          debugLabel: 'PlayList.albams',
        ),
      );

  Map<String, dynamic> toMap() => {
        'albams': albams?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Data].
  factory PlayList.fromJson(String data) {
    return PlayList.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Data] to a JSON string.
  String toJson() => json.encode(toMap());
}
