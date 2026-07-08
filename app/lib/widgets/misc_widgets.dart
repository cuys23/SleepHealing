import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';

class AppSpacerH extends StatelessWidget {
  const AppSpacerH(
    this.height, {
    Key? key,
  }) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}

class AppSpacerW extends StatelessWidget {
  const AppSpacerW(
    this.width, {
    Key? key,
  }) : super(key: key);
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}

class AppDividerV extends StatelessWidget {
  const AppDividerV({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 3.0,
      child: Center(
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
          width: width != null ? width! / 2 : 1.0,
          height: height ?? 10.h,
          color: AppColors.gray,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomSeprator extends StatelessWidget {
  CustomSeprator({Key? key, this.color, this.height, this.width})
      : super(key: key);
  Color? color;
  double? height;
  double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1.h,
      width: width ?? double.infinity,
      color: color ?? AppColors.offWhite,
    );
  }
}

class ErrorTextWidget extends StatelessWidget {
  const ErrorTextWidget({Key? key, required this.error}) : super(key: key);
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.danger.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 16.sp, color: AppColors.danger),
            AppSpacerW(8.w),
            Flexible(
              child: Text(
                error.toString().tr(),
                style: AppTextDecor.tagBadge11
                    .copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTextWidget extends StatelessWidget {
  const MessageTextWidget({Key? key, required this.msg}) : super(key: key);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg.toString().tr(),
        style: AppTextDecor.caption13Muted,
      ),
    );
  }
}

/// Small inline spinner by default; a shimmering skeleton bar when [showBG]
/// is true (for full-width list/section loading placeholders).
class LoadingWidget extends StatefulWidget {
  const LoadingWidget({Key? key, this.showBG = false}) : super(key: key);
  final bool showBG;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBG) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.accentPrimary,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: 64.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              begin: Alignment(-1 - _controller.value * 2, 0),
              end: Alignment(1 - _controller.value * 2, 0),
              colors: const [
                AppColors.surface,
                AppColors.twilight,
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

class HorizontalDivider extends StatelessWidget {
  const HorizontalDivider({Key? key, this.color}) : super(key: key);
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.h,
      width: double.infinity,
      color: color ?? AppColors.white.withOpacity(0.2),
    );
  }
}
