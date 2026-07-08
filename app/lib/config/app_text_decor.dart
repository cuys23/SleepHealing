import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';

class AppTextDecor {
  AppTextDecor._();
  //Open Sans
  //Regular

  static TextStyle regular18White = TextStyle(
    color: AppColors.white,
    fontSize: 18.sp,
  );
  static TextStyle regular18lightGeay = TextStyle(
    color: AppColors.lightGeay,
    fontSize: 18.sp,
  );
  static TextStyle regular16White = TextStyle(
    color: AppColors.white,
    fontSize: 16.sp,
  );
  static TextStyle regular14lightGeay = TextStyle(
    color: AppColors.lightGeay,
    fontSize: 14.sp,
  );
  static TextStyle regular14White = TextStyle(
    color: AppColors.white,
    fontSize: 14.sp,
  );
  static TextStyle regular14Black = TextStyle(
    color: AppColors.black,
    fontSize: 14.sp,
  );
  static TextStyle regular12lightGeay = TextStyle(
    color: AppColors.lightGeay,
    fontSize: 12.sp,
  );
  static TextStyle regular12Gray = TextStyle(
    color: AppColors.gray,
    fontSize: 12.sp,
  );
  static TextStyle regular12White = TextStyle(
    color: AppColors.white,
    fontSize: 12.sp,
  );

  //Semi Bold

  static TextStyle semiBold20White = TextStyle(
    color: AppColors.white,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle semiBold16White = TextStyle(
    color: AppColors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );
  //Medium

  static TextStyle medium14Red = TextStyle(
    color: AppColors.red,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle medium18White = TextStyle(
    color: AppColors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
  );

  //Bold
  static TextStyle bold36White = TextStyle(
    color: AppColors.white,
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bold32White = TextStyle(
    color: AppColors.white,
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bold24White = TextStyle(
    color: AppColors.white,
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bold20White = TextStyle(
    color: AppColors.white,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bold18White = TextStyle(
    color: AppColors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bold16White = TextStyle(
    color: AppColors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bold14White = TextStyle(
    color: AppColors.white,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle bold12White = TextStyle(
    color: AppColors.white,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  // ---- SleepHealing design system (Plus Jakarta Sans) ----
  static const String _fontFamily = 'Plus Jakarta Sans';

  static TextStyle display40 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 40.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
  );
  static TextStyle heading1_30 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
  );
  static TextStyle heading2_22 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
  );
  static TextStyle heading3_17 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle body15 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
  );
  static TextStyle caption13Muted = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textMuted,
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle overline11 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textTertiary,
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  // Legacy Deep-Calm-era names kept as aliases so already-migrated screens
  // keep compiling unchanged; new screens should use the canonical names above.
  static TextStyle largeTitle28 = heading1_30;
  static TextStyle sectionHeader20 = heading2_22;
  static TextStyle sectionHeader22 = heading2_22;
  static TextStyle bodyTitle15 = body15;
  static TextStyle bodyTitle16 = heading3_17;
  static TextStyle caption12 = caption13Muted;
  static TextStyle caption13 = caption13Muted;
  static TextStyle tagBadge11 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle tabBarLabel10 = TextStyle(
    fontFamily: _fontFamily,
    color: AppColors.textMuted,
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
  );
}
