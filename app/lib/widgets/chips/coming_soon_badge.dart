import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';

/// Small muted pill marking a UI element as not yet backed by real
/// functionality (no backend/engine support). Pair with dimmed opacity
/// and/or IgnorePointer on the element itself so it also behaves inert,
/// not just looks it.
class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: AppColors.inputBg,
      ),
      child: Text(
        'common.coming_soon'.tr(),
        style: AppTextDecor.tagBadge11.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
