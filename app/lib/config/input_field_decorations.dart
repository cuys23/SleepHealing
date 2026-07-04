import 'package:flutter/material.dart';
import 'package:medyo/config/app_colors.dart';

class AppInputDecor {
  AppInputDecor._(); // This class is not meant to be instantiated.

  static InputDecoration dgBordered = InputDecoration(
    isDense: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 13,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w400),
    filled: true,
    fillColor: AppColors.inputBg,
    labelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w500),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AppColors.accentPrimary,
        width: 1.2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AppColors.danger,
      ),
    ),
  );
}
