import 'package:go_router/go_router.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/setup/player_setup_screen.dart';
import '../presentation/game/game_screen.dart';
import '../presentation/store/store_screen.dart';
import '../presentation/achievements/achievements_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/tutorial/tutorial_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const setup = '/setup';
  static const game = '/game';
  static const store = '/store';
  static const achievements = '/achievements';
  static const settings = '/settings';
  static const tutorial = '/tutorial';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: setup, builder: (_, __) => const PlayerSetupScreen()),
      GoRoute(path: game, builder: (_, __) => const GameScreen()),
      GoRoute(path: store, builder: (_, __) => const StoreScreen()),
      GoRoute(path: achievements, builder: (_, __) => const AchievementsScreen()),
      GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: tutorial, builder: (_, __) => const TutorialScreen()),
    ],
  );
}
