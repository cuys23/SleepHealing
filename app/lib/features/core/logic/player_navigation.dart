import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medyo/features/core/logic/core_provider.dart';
import 'package:medyo/features/core/models/album_list_model/albam.dart';
import 'package:medyo/features/core/models/play_list_model/albam.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/utils/context_less_nav.dart';
import 'package:medyo/utils/global_function.dart';
import 'package:medyo/utils/routes.dart';

/// Opens the player screen and plays a track reconstructed from data saved
/// locally by Recently Played / Continue Listening. Bypasses the "Sub"/"Home"
/// auto-play watchers in PlayerScreen entirely (resets their providers to
/// null) so this never fights with the album-browsing flows.
Future<void> openStoredTrack(
  BuildContext context,
  WidgetRef ref, {
  required Map storedData,
  Duration? seekTo,
}) async {
  final id = storedData['id'] ?? storedData['playlistId'];
  final albumId = storedData['albumId'];

  final track = MusicTrack(
    id: int.tryParse(id?.toString() ?? ''),
    name: storedData['title'] as String?,
    description: storedData['desc'] as String?,
    thumbnail: storedData['thumbnail'] as String?,
    audio: storedData['audio'] as String?,
    isfavorite: storedData['isFav'] as bool?,
    isPaid: false,
    hasReadMore: storedData['hasReadMore'] as bool?,
    albam: albumId != null ? Albam(id: int.tryParse(albumId.toString())) : null,
  );

  ref.read(selectedAlbumProvider.notifier).state = null;
  ref.read(selectedDatumProvider.notifier).state = null;
  ref.read(selectedMusicProvider.notifier).state = null;
  ref.read(selectedMusicIndex.notifier).state = 0;
  ref.read(currentPlayListProvider.notifier).state = [track];

  context.nav.pushNamed(Routes.playerScreen);

  final audioHandler = ref.read(audioServiceProvider);
  if (audioHandler == null) return;
  await AppGLF.changeAndPlayMedia(audioHandler, track, shouldPlay: true);

  if (seekTo != null && seekTo > Duration.zero) {
    await Future.delayed(const Duration(milliseconds: 400));
    await audioHandler.seek(seekTo);
  }
}
