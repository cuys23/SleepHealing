import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/wellness/mock/sleep_tracker_mock_data.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/progress/circular_progress_ring.dart';

/// Sleep Tracker tab. This entire feature has no backend/data source today
/// (no sleep-session logging pipeline exists) — see sleep_tracker_mock_data
/// for the TODO. Renders as a UI shell using representative sample values.
class SleepTrackerScreen extends StatelessWidget {
  const SleepTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView(
          padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
          children: [
            Text('sleep_tracker_screen.title'.tr(),
                style: AppTextDecor.heading2_22),
            AppSpacerH(18.h),
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withOpacity(0.12),
                    AppColors.accentSecondary.withOpacity(0.06),
                  ],
                ),
                border: Border.all(color: AppColors.accentPrimary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircularProgressRing(
                    progress: 0.78,
                    size: 72.w,
                    strokeWidth: 5,
                    child: Text('78', style: AppTextDecor.heading3_17),
                  ),
                  AppSpacerW(16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('sleep_tracker_screen.last_night'.tr(),
                            style: AppTextDecor.caption13Muted),
                        Text('sleep_tracker_screen.good_sleep'.tr(),
                            style: AppTextDecor.heading3_17),
                        Text('sleep_tracker_screen.above_average'.tr(),
                            style: AppTextDecor.tagBadge11
                                .copyWith(color: AppColors.mint)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacerH(16.h),
            Row(
              children: [
                _StatCell(
                    value: '7h 24m',
                    labelKey: 'sleep_tracker_screen.time_asleep',
                    color: AppColors.accentPrimary),
                _StatCell(
                    value: '12 min',
                    labelKey: 'sleep_tracker_screen.fall_asleep',
                    color: AppColors.accentSecondary),
                _StatCell(
                    value: '2',
                    labelKey: 'sleep_tracker_screen.wake_ups',
                    color: AppColors.mint),
              ],
            ),
            AppSpacerH(20.h),
            Text('sleep_tracker_screen.this_week'.tr(),
                style: AppTextDecor.heading3_17),
            AppSpacerH(12.h),
            SizedBox(
              height: 100.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklySleepMock
                    .map((point) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 78.h * point.heightFraction,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.accentPrimary,
                                        AppColors.accentPrimary
                                            .withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                                AppSpacerH(6.h),
                                Text(point.dayLabel,
                                    style: AppTextDecor.tagBadge11
                                        .copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            AppSpacerH(24.h),
            Row(
              children: [
                Expanded(
                  child: _NavCard(
                    icon: Icons.bar_chart_rounded,
                    titleKey: 'sleep_tracker_screen.statistics',
                    onTap: () =>
                        context.nav.pushNamed(Routes.statisticsScreen),
                  ),
                ),
                AppSpacerW(12.w),
                Expanded(
                  child: _NavCard(
                    icon: Icons.checklist_rounded,
                    titleKey: 'sleep_tracker_screen.programs',
                    onTap: () =>
                        context.nav.pushNamed(Routes.sleepProgramsScreen),
                  ),
                ),
              ],
            ),
            AppSpacerH(12.h),
            _NavCard(
              icon: Icons.mood_rounded,
              titleKey: 'sleep_tracker_screen.mood_checkin',
              onTap: () => context.nav.pushNamed(Routes.moodCheckinScreen),
              fullWidth: true,
            ),
            AppSpacerH(20.h),
            Text('sleep_tracker_screen.wellness_tools'.tr(),
                style: AppTextDecor.heading3_17),
            AppSpacerH(12.h),
            Row(
              children: [
                Expanded(
                  child: _NavCard(
                    icon: Icons.self_improvement_rounded,
                    titleKey: 'sleep_tracker_screen.meditation',
                    onTap: () =>
                        context.nav.pushNamed(Routes.meditationScreen),
                  ),
                ),
                AppSpacerW(12.w),
                Expanded(
                  child: _NavCard(
                    icon: Icons.air_rounded,
                    titleKey: 'sleep_tracker_screen.breathing',
                    onTap: () =>
                        context.nav.pushNamed(Routes.breathingScreen),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.labelKey, required this.color});
  final String value;
  final String labelKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextDecor.heading3_17.copyWith(color: color)),
            AppSpacerH(2.h),
            Text(labelKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextDecor.tagBadge11
                    .copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.titleKey,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String titleKey;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp, color: AppColors.accentPrimary),
            AppSpacerW(8.w),
            Flexible(
              child: Text(titleKey.tr(),
                  style: AppTextDecor.bodyTitle15,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
