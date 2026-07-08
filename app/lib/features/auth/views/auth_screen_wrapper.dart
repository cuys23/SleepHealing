import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

class AuthScreenWrapper extends StatelessWidget {
  const AuthScreenWrapper({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
        showBottomPlayer: false,
        child: Stack(
          children: [
            // Ambient glow behind the auth card, matching the design's soft
            // purple halo style (Phase 1 "Soft Glow" token language).
            Positioned(
              top: -80.h,
              left: -60.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentPrimary.withOpacity(0.18),
                      AppColors.accentPrimary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: Image.asset("assets/images/auth_overlay.png")),
            SizedBox(
              height: 844.h,
              width: 390.w,
              child: child,
            )
          ],
        ));
  }
}
