import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/favourites/views/favourites_tab.dart';
import 'package:medyo/services/ad_helper.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/player_app_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../../widgets/playerLoader.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late InterstitialAd interad;
  bool isloaded = false;
  bool allowUpdate = true;
  bool isSliderOpen = false;
  bool _isDragging = false;
  double _dragValue = 0.0;
  String? _initializedFor;
  late final AnimationController _breatheController;
  @override
  void initState() {
    super.initState();
    initinterad();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  initinterad() {
    if (!AdHelper.adsEnabled) return;
    InterstitialAd.load(
      adUnitId: AdHelper.interstetialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: ((error) {
          debugPrint('Failed to load a banner ad: ${error.message}');
        }),
      ),
    );
  }

  void onLoaded(InterstitialAd ad) {
    interad = ad;
    isloaded = true;
  }

  @override
  Widget build(BuildContext context) {
    AppGLF.changeStatusBarColor(color: Colors.transparent);
    final audioHandler = ref.watch(audioServiceProvider);
    final album = ref.watch(selectedAlbumProvider);
    final album2 = ref.watch(selectedDatumProvider);
    final music = ref.watch(selectedMusicProvider);
    final musicIndex = ref.watch(selectedMusicIndex);
    final playList = ref.watch(currentPlayListProvider);

    final isLoading = ref.watch(playerLoadingProvider);

    if (album != null && music == "Sub") {
      ref.watch(tracksProvider(album.id.toString())).maybeWhen(
          orElse: () {},
          loaded: (_) {
            final key = 'sub-${album.id}';
            if (_initializedFor != key) {
              _initializedFor = key;
              Future.microtask(() async {
                if (!mounted) return;
                ref.read(currentPlayListProvider.notifier).state =
                    _.data!.albams!;

                if (_.data != null &&
                    musicIndex < _.data!.albams!.length &&
                    audioHandler?.mediaItem.value?.extras?['album'] ==
                        _.data!.albams!.first.albam?.id.toString()) {
                  await AppGLF.changeAndPlayMedia(
                      audioHandler!, _.data!.albams![musicIndex],
                      shouldPlay: true);
                }
              });
            }
          });
    } else if (album2 != null && music == "Home") {
      ref.watch(tracksProvider(album2.id.toString())).maybeWhen(
          orElse: () {},
          loaded: (_) {
            final key = 'home-${album2.id}';
            if (_initializedFor != key) {
              _initializedFor = key;
              Future.microtask(() async {
                if (!mounted) return;
                ref.read(currentPlayListProvider.notifier).state =
                    _.data!.albams!;

                if (_.data != null &&
                    musicIndex < _.data!.albams!.length &&
                    audioHandler?.mediaItem.value?.extras?['album'] ==
                        _.data!.albams!.first.albam?.id.toString()) {
                  await AppGLF.changeAndPlayMedia(
                      audioHandler!, _.data!.albams![musicIndex],
                      shouldPlay: true);
                }
              });
            }
          });
    }

    return Scaffold(
      body: StreamBuilder<MediaItem?>(
          stream: audioHandler?.mediaItem,
          builder: (context, media) {
            return Container(
                height: 844.h,
                width: 390.w,
                color: AppColors.darkTeal,
                child: Column(
                  children: [
                    const PLayerAppBar(),
                    Expanded(
                        child: SlidingUpPanel(
                      onPanelSlide: (position) {
                        print('Print position $position');
                      },
                      header: Container(
                        width: 390.w,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        child: Center(
                            child: SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: AnimatedRotation(
                            turns: isSliderOpen ? 0 : 0.5,
                            duration: 200.milisec,
                            child: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.white,
                            ),
                          ),
                        )),
                      ),
                      onPanelOpened: () {
                        debugPrint('Slider Opened');
                        setState(() {
                          isSliderOpen = true;
                        });
                      },
                      onPanelClosed: () {
                        debugPrint('Slider Closed');
                        setState(() {
                          isSliderOpen = false;
                        });
                      },
                      color: Colors.transparent,
                      minHeight: 270.h,
                      maxHeight: 600.h,
                      panelBuilder: (controller) => ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          decoration:
                              const BoxDecoration(color: AppColors.surface),
                          child: Column(
                            children: [
                              Container(
                                width: 40.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: AppColors.divider,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              AppSpacerH(16.h),
                              Expanded(
                                child: playList.isNotEmpty
                                    ? ListView.builder(
                                        controller: controller,
                                        padding: EdgeInsets.zero,
                                        itemCount: playList.length,
                                        itemBuilder: (context, index) {
                                          final song = playList[index];
                                          return SongTile(
                                            track: song,
                                            index: index,
                                            isSelected:
                                                media.data?.title == song.name,
                                            isPaid: playList[index].isPaid!,
                                          );
                                        })
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      body: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: AppColors.darkTeal,
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _breatheController,
                                builder: (context, child) {
                                  final scale = 1.0 +
                                      (_breatheController.value * 0.05);
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  height: 260.h,
                                  width: 260.h,
                                  padding: EdgeInsets.all(10.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.accentPrimary
                                            .withOpacity(0.35),
                                        AppColors.accentSecondary
                                            .withOpacity(0.15),
                                      ],
                                    ),
                                  ),
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(24.r),
                                      child: CachedNetworkImage(
                                        imageUrl: media.data != null
                                            ? media.data!.artUri.toString()
                                            : "",
                                        height: 240.h,
                                        width: 240.h,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/cdlabel.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                ),
                              ),
                              AppSpacerH(23.h),
                              SizedBox(
                                width: 340.w,
                                child: Text(
                                  media.data != null ? media.data!.title : "",
                                  style: AppTextDecor.bodyTitle16,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Center(
                                child: SizedBox(
                                  width: 340.w,
                                  child: Center(
                                    child: TextScroll(
                                      media.data?.extras?['desc'] ?? "",
                                      style: AppTextDecor.caption13,
                                      textAlign: TextAlign.center,
                                      velocity: const Velocity(
                                          pixelsPerSecond: Offset(30, 0)),
                                    ),
                                  ),
                                ),
                              ),
                              AppSpacerH(26.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // const PlayerIcons(
                                  //   svgPath: 'assets/svgs/icon_suffle.svg',
                                  // ),
                                  const SizedBox(),
                                  PlayerIcons(
                                    onTap: () async {
                                      audioHandler?.skipToPrevious();
                                    },
                                    svgPath: context.locale.languageCode == "ar"
                                        ? 'assets/svgs/icon_next.svg'
                                        : 'assets/svgs/icon_previous.svg',
                                  ),
                                  StreamBuilder<bool>(
                                    stream: audioHandler?.playbackState
                                        .map((state) => state.playing)
                                        .distinct(),
                                    builder: (context, snapshot) {
                                      final playing = snapshot.data ?? false;

                                      return isLoading
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: AppColors.white,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                if (playing) {
                                                  audioHandler?.pause();
                                                } else {
                                                  audioHandler?.play();
                                                }
                                              },
                                              child: Container(
                                                height: 64.h,
                                                width: 64.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.accentPrimary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          32.h),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .accentPrimary
                                                          .withOpacity(0.35),
                                                      blurRadius: 16,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: PlayerIcons(
                                                    svgPath: playing
                                                        ? 'assets/svgs/icon_pause.svg'
                                                        : 'assets/svgs/icon_play.svg',
                                                  ),
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                  PlayerIcons(
                                    onTap: () {
                                      if (isloaded) {
                                        interad.show();
                                      }
                                      audioHandler?.skipToNext();
                                    },
                                    svgPath: context.locale.languageCode == "ar"
                                        ? 'assets/svgs/icon_previous.svg'
                                        : 'assets/svgs/icon_next.svg',
                                  ),
                                  const SizedBox(),
                                  // const PlayerIcons(
                                  //   svgPath: 'assets/svgs/icon_repeat.svg',
                                  // ),
                                ],
                              ),
                              Consumer(
                                builder: (context, ref, _) {
                                  final position =
                                      ref.watch(playBackDurationProvider);
                                  final totalDuration = media.data?.duration ??
                                      ref.watch(currentDurationProvider);
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w),
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 4.h,
                                            overlayShape:
                                                SliderComponentShape.noThumb,
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius: 6.r),
                                          ),
                                          child: Slider(
                                            value: _isDragging
                                                ? _dragValue
                                                : (totalDuration != null &&
                                                        totalDuration
                                                                .inMilliseconds >
                                                            0)
                                                    ? (position
                                                                .inMilliseconds /
                                                            totalDuration
                                                                .inMilliseconds)
                                                        .clamp(0.0, 1.0)
                                                    : 0.0,
                                            activeColor:
                                                AppColors.accentPrimary,
                                            thumbColor:
                                                AppColors.accentPrimary,
                                            inactiveColor:
                                                AppColors.divider,
                                            onChangeStart: (value) {
                                              setState(() {
                                                _isDragging = true;
                                                _dragValue = value;
                                              });
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                _dragValue = value;
                                              });
                                            },
                                            onChangeEnd: (value) {
                                              if (totalDuration != null) {
                                                audioHandler?.seek(Duration(
                                                  milliseconds: (totalDuration
                                                              .inMilliseconds *
                                                          value)
                                                      .toInt(),
                                                ));
                                              }
                                              setState(() {
                                                _isDragging = false;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      AppSpacerH(10.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppGLF.format(position),
                                              style: AppTextDecor.caption12,
                                            ),
                                            Text(
                                              totalDuration != null
                                                  ? AppGLF.format(
                                                      totalDuration)
                                                  : "0:00",
                                              style: AppTextDecor.caption12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            ],
                          )),
                    ))
                  ],
                ));
          }),
    );
  }
}

class PlayerIcons extends StatelessWidget {
  const PlayerIcons({
    super.key,
    required this.svgPath,
    this.onTap,
  });
  final String svgPath;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SvgPicture.asset(
          svgPath,
          width: 23.h,
        ),
      ),
    );
  }
}

class PlayerIconsSmall extends StatelessWidget {
  const PlayerIconsSmall({
    super.key,
    required this.svgPath,
    this.onTap,
  });
  final String svgPath;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: SvgPicture.asset(
          svgPath,
          width: 12.h,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
