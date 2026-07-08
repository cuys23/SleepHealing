// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with real aggregated sleep statistics
// once a sleep-tracking data source exists.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

class StatInsight {
  const StatInsight({
    required this.labelKey,
    required this.messageKey,
    required this.isPositive,
  });

  final String labelKey;
  final String messageKey;
  final bool isPositive;
}

const List<StatInsight> statInsightsMock = [
  StatInsight(
    labelKey: 'statistics_screen.insight_improving',
    messageKey: 'statistics_screen.insight_improving_msg',
    isPositive: true,
  ),
  StatInsight(
    labelKey: 'statistics_screen.insight_tip',
    messageKey: 'statistics_screen.insight_tip_msg',
    isPositive: false,
  ),
];
