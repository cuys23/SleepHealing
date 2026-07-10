import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/chips/coming_soon_badge.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Local-only UI state: no real ThemeMode/notification-preference wiring
  // yet, per the deliberate decision to defer real light/dark theming and
  // push-notification opt-in this round.
  // TODO(theming): wire to a real ThemeMode provider once light mode ships.
  // TODO(notifications): wire to a real notification-preference provider.
  bool _darkMode = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Column(
        children: [
          RegularAppBar(title: 'settings_screen.title'.tr()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              children: [
                _SettingsGroupLabel('settings_screen.account'.tr()),
                _SettingsGroup(children: [
                  _SettingsRow(
                    icon: Icons.person_outline,
                    label: 'settings_screen.edit_profile'.tr(),
                    onTap: () {
                      // Profile editing lives on the Profile tab today; no
                      // dedicated edit-profile screen exists yet.
                      context.nav.pop();
                    },
                  ),
                  _SettingsRow(
                    icon: Icons.lock_outline,
                    label: 'profile_screen.change_pass'.tr(),
                    onTap: () => context.nav.pushNamed(Routes.changePass),
                    isLast: true,
                  ),
                ]),
                AppSpacerH(20.h),
                _SettingsGroupLabel('settings_screen.preferences'.tr()),
                _SettingsGroup(children: [
                  _SettingsToggleRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'settings_screen.dark_mode'.tr(),
                    value: _darkMode,
                    onChanged: (v) => setState(() => _darkMode = v),
                  ),
                  _SettingsToggleRow(
                    icon: Icons.notifications_outlined,
                    label: 'settings_screen.notifications'.tr(),
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                  const _SettingsAudioQualityRow(),
                ]),
                AppSpacerH(20.h),
                _SettingsGroupLabel('settings_screen.about'.tr()),
                _SettingsGroup(children: [
                  _SettingsRow(
                    icon: Icons.help_outline,
                    label: 'settings_screen.help_center'.tr(),
                    onTap: () => context.nav.pushNamed(Routes.contactUs),
                  ),
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    label: 'profile_screen.privacy_policy'.tr(),
                    onTap: () => context.nav.pushNamed(Routes.privacyPolicy),
                  ),
                  const _SettingsVersionRow(),
                ]),
                AppSpacerH(24.h),
                GestureDetector(
                  onTap: () => showLogoutDialouge(context),
                  child: Center(
                    child: Text(
                      'profile_screen.log_out'.tr(),
                      style: AppTextDecor.bodyTitle15
                          .copyWith(color: AppColors.danger),
                    ),
                  ),
                ),
                AppSpacerH(24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroupLabel extends StatelessWidget {
  const _SettingsGroupLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(label, style: AppTextDecor.overline11),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textMuted),
            AppSpacerW(10.w),
            Expanded(
                child: Text(label, style: AppTextDecor.bodyTitle15)),
            trailing ??
                Icon(Icons.chevron_right,
                    size: 14.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: icon,
      label: label,
      onTap: () => onChanged(!value),
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: AppColors.accentPrimary,
        onChanged: onChanged,
      ),
    );
  }
}

/// Audio Quality selector shown in the design but with no backing engine
/// support today (the audio pipeline has no bitrate/quality switch) — kept
/// visible per the design but dimmed and non-interactive so it doesn't
/// read as a working control.
class _SettingsAudioQualityRow extends StatelessWidget {
  const _SettingsAudioQualityRow();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: IgnorePointer(
        child: _SettingsRow(
          icon: Icons.graphic_eq,
          label: 'settings_screen.audio_quality'.tr(),
          isLast: true,
          trailing: const ComingSoonBadge(),
        ),
      ),
    );
  }
}

class _SettingsVersionRow extends StatelessWidget {
  const _SettingsVersionRow();

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: Icons.info_outline,
      label: 'settings_screen.about_app'.tr(),
      isLast: true,
      trailing: Text('v2.0.2', style: AppTextDecor.caption13Muted),
      onTap: null,
    );
  }
}
