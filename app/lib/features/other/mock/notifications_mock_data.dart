// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with real notification history once a
// backend endpoint exists. Push delivery itself already works
// via firebase_messaging — this screen is only missing a history
// list API, it does not affect whether push notifications work.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

import 'package:flutter/material.dart';

class NotificationItem {
  const NotificationItem({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    required this.timeKey,
    required this.group,
  });

  final IconData icon;
  final String titleKey;
  final String bodyKey;
  final String timeKey;
  final String group;
}

const List<NotificationItem> notificationsMock = [
  NotificationItem(
    icon: Icons.nightlight_round,
    titleKey: 'notifications_screen.n1_title',
    bodyKey: 'notifications_screen.n1_body',
    timeKey: 'notifications_screen.time_2m',
    group: 'notifications_screen.group_today',
  ),
  NotificationItem(
    icon: Icons.emoji_events_outlined,
    titleKey: 'notifications_screen.n2_title',
    bodyKey: 'notifications_screen.n2_body',
    timeKey: 'notifications_screen.time_1h',
    group: 'notifications_screen.group_today',
  ),
  NotificationItem(
    icon: Icons.play_circle_outline,
    titleKey: 'notifications_screen.n3_title',
    bodyKey: 'notifications_screen.n3_body',
    timeKey: 'notifications_screen.time_yesterday',
    group: 'notifications_screen.group_earlier',
  ),
];
