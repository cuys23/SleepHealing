import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';

class AppTextButton extends StatefulWidget {
  const AppTextButton({
    Key? key,
    this.width = double.infinity,
    this.height,
    this.buttonColor,
    required this.title,
    this.onTap,
    this.titleColor,
  }) : super(key: key);
  final double? width;
  final double? height;

  /// Explicit solid background color. When null, the primary gradient
  /// (Soft Purple → Sky Blue) from the design system is used instead.
  final Color? buttonColor;
  final String title;
  final Color? titleColor;
  final Function()? onTap;

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final useGradient = widget.buttonColor == null;
    final shadowColor = widget.buttonColor ?? AppColors.accentPrimary;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: widget.height ?? 54.h,
          width: widget.width,
          decoration: BoxDecoration(
            color: useGradient ? null : widget.buttonColor,
            gradient: useGradient
                ? const LinearGradient(
                    colors: [
                      AppColors.accentPrimary,
                      AppColors.accentSecondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: AppTextDecor.bodyTitle16
                  .copyWith(color: widget.titleColor ?? AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
