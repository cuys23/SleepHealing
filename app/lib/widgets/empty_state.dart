import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/misc_widgets.dart';

/// Shared empty-state layout: icon badge + title + subtitle + optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    this.ctaLabelKey,
    this.onCtaTap,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final String? ctaLabelKey;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withOpacity(0.12),
                    AppColors.accentSecondary.withOpacity(0.06),
                  ],
                ),
              ),
              child: Icon(icon, size: 40.sp, color: AppColors.accentPrimary),
            ),
            AppSpacerH(24.h),
            Text(titleKey.tr(),
                textAlign: TextAlign.center, style: AppTextDecor.heading3_17),
            AppSpacerH(8.h),
            Text(subtitleKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextDecor.caption13Muted),
            if (ctaLabelKey != null) ...[
              AppSpacerH(28.h),
              AppTextButton(
                width: 200.w,
                title: ctaLabelKey!.tr(),
                onTap: onCtaTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
