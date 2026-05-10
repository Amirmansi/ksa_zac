import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants.dart';
import 'data/models/user_profile.dart';
import 'utils/audio_manager.dart';
import 'utils/haptic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive init + adapters + box.
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserProfileAdapter());
  }
  await Hive.openBox<UserProfile>(GameConstants.boxProfile);

  // Read profile to bootstrap audio + haptics with saved settings.
  final profileBox = Hive.box<UserProfile>(GameConstants.boxProfile);
  final saved = profileBox.get('me');
  await AudioManager.instance.init(
    soundEnabled: saved?.soundEnabled ?? true,
    musicEnabled: saved?.musicEnabled ?? true,
    volume: saved?.volume ?? 0.7,
  );
  Haptic.setEnabled(saved?.hapticsEnabled ?? true);

  runApp(const ProviderScope(child: EgyptianRaceApp()));
}
