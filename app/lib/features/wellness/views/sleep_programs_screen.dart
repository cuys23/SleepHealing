import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/wellness/mock/sleep_programs_mock_data.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/widgets/chips/pro_badge.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

/// No structured multi-day program content/progress backend exists yet —
/// see sleep_programs_mock_data.dart TODO. PRO items reuse the app's
/// existing premium-gate dialog, same as paid audio content elsewhere.
class SleepProgramsScreen extends StatelessWidget {
  const SleepProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = sleepProgramsMock.firstWhere((p) => p.currentDay > 0,
        orElse: () => sleepProgramsMock.first);

    return ScreenWrapper(
      child: Column(
        children: [
          RegularAppBar(title: 'sleep_programs_screen.title'.tr()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.15),
                        AppColors.accentSecondary.withOpacity(0.08),
                      ],
                    ),
                    border:
                        Border.all(color: AppColors.accentPrimary.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.mint,
                            ),
                          ),
                          AppSpacerW(6.w),
                          Text('sleep_programs_screen.in_progress'.tr(),
                              style: AppTextDecor.tagBadge11
                                  .copyWith(color: AppColors.mint)),
                        ],
                      ),
                      AppSpacerH(6.h),
                      Text(active.titleKey.tr(), style: AppTextDecor.heading3_17),
                      AppSpacerH(2.h),
                      Text(active.subtitleKey.tr(),
                          style: AppTextDecor.caption13Muted),
                      AppSpacerH(12.h),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2.r),
                              child: LinearProgressIndicator(
                                value: active.progress,
                                minHeight: 4.h,
                                backgroundColor: AppColors.divider,
                                color: AppColors.accentPrimary,
                              ),
                            ),
                          ),
                          AppSpacerW(10.w),
                          Text(
                              'sleep_programs_screen.day_x_of_y'.tr(namedArgs: {
                                'day': '${active.currentDay}',
                                'total': '${active.totalDays}',
                              }),
                              style: AppTextDecor.tagBadge11
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacerH(20.h),
                Text('sleep_programs_screen.all_programs'.tr(),
                    style: AppTextDecor.heading3_17),
                AppSpacerH(10.h),
                ...sleepProgramsMock.map((program) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: GestureDetector(
                        onTap: () {
                          if (program.isPro) showPremiumDialouge(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accentSecondary,
                                      AppColors.mint
                                    ],
                                  ),
                                ),
                              ),
                              AppSpacerW(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(program.titleKey.tr(),
                                        style: AppTextDecor.bodyTitle15),
                                    Text(program.subtitleKey.tr(),
                                        style: AppTextDecor.caption13Muted,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    if (program.currentDay > 0) ...[
                                      AppSpacerH(6.h),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2.r),
                                        child: LinearProgressIndicator(
                                          value: program.progress,
                                          minHeight: 3.h,
                                          backgroundColor: AppColors.divider,
                                          color: AppColors.accentSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (program.isPro) const ProBadge(),
                            ],
                          ),
                        ),
                      ),
                    )),
                AppSpacerH(24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
