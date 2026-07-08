// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with a real mood-logging endpoint once
// one exists. Submitting the form today only shows a local
// confirmation toast — nothing is persisted or sent anywhere.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

class MoodOption {
  const MoodOption({required this.emoji, required this.labelKey});

  final String emoji;
  final String labelKey;
}

const List<MoodOption> moodOptionsMock = [
  MoodOption(emoji: '😌', labelKey: 'mood_checkin_screen.mood_calm'),
  MoodOption(emoji: '😊', labelKey: 'mood_checkin_screen.mood_happy'),
  MoodOption(emoji: '😐', labelKey: 'mood_checkin_screen.mood_neutral'),
  MoodOption(emoji: '😟', labelKey: 'mood_checkin_screen.mood_anxious'),
  MoodOption(emoji: '😴', labelKey: 'mood_checkin_screen.mood_tired'),
];

const List<String> sleepConcernTagsMock = [
  'mood_checkin_screen.concern_insomnia',
  'mood_checkin_screen.concern_stress',
  'mood_checkin_screen.concern_racing_mind',
  'mood_checkin_screen.concern_pain',
];
