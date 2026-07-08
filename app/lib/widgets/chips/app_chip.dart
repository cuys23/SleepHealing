import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';

/// Selected/unselected pill chip, reused by Search filters, Meditation
/// duration chips, and Sleep Programs status chips.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: selected
              ? AppColors.accentPrimary.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          border: selected
              ? Border.all(color: AppColors.accentPrimary.withOpacity(0.25))
              : null,
        ),
        child: Text(
          label,
          style: AppTextDecor.tagBadge11.copyWith(
            color: selected ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
