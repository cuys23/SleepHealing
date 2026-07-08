import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/brand_logo.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(2000.milisec).then((value) {
      final Box appSettingsBox = Hive.box(
        AppHSC.appSettingsBox,
      );
      context.nav.pushNamedAndRemoveUntil(
        appSettingsBox.get(AppHSC.hasSeenOnBoardingScreen) == true
            ? Routes.homeScreen
            : Routes.onBoardingScreen,
        (route) => false,
      );
      // context.nav.pushNamedAndRemoveUntil(
      //   (authBox.get(AppHSC.authToken) != null &&
      //           authBox.get(AppHSC.authToken) != '')
      //       ? Routes.homeScreen
      //       : Routes.onBoardingScreen,
      //   (route) => false,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
        child: Stack(
      children: [
        Container(
          height: 844.h,
          width: 390.w,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 0.9,
              colors: [Color(0xFF1A1040), AppColors.bgPrimary],
              stops: [0, 0.7],
            ),
          ),
        ),
        Center(
          child: Hero(
            tag: "LOGO",
            child: BrandLogo(size: 96.w, showText: true),
          ),
        ),
      ],
    ));
  }
}
