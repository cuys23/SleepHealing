import 'dart:convert';

import 'package:medyo/utils/safe_parse.dart';

import 'albam.dart';

class Data {
  List<Albam>? albams;

  Data({this.albams});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        albams: parseListSafely(
          data['albams'] as List<dynamic>?,
          Albam.fromMap,
          debugLabel: 'AlbumListModel.albams',
        ),
      );

  Map<String, dynamic> toMap() => {
        'albams': albams?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Data].
  factory Data.fromJson(String data) {
    return Data.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Data] to a JSON string.
  String toJson() => json.encode(toMap());
}
