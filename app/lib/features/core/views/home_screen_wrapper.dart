import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/views/bottom_player.dart';
import 'package:medyo/features/core/views/explore_tab.dart';
import 'package:medyo/features/core/views/menu_page.dart';
import 'package:medyo/features/profile/views/profile_tab.dart';
import 'package:medyo/features/wellness/views/sleep_tracker_screen.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/widgets/home_app_bar.dart';
import 'package:medyo/widgets/misc_widgets.dart';

class HomeScreenWrapper extends ConsumerStatefulWidget {
  const HomeScreenWrapper({super.key, this.padding});

  final EdgeInsets? padding;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends ConsumerState<HomeScreenWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(50.milisec).then((value) {
      ref.read(userProvider.notifier).getUser();
    });
  }

  int selcetedIndex = 0;
  bool isappbar = true;
  @override
  Widget build(BuildContext context) {
    AppGLF.changeStatusBarColor(color: Colors.transparent);
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.appBox).listenable(),
        builder: (context, Box appBox, Widget? child) {
          int? savedColorValue = appBox.get('saved_color');
          if (savedColorValue != null) {
            AppColors.darkTeal = Color(savedColorValue);
          }
          return Scaffold(
            extendBody: true,
            bottomNavigationBar: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 83.h,
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.tabBarBg,
                    border: Border(
                      top: BorderSide(color: AppColors.divider, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomePageBottomBarItem(
                        onTap: () {
                          setState(() {
                            selcetedIndex = 0;
                            isappbar = true;
                          });
                        },
                        isSelected: selcetedIndex == 0,
                        iconData: Icons.home_rounded,
                        label: "Home",
                      ),
                      HomePageBottomBarItem(
                        onTap: () {
                          setState(() {
                            selcetedIndex = 1;
                            isappbar = true;
                          });
                        },
                        isSelected: selcetedIndex == 1,
                        svgPath: "assets/svgs/menu_icon.svg",
                        label: "Explore",
                      ),
                      HomePageBottomBarItem(
                        onTap: () {
                          setState(() {
                            selcetedIndex = 2;
                            isappbar = true;
                          });
                        },
                        isSelected: selcetedIndex == 2,
                        iconData: Icons.nights_stay_outlined,
                        label: "Sleep",
                      ),
                      HomePageBottomBarItem(
                        onTap: () {
                          setState(() {
                            selcetedIndex = 3;
                            isappbar = true;
                          });
                        },
                        isSelected: selcetedIndex == 3,
                        svgPath: "assets/svgs/icon_user.svg",
                        label: "Profile",
                      )
                    ],
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                Container(
                  padding: widget.padding ?? EdgeInsets.zero,
                  height: 844.h,
                  width: 390.w,
                  color: AppColors.darkTeal,
                  child: Column(
                    children: [
                      isappbar == false
                          ? HomeAppBar(
                              onProfiletap: () {
                                setState(() {
                                  selcetedIndex = 3;
                                });
                              },
                            )
                          : selcetedIndex == 1
                              ? AppSpacerH(40.h)
                              : const SizedBox(),
                      Expanded(
                        child: IndexedStack(
                          index: selcetedIndex,
                          children: const [
                            MenuPage(),
                            ExploreTab(),
                            SleepTrackerScreen(),
                            ProfileTab()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                    duration: 500.milisec,
                    bottom: 119.h - ref.watch(bottomPlayerOffset('y')),
                    left: 0 + ref.watch(bottomPlayerOffset('x')),
                    child: const BottomPlayerControl())
              ],
            ),
          );
        });
  }
}

class HomePageBottomBarItem extends StatelessWidget {
  const HomePageBottomBarItem(
      {super.key,
      this.onTap,
      this.isSelected = false,
      this.svgPath,
      this.iconData,
      required this.label});
  final Function()? onTap;
  final bool isSelected;
  final String? svgPath;
  final IconData? iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColors.accentPrimary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.1 : 1,
            duration: 200.milisec,
            child: iconData != null
                ? Icon(iconData, color: color, size: 22.h)
                : SvgPicture.asset(
                    svgPath!,
                    color: color,
                    fit: BoxFit.cover,
                    height: 22.h,
                  ),
          ),
          SizedBox(height: 4.h),
          AnimatedDefaultTextStyle(
            duration: 200.milisec,
            style: AppTextDecor.tabBarLabel10.copyWith(color: color),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
