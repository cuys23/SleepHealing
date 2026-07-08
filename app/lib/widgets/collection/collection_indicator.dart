import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';

/// Row of tappable dots reflecting [currentIndex] out of [count].
/// The active dot elongates (AnimatedContainer) and pops (AnimatedScale).
class CollectionIndicator extends StatelessWidget {
  const CollectionIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.onDotTap,
  });

  final int count;
  final int currentIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: () => onDotTap(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: isActive ? 20.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accentPrimary
                      : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
