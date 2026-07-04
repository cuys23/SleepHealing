import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medyo/config/app_colors.dart';

/// Single source of truth for the Maditam "Moon Drop" brand mark.
///
/// Renders the icon (crescent moon + meditation drop on a deep-indigo
/// badge) from `assets/branding/maditam_logo.svg`, with an optional
/// lowercase "maditam" wordmark. Use this everywhere the brand logo is
/// shown instead of referencing the logo asset directly.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.isDark = true,
    this.direction = Axis.vertical,
  });

  /// Diameter of the icon badge.
  final double size;

  /// Whether to show the lowercase "maditam" wordmark next to/below the icon.
  final bool showText;

  /// Whether the surrounding surface is dark (light wordmark text) or light
  /// (dark wordmark text). The icon badge itself is unaffected — its deep
  /// indigo background is part of the fixed brand identity.
  final bool isDark;

  /// Layout of icon + wordmark when [showText] is true.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      'assets/branding/maditam_logo.svg',
      width: size,
      height: size,
    );

    if (!showText) return icon;

    final wordmark = Text(
      'maditam',
      style: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w600,
        fontSize: size * 0.34,
        letterSpacing: 3,
        color: isDark ? AppColors.textPrimary : AppColors.bgPrimary,
      ),
    );

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, SizedBox(width: size * 0.18), wordmark],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [icon, SizedBox(height: size * 0.18), wordmark],
    );
  }
}
