import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/wellness/mock/statistics_mock_data.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

/// No sleep-tracking backend exists yet — see statistics_mock_data.dart.
/// The Week/Month/Year selector is local UI state only; every period shows
/// the same representative sample values today.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

enum _Period { week, month, year }

class _StatisticsScreenState extends State<StatisticsScreen> {
  _Period _period = _Period.month;

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Column(
        children: [
          RegularAppBar(title: 'statistics_screen.title'.tr()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: _Period.values
                        .map((p) => Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _period = p),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 7.h),
                                  decoration: BoxDecoration(
                                    color: _period == p
                                        ? AppColors.accentPrimary
                                            .withOpacity(0.15)
                                        : null,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'statistics_screen.period_${p.name}'.tr(),
                                    textAlign: TextAlign.center,
                                    style: AppTextDecor.tagBadge11.copyWith(
                                      color: _period == p
                                          ? AppColors.textSecondary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                AppSpacerH(18.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        labelKey: 'statistics_screen.avg_score',
                        value: '76',
                        gradient: true,
                      ),
                    ),
                    AppSpacerW(10.w),
                    Expanded(
                      child: _SummaryCard(
                        labelKey: 'statistics_screen.avg_duration',
                        value: '7h 18m',
                        gradient: false,
                      ),
                    ),
                  ],
                ),
                AppSpacerH(18.h),
                Text('statistics_screen.insights'.tr(),
                    style: AppTextDecor.heading3_17),
                AppSpacerH(10.h),
                ...statInsightsMock.map((insight) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: (insight.isPositive
                                  ? AppColors.mint
                                  : AppColors.softGold)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: (insight.isPositive
                                    ? AppColors.mint
                                    : AppColors.softGold)
                                .withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: insight.isPositive
                                        ? AppColors.mint
                                        : AppColors.softGold,
                                  ),
                                ),
                                AppSpacerW(6.w),
                                Text(
                                  insight.labelKey.tr(),
                                  style: AppTextDecor.tagBadge11.copyWith(
                                    color: insight.isPositive
                                        ? AppColors.mint
                                        : AppColors.softGold,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacerH(4.h),
                            Text(insight.messageKey.tr(),
                                style: AppTextDecor.caption13Muted),
                          ],
                        ),
                      ),
                    )),
                AppSpacerH(8.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.1),
                        AppColors.accentSecondary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) => const LinearGradient(
                          colors: [
                            AppColors.accentPrimary,
                            AppColors.accentSecondary
                          ],
                        ).createShader(rect),
                        child: Text('12',
                            style: AppTextDecor.display40
                                .copyWith(fontSize: 28.sp, color: Colors.white)),
                      ),
                      AppSpacerW(12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('statistics_screen.day_streak'.tr(),
                              style: AppTextDecor.bodyTitle15),
                          Text('statistics_screen.keep_it_going'.tr(),
                              style: AppTextDecor.caption13Muted),
                        ],
                      ),
                    ],
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.labelKey, required this.value, required this.gradient});

  final String labelKey;
  final String value;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelKey.tr(), style: AppTextDecor.caption13Muted),
          AppSpacerH(4.h),
          gradient
              ? ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [AppColors.accentPrimary, AppColors.accentSecondary],
                  ).createShader(rect),
                  child: Text(value,
                      style: AppTextDecor.heading1_30
                          .copyWith(fontSize: 24.sp, color: Colors.white)),
                )
              : Text(value, style: AppTextDecor.heading1_30.copyWith(fontSize: 24.sp)),
        ],
      ),
    );
  }
}
