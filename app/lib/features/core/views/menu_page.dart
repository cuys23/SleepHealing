// ignore_for_file: unnecessary_null_comparison, unused_local_variable, unrelated_type_equality_checks

import 'package:audioplayers/audioplayers.dart';
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
import 'package:medyo/features/core/models/app_banner_list_model/banner.dart';
import 'package:medyo/features/core/models/category_list_model/category.dart';
import 'package:medyo/features/core/models/dashboard_category_a_lbums_list/albam.dart'
    as hAlbam;
import 'package:medyo/features/theme/misc_provider.dart';
import 'package:medyo/services/ad_helper.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/dialouges.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/misc_widgets.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  Box authbox = Hive.box(AppHSC.authBox);
  Box userbox = Hive.box(AppHSC.userBox);
  String? saved;

  @override
  void initState() {
    debugPrint("Build");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final audioplayer = ref.watch(audioPlayerProvider);
      if (audioplayer.state != PlayerState.playing) {
        audioplayer.play(AssetSource("sounds/birds-in-the-morning-24147.mp3"));
        await audioplayer.setVolume(0);
      }
      _checkScene();
    });
    initAd();
    initbannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(appBannersProvider);
      ref.refresh(categoriessProvider);
      ref.refresh(dashboardcategoryalbumListProvider('Most Recomanded'));
      ref.refresh(dashboardcategoryalbumListProvider(
          AppGLF.getTimeOfDay().toLowerCase()));
    });
  }

  Future<void> _checkScene() async {
    var box = await Hive.openBox("app");

    saved = box.get('saved_scene');
  }

  List<String> images = [
    "assets/images/home_sgstn_tile_3.png",
    "assets/images/home_sgstn_tile_2.png",
    "assets/images/home_sgstn_tile_1.png",
    "assets/images/home_sgstn_tile_3.png",
    "assets/images/home_sgstn_tile_2.png",
    "assets/images/home_sgstn_tile_1.png",
    "assets/images/home_sgstn_tile_3.png",
    "assets/images/home_sgstn_tile_2.png",
    "assets/images/home_sgstn_tile_1.png",
  ];
  List<String> types = [
    "Empower",
    "Chill-Out",
    "Sleep",
    "Empower",
    "Chill-Out",
    "Sleep",
    "Empower",
    "Chill-Out",
    "Sleep",
  ];
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8];
  bool sunny = true;

  InterstitialAd? _interstitialAd;

  void initAd() {
    if (!AdHelper.adsEnabled) return;
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3405382556879664/5810134101",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}),
    );
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
  }

  BannerAd? bannerAd;
  bool isloaded = false;

  initbannerAd() {
    if (!AdHelper.adsEnabled) return;
    debugPrint("Banner Ad Initialized");
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
    bannerAd!.load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? scene = ref.watch(sceneProvider);

    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.appBox).listenable(),
        builder: (context, Box appBox, Widget? child) {
          int? savedColorValue = appBox.get('saved_color');
          if (savedColorValue != null) {
            AppColors.darkTeal = Color(savedColorValue);
          }

          return ValueListenableBuilder(
              valueListenable: Hive.box(AppHSC.userBox).listenable(),
              builder: (BuildContext context, Box userBox, Widget? child) {
                return ValueListenableBuilder(
                    valueListenable: Hive.box(AppHSC.authBox).listenable(),
                    builder:
                        (BuildContext context, Box authBox, Widget? child) {
                      return Scaffold(
                        backgroundColor: saved == null
                            ? AppColors.darkTeal
                            : Colors.transparent,
                        //extendBody: true,
                        body: Stack(
                          children: [
                            saved == null
                                ? const SizedBox()
                                : Positioned.fill(
                                    child: Image.asset(
                                      saved != null
                                          ? saved.toString()
                                          : scene != ""
                                              ? scene!
                                              : AppGLF.getTimeOfDay() ==
                                                      "Morning"
                                                  ? "assets/images/giphy.gif"
                                                  : AppGLF.getTimeOfDay() ==
                                                          "Afternoon"
                                                      ? "assets/images/nature.gif"
                                                      : AppGLF.getTimeOfDay() ==
                                                              "Evening"
                                                          ? "assets/images/rainy.gif"
                                                          : "assets/images/moonlit.gif",
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: SafeArea(
                                top: false,
                                child: CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: 0.15.sh,
                                      ),
                                    ),
                                    SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                            childCount: 1, (context, index) {
                                      return Container(
                                        // height: MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                            gradient: saved == null
                                                ? LinearGradient(
                                                    colors: [
                                                      AppColors.darkTeal,
                                                      AppColors.darkTeal,
                                                      // Color(0xff253334),
                                                      // Color.fromARGB(0, 37, 51, 52),
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  )
                                                : const LinearGradient(
                                                    colors: [
                                                      Color(0xff253334),
                                                      Color.fromARGB(
                                                          0, 37, 51, 52),
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  )),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.h),
                                          child: ListView(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            children: [
                                              AppSpacerH(8.h),
                                              Text(
                                                "${"menu_screen.good".tr()} ${AppGLF.getTimeOfDay().tr()}".toUpperCase(),
                                                style: AppTextDecor.caption12,
                                              ),
                                              AppSpacerH(4.h),
                                              Text(
                                                (authBox.get(AppHSC.authToken) !=
                                                            null &&
                                                        userBox.get(AppHSC
                                                                .firstName) !=
                                                            null &&
                                                        userBox.get(AppHSC
                                                                .firstName) !=
                                                            '')
                                                    ? userBox
                                                        .get(AppHSC.firstName)
                                                    : 'Guest',
                                                style:
                                                    AppTextDecor.largeTitle28,
                                              ),
                                              AppSpacerH(16.h),
                                              ref
                                                  .watch(categoriessProvider)
                                                  .map(
                                                      initial: (_) =>
                                                          const LoadingWidget(),
                                                      loading: (_) =>
                                                          const LoadingWidget(),
                                                      loaded: (_) {
                                                        if (_
                                                                .data
                                                                .data
                                                                ?.category
                                                                ?.isNotEmpty ==
                                                            true) {
                                                          return GridView.count(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            crossAxisCount: 3,
                                                            crossAxisSpacing:
                                                                10.w,
                                                            childAspectRatio:
                                                                104 / 96,
                                                            mainAxisSpacing:
                                                                10.h,
                                                            children: _.data
                                                                .data!.category!
                                                                .take(6)
                                                                .map((e) =>
                                                                    AllCatagoriesCard(
                                                                      data: e,
                                                                      onTap:
                                                                          () {
                                                                        context.nav.pushNamed(
                                                                            Routes
                                                                                .subCategoryScreen,
                                                                            arguments:
                                                                                e);
                                                                      },
                                                                    ))
                                                                .toList(),
                                                          );
                                                        } else {
                                                          return Center(
                                                            child: Text(
                                                                'menu_screen.no_data'
                                                                    .tr()),
                                                          );
                                                        }
                                                      },
                                                      error: (_) =>
                                                          ErrorTextWidget(
                                                              error: _.error)),
                                              AppSpacerH(16.h),
                                              SizedBox(
                                                child: Center(
                                                  child: GestureDetector(
                                                    onTap: (() {
                                                      context.nav.pushNamed(
                                                          Routes.allcatagories);
                                                    }),
                                                    child: Container(
                                                      width: 168.w,
                                                      height: 36.h,
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .inputBg,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      14.r)),
                                                      child: Center(
                                                        child: Text(
                                                          "menu_screen.view_all"
                                                              .tr(),
                                                          style: AppTextDecor
                                                              .caption13,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              AppSpacerH(16.h),
                                              AppSpacerH(16.h),
                                              ref.watch(appBannersProvider).map(
                                                  initial: (_) =>
                                                      const LoadingWidget(),
                                                  loading: (_) =>
                                                      const LoadingWidget(),
                                                  loaded: (_) {
                                                    if (_.data.data!.banner!
                                                        .isNotEmpty) {
                                                      return Column(
                                                        children: [
                                                          SizedBox(
                                                            width: 388.w,
                                                            height: 200.h,
                                                            child: ListView
                                                                .builder(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    physics:
                                                                        const BouncingScrollPhysics(),
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis
                                                                            .horizontal,
                                                                    itemCount: _
                                                                        .data
                                                                        .data!
                                                                        .banner!
                                                                        .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return Row(
                                                                        children: [
                                                                          AppBannerContainer(
                                                                            margin: index == 0
                                                                                ? 0
                                                                                : 16.w,
                                                                            banner:
                                                                                _.data.data!.banner![index],
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }),
                                                          ),
                                                          AppSpacerH(16.h),
                                                        ],
                                                      );
                                                    } else {
                                                      return const SizedBox();
                                                    }
                                                  },
                                                  error: (_) => ErrorTextWidget(
                                                      error: _.error)),
                                              AppSpacerH(16.h),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "${AppGLF.getTimeOfDay() == "Morning" ? "menu_screen.morning".tr() : AppGLF.getTimeOfDay() == "Afternoon" ? "menu_screen.afternoon".tr() : AppGLF.getTimeOfDay() == "Evening" ? "menu_screen.evening".tr() : "menu_screen.night".tr()} ${"menu_screen.reset".tr()}",
                                                      style: AppTextDecor
                                                          .sectionHeader20,
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (_interstitialAd !=
                                                          null) {
                                                        _interstitialAd!.show();
                                                        _interstitialAd =
                                                            null; // একবার use করার পর clear করে দিন
                                                      } else {
                                                        debugPrint(
                                                            "Interstitial ad not ready yet");
                                                      }

                                                      context.nav.pushNamed(
                                                          Routes
                                                              .afternoonreset);
                                                    },
                                                    child: Container(
                                                      width: 80.w,
                                                      height: 40.h,
                                                      color: Colors.transparent,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "menu_screen.see_all"
                                                              .tr(),
                                                          style: AppTextDecor
                                                              .caption13
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .accentPrimary),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              AppSpacerH(8.h),
                                              const DashboardCatagories(),
                                              isloaded && bannerAd != null
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16.0),
                                                      child: Center(
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          height: bannerAd!
                                                              .size.height
                                                              .toDouble(),
                                                          child: AdWidget(
                                                              ad: bannerAd!),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "menu_screen.recommand"
                                                          .tr(),
                                                      style: AppTextDecor
                                                          .sectionHeader20,
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _interstitialAd?.show();

                                                      context.nav.pushNamed(Routes
                                                          .mostrecommendedchannel);
                                                    },
                                                    child: Container(
                                                      width: 80.w,
                                                      height: 40.h,
                                                      color: Colors.transparent,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "menu_screen.see_all"
                                                              .tr(),
                                                          style: AppTextDecor
                                                              .caption13
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .accentPrimary),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              AppSpacerH(8.h),
                                              SizedBox(
                                                width: 200.w,
                                                height: 232.h,
                                                child: ref
                                                    .watch(
                                                        dashboardcategoryalbumListProvider(
                                                            'Most Recomanded'))
                                                    .map(
                                                      initial: (_) =>
                                                          const LoadingWidget(),
                                                      loading: (_) =>
                                                          const LoadingWidget(),
                                                      loaded: (_) {
                                                        return ValueListenableBuilder(
                                                            valueListenable: Hive
                                                                    .box(AppHSC
                                                                        .userBox)
                                                                .listenable(),
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    Box userBox,
                                                                    Widget?
                                                                        child) {
                                                              final bool
                                                                  isPremium =
                                                                  (userBox.get(
                                                                          AppHSC
                                                                              .premium) ==
                                                                      true);
                                                              return ListView
                                                                  .builder(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      physics:
                                                                          const BouncingScrollPhysics(),
                                                                      shrinkWrap:
                                                                          true,
                                                                      scrollDirection:
                                                                          Axis
                                                                              .horizontal,
                                                                      itemCount: _
                                                                          .data
                                                                          .data!
                                                                          .albams!
                                                                          .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        final isPaid = _
                                                                            .data
                                                                            .data!
                                                                            .albams![index]
                                                                            .isPaid;
                                                                        return GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (_interstitialAd !=
                                                                                null) {
                                                                              _interstitialAd!.show();
                                                                              _interstitialAd = null; // একবার use করার পর clear করে দিন
                                                                            } else {
                                                                              debugPrint("Interstitial ad not ready yet");
                                                                            }
                                                                            if (isPaid) {
                                                                              showPremiumDialouge(context);
                                                                            } else {
                                                                              ref.watch(selectedDatumProvider.notifier).state = _.data.data!.albams![index];
                                                                              ref.watch(selectedMusicProvider.notifier).update((state) => "Home");
                                                                              context.nav.pushNamed(Routes.playerScreen);
                                                                            }
                                                                          },
                                                                          child: MostRecommendedCard(
                                                                              margin: index == 0 && context.locale == 'ar' ? 0 : 10.w,
                                                                              data: _.data.data!.albams![index],
                                                                              isPaid: isPaid!),
                                                                        );
                                                                      });
                                                            });
                                                      },
                                                      error: (_) =>
                                                          ErrorTextWidget(
                                                              error: _.error),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }))
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              });
        });
  }

  Future<void> _onRefresh() async {
    debugPrint("Refreshing MenuPage...");

    // Re-fetch Hive value
    await _checkScene();

    // Refresh Riverpod providers manually
    ref.refresh(appBannersProvider);
    ref.refresh(categoriessProvider);
    ref.refresh(dashboardcategoryalbumListProvider('Most Recomanded'));
    ref.refresh(dashboardcategoryalbumListProvider(
        AppGLF.getTimeOfDay().toLowerCase()));

    // Optional: force UI rebuild
    setState(() {});
  }
}

class AppBannerContainer extends StatelessWidget {
  const AppBannerContainer({
    super.key,
    required this.margin,
    this.banner,
  });
  final double margin;
  final AppBanner? banner;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: context.locale == const Locale("ar", "SA")
            ? EdgeInsets.only(right: margin)
            : EdgeInsets.only(left: margin),
        decoration: const BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 320.w,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: banner != null
                    ? Image.network(
                        banner!.thumbnail.toString(),
                        width: 320.w,
                        height: 160.h,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/home_song.png",
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            AppSpacerH(12.h),
            Text(
              banner != null
                  ? banner!.title.toString().tr()
                  : "10 Minute Mindfulness Meditation",
              style: AppTextDecor.bodyTitle15,
            ),
          ],
        ));
  }
}

class MostRecommendedCard extends StatelessWidget {
  const MostRecommendedCard({
    super.key,
    required this.margin,
    required this.data,
    this.isPaid,
  });
  final double margin;
  final bool? isPaid;
  final hAlbam.Albam data;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.userBox).listenable(),
        builder: (BuildContext context, Box userBox, Widget? child) {
          final bool isPremium = (userBox.get(AppHSC.premium) == true);
          return Container(
              margin: EdgeInsets.only(left: margin),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Container(
                      width: 200.w,
                      height: 160.h,
                      decoration: const BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: data != null
                            ? Image.network(
                                data.thumbnail.toString(),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/images/most_recommended.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (isPaid!)
                      Positioned(
                          bottom: 5.h,
                          left: 5.h,
                          child: CircleAvatar(
                              maxRadius: 13,
                              backgroundColor:
                                  AppColors.bgPrimary.withOpacity(0.6),
                              child: SvgPicture.asset(
                                "assets/svgs/lock_icon.svg",
                                width: 12.w,
                                height: 16.h,
                              )))
                  ]),
                  AppSpacerH(12.h),
                  SizedBox(
                    width: 160.w,
                    height: 52.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        data != null
                            ? Text(
                                data.name.toString().tr(),
                                style: AppTextDecor.bodyTitle15,
                              )
                            : Text(
                                "menu_screen.mindful".tr(),
                                style: AppTextDecor.bodyTitle15,
                              ),
                        data != null
                            ? Expanded(
                                child: Text(
                                  data.description ?? "".tr(),
                                  style: AppTextDecor.caption12,
                                  maxLines: 2,
                                ),
                              )
                            : Text(
                                "menu_screen.relieve".tr(),
                                style: AppTextDecor.caption12,
                              ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }
}

class AfterNoonResteCard extends StatelessWidget {
  const AfterNoonResteCard({
    super.key,
    required this.margin,
    this.data,
    required this.isPaid,
  });
  final double margin;
  final bool isPaid;
  final hAlbam.Albam? data;

  Widget getIcon({required bool isPremium, required bool isPaid}) {
    debugPrint("------------>>>> isPremium: $isPremium, isPaid: $isPaid");
    if (isPremium) {
      return const SizedBox();
    }
    if (isPaid) {
      return Positioned(
        bottom: 5.h,
        left: 5.h,
        child: CircleAvatar(
          maxRadius: 13,
          backgroundColor: AppColors.bgPrimary.withOpacity(0.6),
          child: SvgPicture.asset(
            "assets/svgs/lock_icon.svg",
            width: 12.w,
            height: 16.h,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppHSC.userBox).listenable(),
        builder: (BuildContext context, Box userBox, Widget? child) {
          final bool isPremium = (userBox.get(AppHSC.premium) == true);
          return Container(
              margin: EdgeInsets.only(left: margin),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Container(
                      width: 200.w,
                      height: 160.h,
                      decoration: const BoxDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: data != null
                            ? Image.network(
                                data!.thumbnail.toString(),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/images/home_reset.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    getIcon(isPremium: isPremium, isPaid: isPaid),
                  ]),
                  AppSpacerH(10.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      data != null
                          ? Text(
                              data!.name.toString().tr(),
                              style: AppTextDecor.bodyTitle15,
                            )
                          : Text(
                              "menu_screen.mindful".tr(),
                              style: AppTextDecor.bodyTitle15,
                            ),
                      AppSpacerW(4.w),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: 'menu_screen.daily_meditam'.tr(),
                            style: AppTextDecor.caption12),
                        WidgetSpan(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10.w, bottom: 5.h, right: 5.w),
                                child: const CircleAvatar(
                                  maxRadius: 2,
                                  backgroundColor: AppColors.gray,
                                ))),
                        TextSpan(
                            text: 'menu_screen.tamara_lev'.tr(),
                            style: AppTextDecor.caption12),
                      ])),
                    ],
                  ),
                ],
              ));
        });
  }
}

class AllCatagoriesCard extends ConsumerWidget {
  const AllCatagoriesCard({
    super.key,
    this.data,
    this.onTap,
  });
  final Function()? onTap;
  final Category? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = AppColors.categoryColor(data?.name ?? '');
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: AppColors.surface,
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: data!.icon != null
                  ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Image.network(
                        data!.icon.toString(),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Icon(Icons.spa_outlined, color: tint),
            ),
            AppSpacerH(8.h),
            Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              data!.name != null ? data!.name.toString().tr() : "Chill",
              style: AppTextDecor.caption12,
            )
          ]),
        ));
  }
}

class DashboardCatagories extends ConsumerStatefulWidget {
  const DashboardCatagories({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardCatagoriesState();
}

class _DashboardCatagoriesState extends ConsumerState<DashboardCatagories> {
  final ScrollController controller = ScrollController();
  @override
  void initState() {
    super.initState();
    initAd();
    // controller.addListener(() {
    //   if (controller.offset >= controller.position.maxScrollExtent) {
    //     setState(() {
    //       EasyLoading.showInfo('Reached Scroll End');
    //     });
    //     ref.watch(dashboardcategoryalbumListProvider).maybeWhen(
    //           orElse: () {},
    //           loaded: (data) {
    //             setState(() {
    //               EasyLoading.showInfo('Reached Scroll End');
    //             });

    //             if (data.data!.albams!.meta!.currentPage! <
    //                 data.data!.albams!.meta!.lastPage!) {
    //               ref
    //                   .watch(dashboardcategoryalbumListProvider.notifier)
    //                   .getDashboardCategoryAlbumList(
    //                       page: data.data!.albams!.meta!.currentPage! + 1);
    //             }
    //           },
    //         );
    //   }
    // });
  }

  late InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  void initAd() {
    if (!AdHelper.adsEnabled) return;
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3405382556879664/5810134101",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}),
    );
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(dashboardcategoryalbumListProvider(
            AppGLF.getTimeOfDay().toLowerCase()))
        .map(
          initial: (_) => const LoadingWidget(),
          loading: (_) => const LoadingWidget(),
          loaded: (_) {
            return ValueListenableBuilder(
                valueListenable: Hive.box(AppHSC.userBox).listenable(),
                builder: (BuildContext context, Box userBox, Widget? child) {
                  // final bool isPremium = (userBox.get(AppHSC.premium) == true);

                  return SizedBox(
                      width: 200.w,
                      height: 212.h,
                      child: ListView.builder(
                          controller: controller,
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: _.data.data!.albams!.length,
                          itemBuilder: (context, index) {
                            final data = _.data.data!.albams![index];
                            final isPaid = _.data.data!.albams![index].isPaid;
                            print(
                                "isPaid ${_.data.data!.albams![index].isPaid}");
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_isLoaded) {
                                      _interstitialAd!.show();
                                    }
                                    if (isPaid != null && isPaid) {
                                      showPremiumDialouge(context);
                                    } else {
                                      ref
                                          .watch(selectedDatumProvider.notifier)
                                          .state = _.data.data!.albams![index];
                                      ref
                                          .watch(selectedMusicProvider.notifier)
                                          .update((state) => "Home");
                                      context.nav
                                          .pushNamed(Routes.playerScreen);
                                    }
                                  },
                                  child: AfterNoonResteCard(
                                    // ignore: unrelated_type_equality_checks
                                    margin: index == 0 && context.locale == "ar"
                                        ? 0
                                        : 10.w,
                                    data: data,
                                    isPaid: isPaid!,
                                  ),
                                ),
                              ],
                            );
                          }));
                });
          },
          error: (_) => ErrorTextWidget(error: _.error),
        );
  }
}
