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

  // ---- SleepHealing design system (v1.0, SleepHealing.dc.html) ----
  static const Color bgPrimary = Color(0xFF080810); // Midnight
  static const Color bgAlt = Color(0xFF12121F); // Deep Indigo
  static const Color surface = Color(0xFF1A1A2E); // Indigo Night
  static const Color twilight = Color(0xFF222240); // Twilight — card-on-card
  static const Color accentPrimary = Color(0xFF7C6DF0); // Soft Purple
  static const Color accentSecondary = Color(0xFF5EB8EF); // Sky Blue
  static const Color mint = Color(0xFF4ECFA5);
  static const Color softGold = Color(0xFFE8C76A);
  static const Color rose = Color(0xFFF06D9C);
  static const Color textPrimary = Color(0xFFF0EEF5); // Soft White
  static const Color textSecondary = Color(0xFFB8A9F0); // Lavender — body text
  static const Color textMuted = Color(0xFF7D7A96); // captions/metadata
  static const Color textTertiary = Color(0xFF4A4766); // overline/disabled
  static const Color danger = Color(0xFFF06D9C); // Rose
  static const Color divider = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color inputBg = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color tabBarBg = Color(0xF0080810); // rgba(8,8,16,0.94)

  // Category accent colors (SleepHealing spec — reuse core accents)
  static const Color categorySleep = accentPrimary;
  static const Color categoryBreathe = mint;
  static const Color categoryFocus = softGold;
  static const Color categoryRelax = mint;
  static const Color categoryAnxiety = accentSecondary;
  static const Color categoryKids = softGold;

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
