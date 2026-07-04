import 'package:flutter/material.dart';

/// Immutable data model for a single carousel entry in "Collection of the Day".
class CollectionModel {
  const CollectionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.backgroundGradient,
    this.image,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> backgroundGradient;
  final String? image;
}
