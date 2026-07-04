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
import 'package:medyo/features/core/logic/player_prefs_provider.dart';
import 'package:medyo/features/core/logic/sleep_timer_provider.dart';
import 'package:medyo/features/favourites/views/favourites_tab.dart';
import 'package:medyo/services/ad_helper.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/services/local_storage_service.dart';
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

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late InterstitialAd interad;
  bool isloaded = false;
  bool allowUpdate = true;
  bool isSliderOpen = false;
  bool _isDragging = false;
  double _dragValue = 0.0;
  String? _initializedFor;
  @override
  void initState() {
    super.initState();
    initinterad();
  }

  @override
  void deactivate() {
    final audioHandler = ref.read(audioServiceProvider);
    final item = audioHandler?.mediaItem.value;
    if (item != null) {
      LocalStorageService.saveContinueListening(
        item: item,
        position: ref.read(playBackDurationProvider),
        duration: item.duration ?? ref.read(currentDurationProvider),
      );
    }
    super.deactivate();
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
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 20.h),
                          decoration:
                              const BoxDecoration(color: AppColors.slidePanel),
                          child: Column(
                            children: [
                              AppSpacerH(20.h),
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
                              Container(
                                height: 246.h,
                                width: 246.h,
                                padding: EdgeInsets.all(12.h),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(123.h),
                                  border: Border.all(
                                      color: AppColors.lightGeay, width: 1.w),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(111.h),
                                    child: CachedNetworkImage(
                                      imageUrl: media.data != null
                                          ? media.data!.artUri.toString()
                                          : "",
                                      height: 222.h,
                                      width: 222.h,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/cdlabel.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ),
                              AppSpacerH(23.h),
                              SizedBox(
                                width: 340.w,
                                child: Text(
                                  media.data != null ? media.data!.title : "",
                                  style: AppTextDecor.regular16White,
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
                                      style: AppTextDecor.regular16White,
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
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final isShuffle =
                                          ref.watch(isShuffleEnabledProvider);
                                      return PlayerIcons(
                                        onTap: () {
                                          ref
                                              .read(isShuffleEnabledProvider
                                                  .notifier)
                                              .state = !isShuffle;
                                        },
                                        svgPath: 'assets/svgs/icon_suffle.svg',
                                        color: isShuffle
                                            ? AppColors.white
                                            : AppColors.white.withOpacity(0.4),
                                      );
                                    },
                                  ),
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
                                                height: 57.h,
                                                width: 57.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          28.5.h),
                                                  border: Border.all(
                                                      color:
                                                          AppColors.lightGeay,
                                                      width: 1.w),
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
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final repeatMode =
                                          ref.watch(repeatModeProvider);
                                      return PlayerIcons(
                                        onTap: () {
                                          final next = RepeatMode.values[
                                              (repeatMode.index + 1) %
                                                  RepeatMode.values.length];
                                          ref
                                              .read(repeatModeProvider.notifier)
                                              .state = next;
                                        },
                                        svgPath: 'assets/svgs/icon_repeat.svg',
                                        color: repeatMode == RepeatMode.off
                                            ? AppColors.white.withOpacity(0.4)
                                            : AppColors.white,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              AppSpacerH(16.h),
                              const SleepTimerButton(),
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
                                            overlayShape:
                                                SliderComponentShape.noThumb,
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
                                            activeColor: AppColors.lightGeay,
                                            thumbColor: AppColors.lightGeay,
                                            inactiveColor: AppColors.lightGeay
                                                .withOpacity(0.5)
                                                .withOpacity(0.3),
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
                                              style:
                                                  AppTextDecor.regular14White,
                                            ),
                                            Text(
                                              totalDuration != null
                                                  ? AppGLF.format(
                                                      totalDuration)
                                                  : "0:00",
                                              style:
                                                  AppTextDecor.regular14White,
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
    this.color,
  });
  final String svgPath;
  final Function()? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SvgPicture.asset(
          svgPath,
          width: 23.h,
          color: color,
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

class SleepTimerButton extends ConsumerWidget {
  const SleepTimerButton({super.key});

  static const List<int> options = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(sleepTimerRemainingProvider);

    return GestureDetector(
      onTap: () => _openSleepTimerSheet(context, ref),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.lightGeay, width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bedtime_outlined, color: AppColors.white, size: 16.h),
            AppSpacerW(8.w),
            Text(
              remaining != null
                  ? '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'
                  : 'player_screen.sleep_timer'.tr(),
              style: AppTextDecor.regular14White,
            ),
          ],
        ),
      ),
    );
  }

  void _openSleepTimerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slidePanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final activeMinutes = ref.watch(sleepTimerMinutesProvider);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('player_screen.sleep_timer'.tr(),
                        style: AppTextDecor.bold18White),
                    AppSpacerH(16.h),
                    ...options.map((minutes) => ListTile(
                          onTap: () {
                            ref
                                .read(sleepTimerMinutesProvider.notifier)
                                .start(minutes);
                            Navigator.of(sheetContext).pop();
                          },
                          title: Text(
                            '$minutes ${'player_screen.minutes'.tr()}',
                            style: AppTextDecor.regular16White,
                          ),
                          trailing: activeMinutes == minutes
                              ? const Icon(Icons.check, color: AppColors.white)
                              : null,
                        )),
                    ListTile(
                      onTap: () {
                        ref
                            .read(sleepTimerMinutesProvider.notifier)
                            .cancelTimer();
                        Navigator.of(sheetContext).pop();
                      },
                      title: Text(
                        'player_screen.sleep_timer_off'.tr(),
                        style: AppTextDecor.regular16White,
                      ),
                      trailing: activeMinutes == null
                          ? const Icon(Icons.check, color: AppColors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
