// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with real achievement/unlock tracking
// once the backend supports it. Every badge is rendered as
// locked (not earned) below, since there is no real completion
// data to show yet — do not fabricate "earned" state.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

import 'package:flutter/material.dart';

class AchievementBadge {
  const AchievementBadge({required this.icon, required this.labelKey});

  final IconData icon;
  final String labelKey;
}

const List<AchievementBadge> achievementBadgesMock = [
  AchievementBadge(
      icon: Icons.emoji_events_outlined,
      labelKey: 'profile_screen.badge_streak'),
  AchievementBadge(
      icon: Icons.nights_stay_outlined,
      labelKey: 'profile_screen.badge_sleep'),
  AchievementBadge(
      icon: Icons.favorite_border, labelKey: 'profile_screen.badge_fan'),
  AchievementBadge(
      icon: Icons.self_improvement_outlined,
      labelKey: 'profile_screen.badge_meditate'),
];
