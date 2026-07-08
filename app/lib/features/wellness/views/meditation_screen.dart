import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/wellness/mock/meditation_mock_data.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/widgets/chips/app_chip.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/progress/circular_progress_ring.dart';

/// Guided meditation countdown timer. The timer itself is real (local
/// Dart Timer, no fake progress) — only the session title/benefits copy is
/// placeholder content (see meditation_mock_data.dart TODO), since there is
/// no dedicated meditation-session content type in the catalog yet.
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  int _selectedMinutes = 15;
  late Duration _remaining = Duration(minutes: _selectedMinutes);
  Timer? _timer;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    _timer?.cancel();
    setState(() {
      _selectedMinutes = minutes;
      _remaining = Duration(minutes: minutes);
      _running = false;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _running = false;
        });
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = Duration(minutes: _selectedMinutes).inSeconds;
    final progress =
        total == 0 ? 0.0 : 1 - (_remaining.inSeconds / total);
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              AppSpacerH(8.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.nav.pop(),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 16.sp, color: AppColors.textPrimary),
                  ),
                  AppSpacerW(10.w),
                  Text('meditation_screen.title'.tr(),
                      style: AppTextDecor.bodyTitle16),
                ],
              ),
              const Spacer(),
              CircularProgressRing(
                progress: progress,
                size: 200.w,
                strokeWidth: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$minutes:$seconds',
                        style: AppTextDecor.heading1_30
                            .copyWith(fontSize: 32.sp)),
                    Text('meditation_screen.remaining'.tr(),
                        style: AppTextDecor.caption13Muted),
                  ],
                ),
              ),
              AppSpacerH(24.h),
              Text(meditationSessionTitleKey.tr(),
                  style: AppTextDecor.heading3_17),
              AppSpacerH(4.h),
              Text(meditationSessionSubtitleKey.tr(),
                  style: AppTextDecor.caption13Muted),
              AppSpacerH(20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: meditationDurationsMinutes
                    .map((m) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: AppChip(
                            label: '$m ${'player_screen.minutes'.tr()}',
                            selected: _selectedMinutes == m,
                            onTap: () => _selectDuration(m),
                          ),
                        ))
                    .toList(),
              ),
              AppSpacerH(28.h),
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPrimary, AppColors.accentSecondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _running ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ),
              AppSpacerH(24.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    Text('meditation_screen.session_benefits'.tr(),
                        style: AppTextDecor.caption13Muted),
                    AppSpacerH(4.h),
                    Text(meditationBenefitsKey.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextDecor.tagBadge11
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              AppSpacerH(16.h),
            ],
          ),
        ),
      ),
    );
  }
}
