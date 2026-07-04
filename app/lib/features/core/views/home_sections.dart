import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/logic/player_navigation.dart';
import 'package:medyo/features/core/models/dashboard_category_a_lbums_list/albam.dart'
    as hAlbam;
import 'package:medyo/services/local_storage_service.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/misc_widgets.dart';

/// Shows the in-progress track saved by [LocalStorageService], if any.
/// Tapping it re-opens the player and seeks back to the saved position.
class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(AppHSC.continueListeningBox).listenable(),
      builder: (context, Box box, _) {
        final data = LocalStorageService.getContinueListening();
        if (data == null) return const SizedBox();

        final positionMs = data['position'] as int? ?? 0;
        final durationMs = data['duration'] as int?;
        final position = Duration(milliseconds: positionMs);
        final progress = (durationMs != null && durationMs > 0)
            ? (positionMs / durationMs).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: GestureDetector(
            onTap: () =>
                openStoredTrack(context, ref, storedData: data, seekTo: position),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.gray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.gray.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: CachedNetworkImage(
                      imageUrl: data['thumbnail']?.toString() ?? '',
                      width: 56.w,
                      height: 56.h,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 56.w,
                        height: 56.h,
                        color: AppColors.gray.withOpacity(0.2),
                      ),
                    ),
                  ),
                  AppSpacerW(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('menu_screen.continue_listening'.tr(),
                            style: AppTextDecor.regular12Gray),
                        AppSpacerH(4.h),
                        Text(
                          data['title']?.toString() ?? '',
                          style: AppTextDecor.bold14White,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacerH(6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3.h,
                            backgroundColor: AppColors.gray.withOpacity(0.3),
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacerW(8.w),
                  const Icon(Icons.play_circle_fill,
                      color: AppColors.white, size: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal list of the last tracks the user played, backed by Hive.
class RecentlyPlayedSection extends ConsumerWidget {
  const RecentlyPlayedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(AppHSC.recentlyPlayedBox).listenable(),
      builder: (context, Box box, _) {
        final items = LocalStorageService.getRecentlyPlayed();
        if (items.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'menu_screen.recently_played'.tr(),
              style: AppTextDecor.bold14White
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacerH(8.h),
            SizedBox(
              height: 190.h,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () =>
                        openStoredTrack(context, ref, storedData: item),
                    child: Container(
                      width: 140.w,
                      margin: EdgeInsets.only(left: index == 0 ? 0 : 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: CachedNetworkImage(
                              imageUrl: item['thumbnail']?.toString() ?? '',
                              width: 140.w,
                              height: 120.h,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 140.w,
                                height: 120.h,
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                            ),
                          ),
                          AppSpacerH(8.h),
                          Text(
                            item['title']?.toString() ?? '',
                            style: AppTextDecor.bold12White,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            AppSpacerH(16.h),
          ],
        );
      },
    );
  }
}

/// Surfaces albums the backend already flags as `is_new` (created within the
/// last 15 days), pulled from the dashboard sections already fetched on Home
/// - no new endpoint involved.
class NewFeaturedSection extends ConsumerWidget {
  const NewFeaturedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended =
        ref.watch(dashboardcategoryalbumListProvider('Most Recomanded'));
    final timeOfDay = ref.watch(
        dashboardcategoryalbumListProvider(AppGLF.getTimeOfDay().toLowerCase()));

    final List<hAlbam.Albam> newItems = [];
    recommended.maybeWhen(
      loaded: (data) =>
          newItems.addAll((data.data?.albams ?? []).where((a) => a.isNew == true)),
      orElse: () {},
    );
    timeOfDay.maybeWhen(
      loaded: (data) =>
          newItems.addAll((data.data?.albams ?? []).where((a) => a.isNew == true)),
      orElse: () {},
    );

    final seen = <int?>{};
    final unique = newItems.where((a) => seen.add(a.id)).toList();
    if (unique.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'menu_screen.new'.tr(),
          style:
              AppTextDecor.bold14White.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacerH(8.h),
        SizedBox(
          height: 212.h,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: unique.length,
            itemBuilder: (context, index) {
              final data = unique[index];
              final isPaid = data.isPaid ?? false;
              return GestureDetector(
                onTap: () {
                  if (isPaid) {
                    showPremiumDialouge(context);
                  } else {
                    ref.read(selectedDatumProvider.notifier).state = data;
                    ref.read(selectedMusicProvider.notifier).state = "Home";
                    context.nav.pushNamed(Routes.playerScreen);
                  }
                },
                child: Container(
                  width: 160.w,
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: data.thumbnail ?? '',
                              width: 160.w,
                              height: 160.h,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 160.w,
                                height: 160.h,
                                color: AppColors.gray.withOpacity(0.2),
                              ),
                            ),
                          ),
                          if (isPaid)
                            Positioned(
                              bottom: 5.h,
                              left: 5.h,
                              child: CircleAvatar(
                                maxRadius: 13,
                                backgroundColor:
                                    AppColors.darkTeal.withOpacity(0.4),
                                child: SvgPicture.asset(
                                  "assets/svgs/lock_icon.svg",
                                  width: 12.w,
                                  height: 16.h,
                                ),
                              ),
                            ),
                        ],
                      ),
                      AppSpacerH(8.h),
                      Text(
                        data.name?.toString().tr() ?? '',
                        style: AppTextDecor.bold12White,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        AppSpacerH(16.h),
      ],
    );
  }
}
