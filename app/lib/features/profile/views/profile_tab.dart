import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/config/config.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/features/auth/logic/auth_provider.dart';
import 'package:medyo/features/wellness/mock/achievements_mock_data.dart';
import 'package:medyo/features/wellness/mock/profile_stats_mock_data.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../favourites/views/favourites_tab.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.userBox).listenable(),
        builder: (BuildContext context, Box userBox, Widget? child) {
          // final bool isPremium = userBox.get(AppHSC.premium);
          return ValueListenableBuilder(
              valueListenable: Hive.box(AppHSC.authBox).listenable(),
              builder: (BuildContext context, Box authbox, Widget? child) {
                return Column(
                  children: [
                    AppSpacerH(60.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          authbox.get(AppHSC.authToken) != null
                              ? SizedBox(
                                  height: 64.h,
                                  width: 64.h,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.h),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                userBox.get(AppHSC.thumbnail),
                                            height: 64.h,
                                            width: 64.h,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url,
                                                    error) =>
                                                const Center(
                                                    child: Icon(Icons.error)),
                                          )),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(32.h),
                                            border: Border.all(
                                                color: AppColors.textPrimary,
                                                width: 1.w)),
                                        height: 64.h,
                                        width: 64.h,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            showProfilePictureDialuge(context);
                                          },
                                          child: Container(
                                            height: 24.h,
                                            width: 24.h,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.h),
                                                color: AppColors.textPrimary),
                                            child: Center(
                                                child: Icon(
                                              Icons.camera_alt,
                                              color: AppColors.black,
                                              size: 18.h,
                                            )),
                                          ),
                                        ),
                                      )
                                    ],
                                  ))
                              : SizedBox(
                                  height: 64.h,
                                  width: 64.h,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(32.h),
                                          child: Icon(
                                            Icons.person,
                                            size: 64.h,
                                            color: AppColors.textPrimary,
                                          )),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(32.h),
                                          border: Border.all(
                                            color: AppColors.textPrimary,
                                            width: 1.w,
                                          ),
                                        ),
                                        height: 64.h,
                                        width: 64.h,
                                      ),
                                      //
                                    ],
                                  ),
                                ),
                          AppSpacerW(16.w),
                          authbox.get(AppHSC.authToken) != null
                              ? Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${userBox.get(AppHSC.firstName)}",
                                        style: AppTextDecor.heading3_17,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${userBox.get(AppHSC.email)}",
                                              style:
                                                  AppTextDecor.caption13Muted,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (userBox.get(AppHSC.verified) !=
                                              true) ...[
                                            AppSpacerW(8.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                color: AppColors.inputBg,
                                              ),
                                              child: ref
                                                  .watch(
                                                      verificationMailProvider)
                                                  .map(
                                                    initial: (_) =>
                                                        GestureDetector(
                                                      onTap: () {
                                                        ref
                                                            .watch(
                                                                verificationMailProvider
                                                                    .notifier)
                                                            .verificationMail();
                                                      },
                                                      child: Text(
                                                        'profile_screen.send_mail'
                                                            .tr(),
                                                        style: AppTextDecor
                                                            .caption12,
                                                      ),
                                                    ),
                                                    loading: (_) =>
                                                        const LoadingWidget(),
                                                    loaded: (_) {
                                                      return Text(
                                                        'profile_screen.send_code'
                                                            .tr(),
                                                        style: AppTextDecor
                                                            .caption12,
                                                      );
                                                    },
                                                    error: (_) =>
                                                        const ErrorTextWidget(
                                                            error: 'Error'),
                                                  ),
                                            ),
                                          ],
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    context.nav.pushNamed(Routes.loginScreen);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: AppColors.accentPrimary,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    minimumSize: Size(150.w, 50.h),
                                    alignment: Alignment.center,
                                  ),
                                  child: Text(
                                    "login_screen.login".tr(),
                                    style: AppTextDecor.bodyTitle16,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    if (authbox.get(AppHSC.authToken) != null) ...[
                      AppSpacerH(20.h),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _ProfileStatsRow(),
                      ),
                      AppSpacerH(20.h),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _AchievementsRow(),
                      ),
                    ],
                    AppSpacerH(24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Column(
                              children: [
                                if (userBox.get(AppHSC.premium) == false)
                                  ProfileTabWidget(
                                    svgPath: "assets/svgs/icon_star.svg",
                                    title: "My Subscription",
                                    onTap: () {
                                      context.nav
                                          .pushNamed(Routes.mySubScreen);
                                    },
                                  ),
                                if (userBox.get(AppHSC.premium) == false)
                                  ProfileTabWidget(
                                    svgPath: "assets/svgs/crown.svg",
                                    title: 'profile_screen.subscription_plans'
                                        .tr(),
                                    onTap: () {
                                      context.nav.pushNamed(
                                          Routes.premiumSubScreen);
                                    },
                                  ),
                                if (authbox.get(AppHSC.authToken) != null)
                                  ProfileTabWidget(
                                    svgPath: "assets/svgs/icon_herat.svg",
                                    title: "Favourites".tr(),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const FavouritesTab()));
                                    },
                                  ),
                                ProfileTabWidget(
                                  iconOverride: Icons.settings_outlined,
                                  svgPath: "",
                                  title: "settings_screen.title".tr(),
                                  onTap: () {
                                    context.nav
                                        .pushNamed(Routes.settingsScreen);
                                  },
                                ),
                                ProfileTabWidget(
                                  svgPath: "assets/svgs/icon_share.svg",
                                  title: "profile_screen.invite_friend".tr(),
                                  onTap: () async {
                                    final box =
                                        context.findRenderObject() as RenderBox?;
                                    try {
                                      await Share.share(
                                        Platform.isIOS
                                            ? AppConfig.iosStoreUrl
                                            : AppConfig.androidStoreUrl,
                                        sharePositionOrigin: box != null
                                            ? box.localToGlobal(Offset.zero) &
                                                box.size
                                            : null,
                                      );
                                    } catch (e) {
                                      debugPrint('Share failed: $e');
                                    }
                                  },
                                ),
                                ProfileTabWidget(
                                  svgPath:
                                      "assets/svgs/icon_privacy_policy.svg",
                                  title: "profile_screen.privacy_policy".tr(),
                                  onTap: () {
                                    context.nav
                                        .pushNamed(Routes.privacyPolicy);
                                  },
                                ),
                                ProfileTabWidget(
                                  svgPath: "assets/svgs/icon_contact_us.svg",
                                  title: "profile_screen.contact_us".tr(),
                                  onTap: () {
                                    context.nav.pushNamed(Routes.contactUs);
                                  },
                                  isLast:
                                      authbox.get(AppHSC.authToken) == null,
                                ),
                                if (authbox.get(AppHSC.authToken) != null)
                                  ProfileTabWidget(
                                    svgPath:
                                        "assets/svgs/icon_change_pass.svg",
                                    title: "profile_screen.change_pass".tr(),
                                    onTap: () {
                                      context.nav.pushNamed(Routes.changePass);
                                    },
                                    isLast: true,
                                  ),
                              ],
                            ),
                          ),
                          if (authbox.get(AppHSC.authToken) != null) ...[
                            AppSpacerH(16.h),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Column(
                                children: [
                                  ProfileTabWidget(
                                    svgPath:
                                        "assets/svgs/icon_delete_account.svg",
                                    title: "profile_screen.delete_acc".tr(),
                                    onTap: () {
                                      showDeleteDialouge(context);
                                    },
                                    isDanger: true,
                                  ),
                                  ProfileTabWidget(
                                    svgPath: "assets/svgs/icon_logout.svg",
                                    title: "profile_screen.log_out".tr(),
                                    onTap: () {
                                      showLogoutDialouge(context);
                                    },
                                    isDanger: true,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          AppSpacerH(24.h),
                        ],
                      ),
                    )
                  ],
                );
              });
        });
  }
}

/// Nights-tracked / hours-listened / streak stats. No aggregation backend
/// exists yet — see profile_stats_mock_data.dart TODO.
class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: profileStatsMock
          .map((stat) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(stat.value, style: AppTextDecor.heading3_17),
                      AppSpacerH(2.h),
                      Text(stat.labelKey.tr(),
                          style: AppTextDecor.tagBadge11
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

/// Achievement badges. No unlock-tracking backend exists yet — every badge
/// renders in its locked state. See achievements_mock_data.dart TODO.
class _AchievementsRow extends StatelessWidget {
  const _AchievementsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('profile_screen.achievements'.tr(),
            style: AppTextDecor.heading3_17),
        AppSpacerH(10.h),
        Row(
          children: achievementBadgesMock
              .map((badge) => Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: Column(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Icon(badge.icon,
                              color: AppColors.textTertiary, size: 20.sp),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class ProfileTabWidget extends StatelessWidget {
  const ProfileTabWidget({
    super.key,
    required this.svgPath,
    required this.title,
    this.onTap,
    this.trailing,
    this.isDanger = false,
    this.isLast = false,
    this.iconOverride,
  });
  final String svgPath;
  final String title;
  final Function()? onTap;
  final Widget? trailing;
  final bool isDanger;
  final bool isLast;
  final IconData? iconOverride;

  @override
  Widget build(BuildContext context) {
    final tint = isDanger ? AppColors.danger : AppColors.accentPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: iconOverride != null
                  ? Icon(iconOverride, color: tint, size: 16.sp)
                  : Padding(
                      padding: EdgeInsets.all(6.w),
                      child: SvgPicture.asset(
                        svgPath,
                        fit: BoxFit.contain,
                        color: tint,
                      ),
                    ),
            ),
            AppSpacerW(12.w),
            Expanded(
                child: Text(
              title,
              style: AppTextDecor.bodyTitle15
                  .copyWith(color: isDanger ? AppColors.danger : null),
            )),
            if (trailing != null)
              trailing!
            else
              Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
