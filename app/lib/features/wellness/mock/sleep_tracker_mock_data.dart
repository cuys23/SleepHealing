// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with real sleep-tracking data once a
// sleep session recording pipeline (manual log or device
// integration) and a backend endpoint exist. See CLAUDE.md's
// "DATA HANDLING FOR NEW FEATURES" section — this feature has
// no data source today, so every value below is a placeholder,
// not a real user metric.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

class WeeklySleepPoint {
  const WeeklySleepPoint({required this.dayLabel, required this.heightFraction});

  final String dayLabel;

  /// 0.0 - 1.0, relative bar height for the weekly chart.
  final double heightFraction;
}

const List<WeeklySleepPoint> weeklySleepMock = [
  WeeklySleepPoint(dayLabel: 'M', heightFraction: 0.6),
  WeeklySleepPoint(dayLabel: 'T', heightFraction: 0.75),
  WeeklySleepPoint(dayLabel: 'W', heightFraction: 0.5),
  WeeklySleepPoint(dayLabel: 'T', heightFraction: 0.85),
  WeeklySleepPoint(dayLabel: 'F', heightFraction: 0.7),
  WeeklySleepPoint(dayLabel: 'S', heightFraction: 0.9),
  WeeklySleepPoint(dayLabel: 'S', heightFraction: 0.8),
];
