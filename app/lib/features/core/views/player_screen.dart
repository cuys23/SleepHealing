import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/logic/player_navigation.dart';
import 'package:medyo/features/core/logic/player_prefs_provider.dart';
import 'package:medyo/features/core/logic/sleep_timer_provider.dart';
import 'package:medyo/features/core/models/play_list_model/albam.dart';
import 'package:medyo/features/favourites/logic/fav_provider.dart';
import 'package:medyo/features/favourites/views/favourites_tab.dart';
import 'package:medyo/services/ad_helper.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/services/local_storage_service.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/widgets/artwork_image.dart';
import 'package:medyo/widgets/misc_widgets.dart';
import 'package:medyo/widgets/player_app_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  bool _showHistoryTab = false;
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
                      header: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r)),
                        child: Container(
                          width: 390.w,
                          color: AppColors.surface,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                playList.isNotEmpty
                                    ? '${'player_screen.up_next'.tr()} · ${playList.length}'
                                    : 'player_screen.up_next'.tr(),
                                style: AppTextDecor.caption13Muted,
                              ),
                              AnimatedRotation(
                                turns: isSliderOpen ? 0.5 : 0,
                                duration: 200.milisec,
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 20.h,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                      minHeight: 52.h,
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
                              _QueueTabToggle(
                                showHistory: _showHistoryTab,
                                onChanged: (showHistory) => setState(
                                    () => _showHistoryTab = showHistory),
                              ),
                              AppSpacerH(12.h),
                              Expanded(
                                child: _showHistoryTab
                                    ? const _HistoryList()
                                    : (playList.isNotEmpty
                                        ? ListView.builder(
                                            controller: controller,
                                            padding: EdgeInsets.zero,
                                            itemCount: playList.length,
                                            itemBuilder: (context, index) {
                                              final song = playList[index];
                                              return SongTile(
                                                track: song,
                                                index: index,
                                                isSelected: media.data?.title ==
                                                    song.name,
                                                isPaid:
                                                    playList[index].isPaid!,
                                              );
                                            })
                                        : const SizedBox()),
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
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          'assets/images/cdlabel.png',
                                          fit: BoxFit.cover,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/cdlabel.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                ),
                              ),
                              AppSpacerH(16.h),
                              const _PlayerWaveform(),
                              AppSpacerH(16.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Text(
                                  media.data != null ? media.data!.title : "",
                                  style: AppTextDecor.bodyTitle16,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              AppSpacerH(4.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Text(
                                  (media.data?.extras?['desc'] as String?)
                                              ?.isNotEmpty ==
                                          true
                                      ? media.data!.extras!['desc'] as String
                                      : 'player_screen.no_description'.tr(),
                                  style: AppTextDecor.caption13,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                            ? AppColors.textPrimary
                                            : AppColors.textPrimary.withOpacity(0.4),
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
                                                  color: AppColors.textPrimary,
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
                                                          .withOpacity(0.45),
                                                      blurRadius: 28,
                                                      spreadRadius: 2,
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
                                            ? AppColors.textPrimary.withOpacity(0.4)
                                            : AppColors.textPrimary,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              AppSpacerH(16.h),
                              const SleepTimerButton(),
                              AppSpacerH(16.h),
                              _PlayerBottomActions(
                                track: (musicIndex >= 0 &&
                                        musicIndex < playList.length)
                                    ? playList[musicIndex]
                                    : null,
                                trackTitle: media.data?.title,
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

/// Purely decorative animated bars — not driven by real playback amplitude
/// data (the audio engine doesn't expose that). TODO(audio): wire to real
/// amplitude samples if/when the player exposes them.
class _PlayerWaveform extends StatefulWidget {
  const _PlayerWaveform();

  @override
  State<_PlayerWaveform> createState() => _PlayerWaveformState();
}

class _PlayerWaveformState extends State<_PlayerWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  static const _barHeights = [
    14.0, 22.0, 28.0, 18.0, 24.0, 30.0, 20.0, 26.0, 16.0, 22.0, 12.0
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_barHeights.length, (index) {
              final phase =
                  (_controller.value + index * 0.09) % 1.0;
              final scale = 0.5 + 0.5 * (0.5 - (phase - 0.5).abs()) * 2;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                child: Container(
                  width: 3.w,
                  height: _barHeights[index].h * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.r),
                    color: index.isEven
                        ? AppColors.accentPrimary
                        : AppColors.accentSecondary,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Bottom action row (Saved / Download / Share) shown below the sleep-timer
/// chip, matching the design's Now Playing screen. Saved uses the existing
/// real favourites API. Download has no backing service yet (downloads_page
/// is a UI stub with no data source) so it surfaces an honest "coming soon"
/// message rather than pretending to work.
/// TODO(backend): wire Download once an offline-cache/download service exists.
class _PlayerBottomActions extends ConsumerWidget {
  const _PlayerBottomActions({required this.track, required this.trackTitle});

  final MusicTrack? track;
  final String? trackTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionItem(
          icon: track != null && track!.isfavorite == true
              ? Icons.favorite
              : Icons.favorite_border,
          label: 'player_screen.saved'.tr(),
          iconColor: track != null && track!.isfavorite == true
              ? AppColors.accentPrimary
              : AppColors.textMuted,
          onTap: track == null
              ? null
              : () => ref
                  .read(favunfavProvider(track!.id.toString()).notifier)
                  .favUnFav(),
        ),
        _ActionItem(
          icon: Icons.file_download_outlined,
          label: 'player_screen.download'.tr(),
          onTap: () => EasyLoading.showInfo('player_screen.download_soon'.tr()),
        ),
        _ActionItem(
          icon: Icons.ios_share_outlined,
          label: 'player_screen.share'.tr(),
          onTap: trackTitle == null
              ? null
              : () {
                  final box = context.findRenderObject() as RenderBox?;
                  final origin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : const Rect.fromLTWH(0, 0, 1, 1);
                  Share.share(trackTitle!, sharePositionOrigin: origin);
                },
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.h, color: iconColor ?? AppColors.textMuted),
          AppSpacerH(3.h),
          Text(label,
              style: AppTextDecor.tagBadge11
                  .copyWith(color: iconColor ?? AppColors.textMuted)),
        ],
      ),
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

  static const List<int> options = [10, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(sleepTimerRemainingProvider);

    return GestureDetector(
      onTap: () => _openSleepTimerSheet(context, ref),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: AppColors.accentPrimary.withOpacity(0.12),
          border: Border.all(
              color: AppColors.accentPrimary.withOpacity(0.25), width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bedtime_outlined,
                color: AppColors.textSecondary, size: 16.h),
            AppSpacerW(8.w),
            Text(
              remaining != null
                  ? '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'
                  : 'player_screen.sleep_timer'.tr(),
              style: AppTextDecor.tagBadge11
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _openSleepTimerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final activeMinutes = ref.watch(sleepTimerMinutesProvider);
            final maxSheetHeight =
                MediaQuery.of(sheetContext).size.height * 0.6;
            return SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('player_screen.sleep_timer'.tr(),
                          style: AppTextDecor.bold18White),
                      AppSpacerH(16.h),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ...options.map((minutes) => ListTile(
                                  onTap: () {
                                    ref
                                        .read(sleepTimerMinutesProvider
                                            .notifier)
                                        .start(minutes);
                                    Navigator.of(sheetContext).pop();
                                  },
                                  title: Text(
                                    '$minutes ${'player_screen.minutes'.tr()}',
                                    style: AppTextDecor.regular16White,
                                  ),
                                  trailing: activeMinutes == minutes
                                      ? const Icon(Icons.check,
                                          color: AppColors.textPrimary)
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
                                  ? const Icon(Icons.check,
                                      color: AppColors.textPrimary)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Up Next / History tab toggle shown at the top of the queue panel,
/// matching design 11's tab header. Purely local UI state - switching tabs
/// never mutates `currentPlayListProvider`.
class _QueueTabToggle extends StatelessWidget {
  const _QueueTabToggle({required this.showHistory, required this.onChanged});

  final bool showHistory;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _QueueTab(
              label: 'player_screen.up_next'.tr(),
              selected: !showHistory,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _QueueTab(
              label: 'player_screen.history'.tr(),
              selected: showHistory,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentPrimary.withOpacity(0.18) : null,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextDecor.caption13.copyWith(
            color:
                selected ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Read-only History list backed by the same
/// `LocalStorageService.getRecentlyPlayed()` data Home's Recently Played
/// section already uses. Tapping an item resumes it via the existing
/// `openStoredTrack` path - never mutates the current queue.
class _HistoryList extends ConsumerWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = LocalStorageService.getRecentlyPlayed();
    if (items.isEmpty) {
      return Center(
        child: Text(
          'player_screen.no_history'.tr(),
          style: AppTextDecor.caption13Muted,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => openStoredTrack(context, ref, storedData: item),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                ArtworkImage(
                  imageUrl: item['thumbnail']?.toString(),
                  width: 44.w,
                  height: 44.w,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                AppSpacerW(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']?.toString() ?? '',
                        style: AppTextDecor.bodyTitle15,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((item['albumName']?.toString() ?? '').isNotEmpty)
                        Text(
                          item['albumName'].toString(),
                          style: AppTextDecor.caption13Muted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_outline,
                    color: AppColors.textMuted, size: 22.h),
              ],
            ),
          ),
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
