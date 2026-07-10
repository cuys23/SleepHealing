import 'dart:convert';

import 'package:medyo/utils/safe_parse.dart';

import 'category.dart';

class Data {
  List<Category>? category;

  Data({this.category});

  factory Data.fromMap(Map<String, dynamic> data) => Data(
        category: parseListSafely(
          data['category'] as List<dynamic>?,
          Category.fromMap,
          debugLabel: 'CategoryListModel.category',
        ),
      );

  Map<String, dynamic> toMap() => {
        'category': category?.map((e) => e.toMap()).toList(),
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
