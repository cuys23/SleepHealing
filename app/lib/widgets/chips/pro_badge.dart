import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';

/// Gradient "PRO" pill badge shown on premium-gated content across Sleep
/// Programs, Premium, and Profile.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        gradient: const LinearGradient(
          colors: [AppColors.softGold, AppColors.rose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        'common.pro'.tr(),
        style: AppTextDecor.tagBadge11.copyWith(
          color: AppColors.bgPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
