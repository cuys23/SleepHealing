import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medyo/services/audio_service.dart';
import 'package:medyo/services/local_storage_service.dart';

/// Time remaining on the active sleep timer, or null when no timer is running.
final sleepTimerRemainingProvider = StateProvider<Duration?>((ref) => null);

/// The minutes value currently active (for highlighting the picked option),
/// or null when no timer is running.
final sleepTimerMinutesProvider =
    StateNotifierProvider<SleepTimerController, int?>((ref) {
  return SleepTimerController(ref);
});

class SleepTimerController extends StateNotifier<int?> {
  SleepTimerController(this.ref) : super(null);
  final Ref ref;
  Timer? _ticker;

  void start(int minutes) {
    _ticker?.cancel();
    LocalStorageService.saveLastSleepTimerMinutes(minutes);

    var remaining = Duration(minutes: minutes);
    state = minutes;
    ref.read(sleepTimerRemainingProvider.notifier).state = remaining;

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining -= const Duration(seconds: 1);
      if (remaining <= Duration.zero) {
        timer.cancel();
        ref.read(sleepTimerRemainingProvider.notifier).state = null;
        state = null;
        ref.read(audioServiceProvider)?.pause();
      } else {
        ref.read(sleepTimerRemainingProvider.notifier).state = remaining;
      }
    });
  }

  void cancelTimer() {
    _ticker?.cancel();
    _ticker = null;
    state = null;
    ref.read(sleepTimerRemainingProvider.notifier).state = null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
