import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medyo/config/app_colors.dart';
import 'package:medyo/config/app_text_decor.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/views/player_screen.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/utils/routes.dart';
import 'package:medyo/widgets/misc_widgets.dart';

class BottomPlayerControl extends ConsumerStatefulWidget {
  const BottomPlayerControl({super.key});

  @override
  ConsumerState<BottomPlayerControl> createState() =>
      _BottomPlayerControlState();
}

class _BottomPlayerControlState extends ConsumerState<BottomPlayerControl> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(audioServiceProvider);
    final showBottom = ref.watch(bottomShow);
    return showBottom
        ? GestureDetector(
            onPanUpdate: (details) {
              debugPrint('drag : ${details.delta.dy}');
              ref.watch(bottomPlayerOffset('x').notifier).state =
                  details.delta.dx * 5;
              ref.watch(bottomPlayerOffset('y').notifier).state =
                  details.delta.dy * 5;
              if (details.delta.dy < -3 || details.delta.dy > 3) {
                context.nav.pushNamed(Routes.playerScreen);
                ref.watch(bottomPlayerOffset('x').notifier).state = 0;
                ref.watch(bottomPlayerOffset('y').notifier).state = 0;
              }
              if (details.delta.dx < -10 || details.delta.dx > 10) {
                ref.watch(bottomShow.notifier).state = false;
                ref.watch(bottomPlayerOffset('x').notifier).state = 0;
                ref.watch(bottomPlayerOffset('y').notifier).state = 0;
              }
            },
            child: StreamBuilder<PlaybackState>(
                stream: audioHandler?.playbackState,
                builder: (context, media) {
                  if (media.hasData &&
                      media.data != null &&
                      (media.data!.playing || ref.watch(isAudioPaused))) {
                    return Container(
                      height: 80.h,
                      width: 390.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: StreamBuilder<MediaItem?>(
                                  stream: audioHandler?.mediaItem,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: snapshot.data!.artUri
                                                .toString(),
                                            fit: BoxFit.fitHeight,
                                            alignment: Alignment.topLeft,
                                            errorWidget: (context, url, error) {
                                              return const SizedBox();
                                            },
                                          ),
                                          AppSpacerW(10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  snapshot.data!.title,
                                                  style:
                                                      AppTextDecor.bodyTitle15,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  snapshot.data!.album ?? '',
                                                  style:
                                                      AppTextDecor.caption12,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    PlayerIconsSmall(
                                      svgPath: 'assets/svgs/icon_previous.svg',
                                      onTap: () {
                                        audioHandler?.skipToPrevious();
                                      },
                                    ),
                                    AppSpacerW(20.w),
                                    StreamBuilder<bool>(
                                      stream: audioHandler?.playbackState
                                          .map((state) => state.playing)
                                          .distinct(),
                                      builder: (context, snapshot) {
                                        final playing = snapshot.data ?? false;

                                        return GestureDetector(
                                          onTap: () {
                                            debugPrint('Status $playing');
                                            if (playing) {
                                              audioHandler?.pause();
                                            } else {
                                              audioHandler?.play();
                                            }
                                          },
                                          child: Container(
                                            height: 40.h,
                                            width: 40.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.accentPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(20.h),
                                            ),
                                            child: Center(
                                              child: PlayerIconsSmall(
                                                svgPath: playing
                                                    ? 'assets/svgs/icon_pause.svg'
                                                    : 'assets/svgs/icon_play.svg',
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    AppSpacerW(20.w),
                                    PlayerIconsSmall(
                                      svgPath: 'assets/svgs/icon_next.svg',
                                      onTap: () {
                                        audioHandler?.skipToNext();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<MediaItem?>(
                            stream: audioHandler?.mediaItem,
                            builder: (context, mediaSnapshot) {
                              return Consumer(
                                builder: (context, ref, _) {
                                  final position =
                                      ref.watch(playBackDurationProvider);
                                  final totalDuration =
                                      mediaSnapshot.data?.duration ??
                                          ref.watch(currentDurationProvider);
                                  return Row(
                                    children: [
                                      Text(AppGLF.format(position),
                                          style: AppTextDecor.caption12),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 3.h,
                                            overlayShape:
                                                SliderComponentShape.noThumb,
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius: 5.r),
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
                                            inactiveColor: AppColors.divider,
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
                                      Text(
                                        totalDuration != null
                                            ? AppGLF.format(totalDuration)
                                            : "0:00",
                                        style: AppTextDecor.caption12,
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
          )
        : const SizedBox();
  }
}
