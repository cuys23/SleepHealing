import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/utils/media_url.dart';

/// Shared track/album artwork widget. When [imageUrl] is empty or fails to
/// load, shows a category-tinted gradient with a music note instead of a
/// blank/broken-image box.
class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius,
    this.category,
    this.iconSize,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final String? category;
  final double? iconSize;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(10.r);
    final fallback = _ArtworkFallback(
      width: width,
      height: height,
      borderRadius: radius,
      category: category,
      iconSize: iconSize,
    );

    final resolvedUrl = normalizeMediaUrl(imageUrl);
    if (resolvedUrl == null) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.category,
    this.iconSize,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;
  final String? category;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.categoryColor(category ?? '');
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withOpacity(0.55), tint.withOpacity(0.2)],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withOpacity(0.85),
        size: iconSize ?? (width * 0.32).clamp(16.0, 40.0),
      ),
    );
  }
}
