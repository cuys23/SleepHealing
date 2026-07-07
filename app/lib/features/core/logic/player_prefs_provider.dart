import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RepeatMode { off, one, all }

final isShuffleEnabledProvider = StateProvider<bool>((ref) => false);

final repeatModeProvider = StateProvider<RepeatMode>((ref) => RepeatMode.off);
