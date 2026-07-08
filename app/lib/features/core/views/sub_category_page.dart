import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/config/hive_contants.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/logic/player_prefs_provider.dart';
import 'package:medyo/features/core/models/album_list_model/albam.dart';
import 'package:medyo/features/core/models/category_list_model/category.dart';
import 'package:medyo/services/ad_helper.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/artwork_image.dart';
import 'package:medyo/widgets/buttons/full_width_button.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/regular_app_bar.dart';
import 'package:medyo/widgets/screen_wrapper.dart';

class SubCategoryPage extends ConsumerStatefulWidget {
  const SubCategoryPage({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubCategoryPageState();
}

class _SubCategoryPageState extends ConsumerState<SubCategoryPage> {
  late BannerAd bannerAd;
  bool isloaded = false;
  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) {
    initbannerAd();
    // }
  }

  initbannerAd() {
    if (!AdHelper.adsEnabled) return;
    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isloaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  /// Opens an album exactly like tapping its AlbumTile would - the same,
  /// already-proven entry point (selectedAlbumProvider + selectedMusicProvider
  /// "Sub" + Player's own tracksProvider-driven auto-play). Prefers a
  /// non-paid album so "Play All"/"Shuffle" don't immediately hit a paywall
  /// dialog when free albums are available.
  void _openAlbum(Albam album) {
    ref.read(selectedAlbumProvider.notifier).state = album;
    ref.read(selectedMusicProvider.notifier).state = "Sub";
    context.nav.pushNamed(Routes.playerScreen);
  }

  void _playAll(List<Albam> albums) {
    if (albums.isEmpty) return;
    final target = albums.firstWhere((a) => a.isPaid != true,
        orElse: () => albums.first);
    if (target.isPaid == true) {
      showPremiumDialouge(context);
      return;
    }
    _openAlbum(target);
  }

  void _shuffle(List<Albam> albums) {
    if (albums.isEmpty) return;
    final free = albums.where((a) => a.isPaid != true).toList();
    if (free.isEmpty) {
      showPremiumDialouge(context);
      return;
    }
    ref.read(isShuffleEnabledProvider.notifier).state = true;
    free.shuffle();
    _openAlbum(free.first);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
        child: Stack(children: [
      SizedBox(
        height: 844.h,
        width: 390.w,
        child: Column(
          children: [
            RegularAppBar(title: widget.category.name ?? ''),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ref
                    .watch(albumsProvider(widget.category.id.toString()))
                    .map(
                      initial: (_) => const LoadingWidget(),
                      loading: (_) => const LoadingWidget(),
                      loaded: (_) {
                        final albums = _.data.data!.albams!;
                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _CollectionHero(
                                category: widget.category,
                                albumCount: albums.length,
                                onPlayAll: () => _playAll(albums),
                                onShuffle: () => _shuffle(albums),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 167 / 240,
                                  crossAxisSpacing: 16.w,
                                  mainAxisSpacing: 16.h,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      AlbumTile(albam: albums[index]),
                                  childCount: albums.length,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      error: (_) => ErrorTextWidget(error: _.error),
                    ),
              ),
            ),
          ],
        ),
      ),
      Positioned(
          bottom: 0,
          child: isloaded
              ? Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  ),
                )
              : Container()),
    ]));
  }
}

/// Collection Detail hero (design 07): category art/name/description as a
/// photographic backdrop, album count, and Play All / Shuffle. All fields
/// come straight off the existing Category the screen already received -
/// no new data source.
class _CollectionHero extends StatelessWidget {
  const _CollectionHero({
    required this.category,
    required this.albumCount,
    required this.onPlayAll,
    required this.onShuffle,
  });

  final Category category;
  final int albumCount;
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              width: double.infinity,
              height: 180.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ArtworkImage(
                    imageUrl: category.thumbnail,
                    width: double.infinity,
                    height: 180.h,
                    borderRadius: BorderRadius.zero,
                    category: category.name,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bgPrimary.withOpacity(0.85),
                          AppColors.bgPrimary.withOpacity(0.1),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 14.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (category.name ?? '').tr(),
                          style: AppTextDecor.heading2_22,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((category.description ?? '').isNotEmpty) ...[
                          AppSpacerH(4.h),
                          Text(
                            category.description!,
                            style: AppTextDecor.caption13Muted,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        AppSpacerH(4.h),
                        Text(
                          '$albumCount ${'sub_category_screen.albums'.tr()}',
                          style: AppTextDecor.caption13Muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacerH(16.h),
          Row(
            children: [
              Expanded(
                child: AppTextButton(
                  height: 44.h,
                  title: 'sub_category_screen.play_all'.tr(),
                  onTap: onPlayAll,
                ),
              ),
              AppSpacerW(12.w),
              Expanded(
                child: GestureDetector(
                  onTap: onShuffle,
                  child: Container(
                    height: 44.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(color: AppColors.accentPrimary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shuffle,
                            size: 16.sp, color: AppColors.accentPrimary),
                        AppSpacerW(6.w),
                        Text(
                          'sub_category_screen.shuffle'.tr(),
                          style: AppTextDecor.bodyTitle15
                              .copyWith(color: AppColors.accentPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AlbumTile extends ConsumerWidget {
  const AlbumTile({
    super.key,
    required this.albam,
  });
  final Albam albam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.userBox).listenable(),
        builder: (BuildContext context, Box userBox, Widget? child) {
          final bool isPremium = (userBox.get(AppHSC.premium) == true);
          final bool isPaid = albam.isPaid ?? false;
          return GestureDetector(
            onTap: () {
              if (isPaid) {
                showPremiumDialouge(context);
              } else {
                ref.watch(selectedAlbumProvider.notifier).state = albam;
                ref
                    .watch(selectedMusicProvider.notifier)
                    .update((state) => "Sub");
                context.nav.pushNamed(Routes.playerScreen);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 143.h,
                  width: 167.w,
                  child: Stack(
                    children: [
                      ArtworkImage(
                        imageUrl: albam.thumbnail,
                        width: 167.w,
                        height: 143.h,
                        borderRadius: BorderRadius.circular(16.r),
                        category: albam.name,
                      ),
                      if (isPaid)
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(27.r),
                            decoration: BoxDecoration(
                                color: AppColors.bgPrimary.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(16.r)),
                            child: SvgPicture.asset(
                              'assets/svgs/icon_prem_lock.svg',
                              height: 26.h,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                AppSpacerH(8.h),
                Text(
                  albam.name.toString().tr(),
                  style: AppTextDecor.bodyTitle15,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                AppSpacerH(4.h),
                Expanded(
                    child: Text(
                  albam.description ?? "".tr(),
                  style: AppTextDecor.caption12,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ))
              ],
            ),
          );
        });
  }
}
