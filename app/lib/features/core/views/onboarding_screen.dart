import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/collection/collection_indicator.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.titleKey,
    required this.textKey,
    required this.gradient,
  });

  final String titleKey;
  final String textKey;
  final Gradient gradient;
}

const _pages = [
  _OnboardingPageData(
    titleKey: 'onboarding_screen.page1_title',
    textKey: 'onboarding_screen.page1_text',
    gradient: LinearGradient(
      colors: [AppColors.accentPrimary, AppColors.accentSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _OnboardingPageData(
    titleKey: 'onboarding_screen.page2_title',
    textKey: 'onboarding_screen.page2_text',
    gradient: LinearGradient(
      colors: [AppColors.mint, AppColors.accentSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _OnboardingPageData(
    titleKey: 'onboarding_screen.page3_title',
    textKey: 'onboarding_screen.page3_text',
    gradient: LinearGradient(
      colors: [Color(0xFF1A1040), AppColors.accentPrimary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  final Box appSettingsBox = Hive.box(AppHSC.appSettingsBox);
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    appSettingsBox.put(AppHSC.hasSeenOnBoardingScreen, true);
    context.nav.pushNamedAndRemoveUntil(
      Routes.homeScreen,
      (route) => false,
    );
  }

  void _onCtaTap() {
    final isLastPage = _pageIndex == _pages.length - 1;
    if (isLastPage) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Container(
        height: 844.h,
        width: 390.w,
        color: AppColors.bgPrimary,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, index) {
                  return _OnboardingOrb(gradient: _pages[index].gradient);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w).copyWith(
                bottom: 36.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _pages[_pageIndex].titleKey.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextDecor.heading1_30.copyWith(height: 1.25),
                  ),
                  AppSpacerH(12.h),
                  Text(
                    _pages[_pageIndex].textKey.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextDecor.body15.copyWith(height: 1.6),
                  ),
                  AppSpacerH(24.h),
                  CollectionIndicator(
                    count: _pages.length,
                    currentIndex: _pageIndex,
                    onDotTap: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                  AppSpacerH(24.h),
                  AppTextButton(
                    title: "onboarding_screen.btn_text".tr(),
                    onTap: _onCtaTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative floating gradient orb shown per onboarding page, matching the
/// design's abstract circle-with-particles motif (no real illustration asset
/// exists yet — TODO: swap for real per-page artwork once product supplies it).
class _OnboardingOrb extends StatefulWidget {
  const _OnboardingOrb({required this.gradient});

  final Gradient gradient;

  @override
  State<_OnboardingOrb> createState() => _OnboardingOrbState();
}

class _OnboardingOrbState extends State<_OnboardingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final offset = Curves.easeInOut.transform(_floatController.value);
          return Transform.translate(
            offset: Offset(0, -10 * offset),
            child: child,
          );
        },
        child: Container(
          width: 160.w,
          height: 160.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.35),
                blurRadius: 80,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
