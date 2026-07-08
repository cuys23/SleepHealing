// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with real multi-day program content and
// per-user progress tracking once the catalog/backend supports
// structured programs (today's catalog only has flat audio
// categories/albums, not day-by-day programs).
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

class SleepProgram {
  const SleepProgram({
    required this.titleKey,
    required this.subtitleKey,
    required this.totalDays,
    required this.currentDay,
    required this.isPro,
  });

  final String titleKey;
  final String subtitleKey;
  final int totalDays;
  final int currentDay;
  final bool isPro;

  double get progress => currentDay / totalDays;
}

const List<SleepProgram> sleepProgramsMock = [
  SleepProgram(
    titleKey: 'sleep_programs_screen.program_reset_title',
    subtitleKey: 'sleep_programs_screen.program_reset_subtitle',
    totalDays: 7,
    currentDay: 3,
    isPro: false,
  ),
  SleepProgram(
    titleKey: 'sleep_programs_screen.program_calm_title',
    subtitleKey: 'sleep_programs_screen.program_calm_subtitle',
    totalDays: 21,
    currentDay: 14,
    isPro: false,
  ),
  SleepProgram(
    titleKey: 'sleep_programs_screen.program_stress_title',
    subtitleKey: 'sleep_programs_screen.program_stress_subtitle',
    totalDays: 5,
    currentDay: 0,
    isPro: true,
  ),
];
