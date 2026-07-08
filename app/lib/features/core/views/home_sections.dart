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
import 'package:medyo/features/core/models/category_list_model/category.dart';
import 'package:medyo/features/core/models/dashboard_category_a_lbums_list/albam.dart'
    as hAlbam;
import 'package:medyo/services/local_storage_service.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/artwork_image.dart';
import 'package:medyo/widgets/misc_widgets.dart';

/// Big "Tonight's Recommendation" hero card. Sourced from the same
/// Most Recommended dashboard data already used further down the page (no
/// new data source) - just shows the first item as a full-width hero.
class TonightRecommendationSection extends ConsumerWidget {
  const TonightRecommendationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(dashboardcategoryalbumListProvider('Most Recomanded')).maybeWhen(
          loaded: (data) {
            final albams = data.data?.albams;
            if (albams == null || albams.isEmpty) return const SizedBox();
            final item = albams.first;
            final isPaid = item.isPaid ?? false;
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: GestureDetector(
                onTap: () {
                  if (isPaid) {
                    showPremiumDialouge(context);
                  } else {
                    ref.read(selectedDatumProvider.notifier).state = item;
                    ref.read(selectedMusicProvider.notifier).state = "Home";
                    context.nav.pushNamed(Routes.playerScreen);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: SizedBox(
                    width: double.infinity,
                    height: 160.h,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ArtworkImage(
                          imageUrl: item.thumbnail,
                          width: double.infinity,
                          height: 160.h,
                          borderRadius: BorderRadius.zero,
                          category: item.name,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.bgPrimary.withOpacity(0.8),
                                AppColors.bgPrimary.withOpacity(0.0),
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16.w,
                          right: 70.w,
                          bottom: 14.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('menu_screen.tonight_recommendation'.tr(),
                                  style: AppTextDecor.caption13Muted),
                              AppSpacerH(2.h),
                              Text(
                                item.name?.toString().tr() ?? '',
                                style: AppTextDecor.heading3_17,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.description ?? '',
                                style: AppTextDecor.caption13Muted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 16.w,
                          bottom: 14.h,
                          child: Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: const BoxDecoration(
                              color: AppColors.accentPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPaid
                                  ? Icons.lock_outline
                                  : Icons.play_arrow_rounded,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          orElse: () => const SizedBox(),
        );
  }
}

/// Row of 4 quick-navigation shortcuts (Sleep Music / Meditation / Breathing
/// / Sleep Timer). Pure navigation to existing routes/screens - no new
/// business logic, no new providers.
class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key});

  void _openSleepMusic(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoriessProvider).maybeWhen(
          loaded: (data) => data.data?.category ?? <Category>[],
          orElse: () => <Category>[],
        );
    Category? sleepCategory;
    for (final c in categories) {
      if ((c.name ?? '').toLowerCase().contains('sleep')) {
        sleepCategory = c;
        break;
      }
    }
    if (sleepCategory != null) {
      context.nav.pushNamed(Routes.subCategoryScreen, arguments: sleepCategory);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('menu_screen.no_sleep_category'.tr())),
      );
    }
  }

  /// Opens the Player, where the real Sleep Timer control already lives -
  /// only if a track is actually active, matching the same null-safety
  /// pattern Player itself uses for `selectedDatumProvider`. No new sleep
  /// timer logic is created here.
  void _openSleepTimer(BuildContext context, WidgetRef ref) {
    final hasActiveTrack = ref.read(selectedDatumProvider) != null;
    if (hasActiveTrack) {
      context.nav.pushNamed(Routes.playerScreen);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('menu_screen.sleep_timer_no_track'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _QuickAction(
        icon: Icons.music_note_rounded,
        labelKey: 'menu_screen.quick_sleep_music',
        onTap: () => _openSleepMusic(context, ref),
      ),
      _QuickAction(
        icon: Icons.self_improvement_rounded,
        labelKey: 'menu_screen.quick_meditation',
        onTap: () => context.nav.pushNamed(Routes.meditationScreen),
      ),
      _QuickAction(
        icon: Icons.air_rounded,
        labelKey: 'menu_screen.quick_breathing',
        onTap: () => context.nav.pushNamed(Routes.breathingScreen),
      ),
      _QuickAction(
        icon: Icons.bedtime_outlined,
        labelKey: 'menu_screen.quick_sleep_timer',
        onTap: () => _openSleepTimer(context, ref),
      ),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('menu_screen.quick_actions'.tr(), style: AppTextDecor.heading3_17),
          AppSpacerH(12.h),
          Row(children: actions.map((a) => Expanded(child: a)).toList()),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.labelKey,
    required this.onTap,
  });

  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22.sp),
          ),
          AppSpacerH(6.h),
          Text(
            labelKey.tr(),
            style: AppTextDecor.caption13Muted,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  ArtworkImage(
                    imageUrl: data['thumbnail']?.toString(),
                    width: 56.w,
                    height: 56.h,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  AppSpacerW(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('menu_screen.continue_listening'.tr(),
                            style: AppTextDecor.caption13Muted),
                        AppSpacerH(4.h),
                        Text(
                          data['title']?.toString() ?? '',
                          style: AppTextDecor.bodyTitle16,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacerH(6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3.h,
                            backgroundColor: AppColors.divider,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacerW(8.w),
                  const Icon(Icons.play_circle_fill,
                      color: AppColors.textPrimary, size: 32),
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
              style: AppTextDecor.heading3_17,
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
                          ArtworkImage(
                            imageUrl: item['thumbnail']?.toString(),
                            width: 140.w,
                            height: 120.h,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          AppSpacerH(8.h),
                          Text(
                            item['title']?.toString() ?? '',
                            style: AppTextDecor.tagBadge11,
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
          style: AppTextDecor.heading3_17,
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
                          ArtworkImage(
                            imageUrl: data.thumbnail,
                            width: 160.w,
                            height: 160.h,
                            borderRadius: BorderRadius.circular(15),
                            category: data.name,
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
                        style: AppTextDecor.tagBadge11,
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
