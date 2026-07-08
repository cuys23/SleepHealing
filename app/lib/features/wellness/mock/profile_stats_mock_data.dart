// ============================================================
// MOCK DATA — UI SHELL ONLY, NOT WIRED TO BACKEND
// TODO(backend): replace with a real aggregation endpoint/local
// computation (nights tracked, hours listened, day streak) once
// the backend or on-device analytics exist.
// Do not import this file from any provider/service in
// features/core/logic or services/ — presentation layer only.
// ============================================================

class ProfileStat {
  const ProfileStat({required this.value, required this.labelKey});

  final String value;
  final String labelKey;
}

const List<ProfileStat> profileStatsMock = [
  ProfileStat(value: '—', labelKey: 'profile_screen.stat_nights'),
  ProfileStat(value: '—', labelKey: 'profile_screen.stat_listened'),
  ProfileStat(value: '—', labelKey: 'profile_screen.stat_streak'),
];
