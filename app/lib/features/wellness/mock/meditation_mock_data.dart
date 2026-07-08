// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend/content): replace with real guided-meditation
// session content (audio track, real benefits copy) once the
// catalog exposes a dedicated meditation session type. The
// countdown timer itself is real (local Dart Timer), only the
// session metadata below is a placeholder.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

const List<int> meditationDurationsMinutes = [5, 15, 30];

const String meditationSessionTitleKey = 'meditation_screen.session_title';
const String meditationSessionSubtitleKey = 'meditation_screen.session_subtitle';
const String meditationBenefitsKey = 'meditation_screen.benefits';
