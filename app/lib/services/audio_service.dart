import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/logic/player_prefs_provider.dart';
import 'package:medyo/features/core/models/play_list_model/albam.dart';
import 'package:medyo/features/theme/misc_provider.dart';
import 'package:medyo/services/local_storage_service.dart';
import 'package:medyo/utils/media_url.dart';

final isAudioPaused = StateProvider<bool>((ref) => false);
final playBackDurationProvider =
    StateProvider<Duration>((ref) => Duration.zero);
final currentDurationProvider = StateProvider<Duration?>((ref) => null);
final audioServiceProvider =
    StateNotifierProvider<AudioHandlerNotifier, AudioHandler?>((ref) {
  return AudioHandlerNotifier(ref);
});

class AudioHandlerNotifier extends StateNotifier<AudioHandler?> {
  AudioHandlerNotifier(this.ref) : super(null) {
    initAudioService();
  }
  final Ref ref;

  Future<void> initAudioService() async {
    state ??= await AudioService.init(
      builder: () => MyAudioHandler(ref),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.razinsoft.maditam.audio',
        androidNotificationChannelName: 'Maditam',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final Ref ref;
  bool _isSkippingToNext = false;
  Timer? _positionTimer;
  Duration _basePosition = Duration.zero;
  Stopwatch? _playStopwatch;
  late final StreamSubscription<Duration?> _durationSub;
  late final StreamSubscription<ProcessingState> _processingSub;

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _playStopwatch = Stopwatch()..start();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final pos = _basePosition + (_playStopwatch?.elapsed ?? Duration.zero);
      ref.read(playBackDurationProvider.notifier).state = pos;
    });
  }

  void _stopPositionTimer() {
    _basePosition += _playStopwatch?.elapsed ?? Duration.zero;
    _playStopwatch?.stop();
    _positionTimer?.cancel();
    _positionTimer = null;
    ref.read(playBackDurationProvider.notifier).state = _basePosition;
  }

  void _resetPosition() {
    _basePosition = Duration.zero;
    _playStopwatch?.stop();
    _playStopwatch = null;
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  MyAudioHandler(this.ref) {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _processingSub = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed &&
          !_isSkippingToNext &&
          _player.playing) {
        if (ref.read(repeatModeProvider) == RepeatMode.one) {
          seek(Duration.zero);
          play();
          return;
        }
        _isSkippingToNext = true;
        skipToNext();
      }
    });

    _durationSub = _player.durationStream.listen((duration) {
      if (duration != null && duration > Duration.zero) {
        ref.read(currentDurationProvider.notifier).state = duration;
        if (mediaItem.value != null) {
          mediaItem.add(mediaItem.value!.copyWith(duration: duration));
        }
      }
    });
  }

  @override
  Future<void> play() {
    ref.read(isAudioPaused.notifier).state = false;
    ref.read(bottomShow.notifier).state = true;
    _startPositionTimer();
    final item = mediaItem.value;
    if (item != null) {
      LocalStorageService.addRecentlyPlayed(item);
    }
    return _player.play();
  }

  @override
  Future<void> pause() {
    ref.read(isAudioPaused.notifier).state = true;
    _stopPositionTimer();
    _saveContinueListening();
    return _player.pause();
  }

  void _saveContinueListening() {
    final item = mediaItem.value;
    if (item == null) return;
    LocalStorageService.saveContinueListening(
      item: item,
      position: ref.read(playBackDurationProvider),
      duration: item.duration ?? ref.read(currentDurationProvider),
    );
  }

  @override
  Future<void> seek(Duration position) {
    _basePosition = position;
    _playStopwatch?.reset();
    return _player.seek(position);
  }

  int? _nextIndex(List<MusicTrack> playList, int musicIndex, bool goForward) {
    if (playList.isEmpty) return null;
    final shuffle = ref.read(isShuffleEnabledProvider);
    final repeatMode = ref.read(repeatModeProvider);

    if (shuffle && playList.length > 1) {
      final random = Random();
      int candidate;
      do {
        candidate = random.nextInt(playList.length);
      } while (candidate == musicIndex);
      return candidate;
    }

    if (goForward) {
      if (musicIndex < playList.length - 1) return musicIndex + 1;
      if (repeatMode == RepeatMode.all) return 0;
      return null;
    } else {
      if (musicIndex > 0) return musicIndex - 1;
      if (repeatMode == RepeatMode.all) return playList.length - 1;
      return null;
    }
  }

  @override
  Future<void> skipToNext() async {
    ref.read(bottomShow.notifier).state = true;
    final playList = ref.read(currentPlayListProvider);
    final musicIndex = ref.read(selectedMusicIndex);
    final newIndex = _nextIndex(playList, musicIndex, true);

    if (newIndex != null) {
      ref.read(selectedMusicIndex.notifier).state = newIndex;
      await _playNewItem(playList[newIndex], true);
    } else {
      _isSkippingToNext = false;
      return;
    }

    return super.skipToNext();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    _isSkippingToNext = false;
    _resetPosition();
    ref.read(currentDurationProvider.notifier).state = mediaItem.duration;
    ref.read(playBackDurationProvider.notifier).state = Duration.zero;
    ref.read(audioPlayerProvider).stop();
    this.mediaItem.add(mediaItem);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItem.id)));
  }

  @override
  Future<void> skipToPrevious() async {
    ref.read(bottomShow.notifier).state = true;
    final playList = ref.read(currentPlayListProvider);
    final musicIndex = ref.read(selectedMusicIndex);
    final newIndex = _nextIndex(playList, musicIndex, false);

    if (newIndex != null) {
      ref.read(selectedMusicIndex.notifier).state = newIndex;
      await _playNewItem(playList[newIndex], true);
    }

    return super.skipToPrevious();
  }

  _playNewItem(MusicTrack music, bool stopPlay) async {
    _isSkippingToNext = false;
    _resetPosition();
    final apiDuration =
        music.duration != null ? Duration(seconds: music.duration!) : null;
    ref.read(currentDurationProvider.notifier).state = apiDuration;
    ref.read(playBackDurationProvider.notifier).state = Duration.zero;

    final audioUrl = normalizeMediaUrl(music.audio) ?? '';
    final thumbnailUrl = normalizeMediaUrl(music.thumbnail);
    mediaItem.add(MediaItem(
      id: audioUrl,
      album: music.albam?.name ?? '',
      title: music.name ?? '',
      extras: {
        'isFav': music.isfavorite,
        'id': music.id.toString(),
        'album': music.albam?.id.toString(),
        'desc': music.description,
        'hasReadMore': music.hasReadMore,
        'thumbnail': thumbnailUrl,
      },
      artUri: thumbnailUrl != null ? Uri.parse(thumbnailUrl) : null,
      duration: apiDuration,
    ));

    if (stopPlay) {
      if (audioUrl.isEmpty) {
        return;
      }
      try {
        await _player.stop();
        ref.read(audioPlayerProvider).stop();
        await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
        await play();
      } catch (e) {
        _isSkippingToNext = false;
        debugPrint('[Audio] setAudioSource error: $e');
      }
    }
  }

  @override
  Future<void> stop() {
    ref.read(isAudioPaused.notifier).state = false;
    _saveContinueListening();
    _resetPosition();
    ref.read(playBackDurationProvider.notifier).state = Duration.zero;
    return _player.stop();
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
