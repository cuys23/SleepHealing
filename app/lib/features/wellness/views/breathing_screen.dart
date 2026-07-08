import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/widgets/misc_widgets.dart';

enum _BreathPhase { inhale, hold, exhale }

const _phaseDurations = {
  _BreathPhase.inhale: 4,
  _BreathPhase.hold: 7,
  _BreathPhase.exhale: 8,
};

const _totalRounds = 8;

/// 4-7-8 breathing exercise. The phase timing is a real, hardcoded
/// technique (not user data), driven purely by local animation state.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  _BreathPhase _phase = _BreathPhase.inhale;
  int _round = 1;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _phaseDurations[_phase]!),
    )..addStatusListener(_onStatusChanged);
    _controller.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      if (_phase == _BreathPhase.exhale) {
        if (_round >= _totalRounds) {
          _round = 1;
        } else {
          _round++;
        }
        _phase = _BreathPhase.inhale;
      } else if (_phase == _BreathPhase.inhale) {
        _phase = _BreathPhase.hold;
      } else {
        _phase = _BreathPhase.exhale;
      }
    });
    _controller.duration = Duration(seconds: _phaseDurations[_phase]!);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _phaseLabelKey {
    switch (_phase) {
      case _BreathPhase.inhale:
        return 'breathing_screen.breathe_in';
      case _BreathPhase.hold:
        return 'breathing_screen.hold';
      case _BreathPhase.exhale:
        return 'breathing_screen.breathe_out';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text('breathing_screen.title'.tr(),
                      style: AppTextDecor.bodyTitle16),
                ],
              ),
              AppSpacerH(4.h),
              Text('breathing_screen.technique'.tr(),
                  style: AppTextDecor.caption13Muted),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = _phase == _BreathPhase.hold
                          ? 1.0
                          : _phase == _BreathPhase.inhale
                              ? 0.7 + 0.3 * _controller.value
                              : 1.0 - 0.3 * _controller.value;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 170.w,
                      height: 170.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.accentPrimary.withOpacity(0.25),
                          AppColors.accentSecondary.withOpacity(0.1),
                        ]),
                      ),
                      child: Container(
                        width: 90.w,
                        height: 90.w,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentPrimary,
                              AppColors.accentSecondary
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_phaseLabelKey.tr(),
                                style: AppTextDecor.bodyTitle15
                                    .copyWith(color: Colors.white)),
                            Text(
                              '${_phaseDurations[_phase]}',
                              style: AppTextDecor.heading1_30
                                  .copyWith(fontSize: 26.sp, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PatternLegend(
                      value: '4s',
                      labelKey: 'breathing_screen.inhale',
                      color: AppColors.accentPrimary),
                  _PatternLegend(
                      value: '7s',
                      labelKey: 'breathing_screen.hold',
                      color: AppColors.accentSecondary),
                  _PatternLegend(
                      value: '8s',
                      labelKey: 'breathing_screen.exhale',
                      color: AppColors.mint),
                ],
              ),
              AppSpacerH(16.h),
              Row(
                children: [
                  Text(
                      'breathing_screen.round'
                          .tr(namedArgs: {'n': '$_round', 'total': '$_totalRounds'}),
                      style: AppTextDecor.caption13Muted),
                  AppSpacerW(12.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: _round / _totalRounds,
                        minHeight: 3.h,
                        backgroundColor: AppColors.divider,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacerH(16.h),
              GestureDetector(
                onTap: () => context.nav.pop(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text('breathing_screen.end_session'.tr(),
                        style: AppTextDecor.bodyTitle16),
                  ),
                ),
              ),
              AppSpacerH(12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatternLegend extends StatelessWidget {
  const _PatternLegend(
      {required this.value, required this.labelKey, required this.color});
  final String value;
  final String labelKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextDecor.heading3_17.copyWith(color: color)),
        Text(labelKey.tr(),
            style: AppTextDecor.tagBadge11.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
