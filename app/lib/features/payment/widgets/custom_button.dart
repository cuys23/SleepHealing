// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';

class CustomButtons extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final Color buttonTextColor;
  final void Function()? onPressed;

  const CustomButtons({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.buttonColor,
    this.buttonTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        backgroundColor:
            WidgetStateProperty.all(buttonColor ?? AppColors.primaryColor),
        minimumSize: WidgetStateProperty.all(
          Size(double.infinity, 50.h),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: buttonTextColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
