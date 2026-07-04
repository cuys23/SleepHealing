import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primaryColor = Color(0xff39D8D8);

  static const Color lightGeay = Color(0xFFD1D1D1);
  // static const Color lightGeay = Color(0xFF7C9A92);
  static Color darkTeal = bgPrimary;
  static const Color slidePanel = Color(0xFF425553);
  // static const Color darkGreen = Color(0xFF364B4D);
  static const Color darkGreen = Color(0xFF06a0ff);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFFD7EFFF);

  static const Color red = Color(0xFFFF0000);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color buttonBorder = Color(0xFF5F7873);

  static const Color deepOlive = Color(0xFF25342A); // 25342A
  static const Color purpleShade = Color(0xFF322534); // 322534
  static const Color stoneGray = Color(0xFF343025); // 343025
  static const Color brownShade = Color(0xFF342525); // 342525

  // ---- Deep Calm design system ----
  static const Color bgPrimary = Color(0xFF0A0E27);
  static const Color bgAlt = Color(0xFF131833);
  static const Color surface = Color(0xFF1A1F3D);
  static const Color accentPrimary = Color(0xFF7C4DFF);
  static const Color accentSecondary = Color(0xFF00BFA5);
  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0x99E8EAF6); // rgba(232,234,246,0.6)
  static const Color textTertiary = Color(0x4DE8EAF6); // rgba(232,234,246,0.3)
  static const Color danger = Color(0xFFFF3B30);
  static const Color divider = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color inputBg = Color(0x12FFFFFF); // rgba(255,255,255,0.07)
  static const Color tabBarBg = Color(0xD90A0E27); // rgba(10,14,39,0.85)

  // Category accent colors (Deep Calm spec)
  static const Color categorySleep = Color(0xFF7E57C2);
  static const Color categoryBreathe = Color(0xFF26A69A);
  static const Color categoryFocus = Color(0xFFFFA726);
  static const Color categoryRelax = Color(0xFF66BB6A);
  static const Color categoryAnxiety = Color(0xFF42A5F5);
  static const Color categoryKids = Color(0xFFFFCA28);

  /// Keyword-based lookup so this degrades gracefully as category names change.
  static Color categoryColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('sleep') || n.contains('bedtime')) return categorySleep;
    if (n.contains('breath')) return categoryBreathe;
    if (n.contains('kids')) return categoryKids;
    if (n.contains('relax') || n.contains('piano')) return categoryRelax;
    if (n.contains('nature') || n.contains('white noise')) {
      return categoryAnxiety;
    }
    if (n.contains('focus')) return categoryFocus;
    return accentPrimary;
  }
}
