import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/other/mock/notifications_mock_data.dart';
import 'package:medyo/widgets/empty_state.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

/// No notification-history backend exists yet — see
/// notifications_mock_data.dart TODO. This does not affect push delivery,
/// which already works via firebase_messaging independent of this screen.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<NotificationItem>>{};
    for (final item in notificationsMock) {
      groups.putIfAbsent(item.group, () => []).add(item);
    }

    return ScreenWrapper(
      child: Column(
        children: [
          RegularAppBar(title: 'notifications_screen.title'.tr()),
          Expanded(
            child: notificationsMock.isEmpty
                ? EmptyState(
                    icon: Icons.notifications_none,
                    titleKey: 'notifications_screen.empty_title',
                    subtitleKey: 'notifications_screen.empty_subtitle',
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: groups.entries.expand((entry) {
                      return [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h, top: 8.h),
                          child: Text(entry.key.tr(),
                              style: AppTextDecor.tagBadge11
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        ...entry.value.map((item) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36.w,
                                      height: 36.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.r),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.accentPrimary,
                                            AppColors.accentSecondary
                                          ],
                                        ),
                                      ),
                                      child: Icon(item.icon,
                                          color: Colors.white, size: 16.sp),
                                    ),
                                    AppSpacerW(12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.titleKey.tr(),
                                              style: AppTextDecor.bodyTitle15),
                                          Text(item.bodyKey.tr(),
                                              style: AppTextDecor.caption13Muted),
                                        ],
                                      ),
                                    ),
                                    Text(item.timeKey.tr(),
                                        style: AppTextDecor.tagBadge11
                                            .copyWith(color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                            )),
                      ];
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
