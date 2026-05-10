import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:egyptian_race/core/constants.dart';
import 'package:egyptian_race/data/models/user_profile.dart';

void main() {
  setUpAll(() async {
    Hive.init('./test/.hive');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    await Hive.openBox<UserProfile>(GameConstants.boxProfile);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  test('UserProfile defaults are sane', () {
    final p = UserProfile();
    expect(p.coins, GameConstants.initialCoins);
    expect(p.unlockedChars, contains('fahlawy'));
    expect(p.selectedChar, 'fahlawy');
    expect(p.canClaimDailyReward, true);
  });

  test('Daily reward claimable when never claimed', () {
    final p = UserProfile();
    expect(p.canClaimDailyReward, true);
  });

  test('Daily reward NOT claimable just after claim', () {
    final p = UserProfile()..lastDailyReward = DateTime.now();
    expect(p.canClaimDailyReward, false);
    expect(p.streakStillValid, true);
  });

  test('Daily reward claimable after 25h', () {
    final p = UserProfile()
      ..lastDailyReward = DateTime.now().subtract(const Duration(hours: 25));
    expect(p.canClaimDailyReward, true);
    expect(p.streakStillValid, true);
  });

  test('Streak resets after 48h gap', () {
    final p = UserProfile()
      ..lastDailyReward = DateTime.now().subtract(const Duration(hours: 50));
    expect(p.streakStillValid, false);
  });

  test('Hive round-trip preserves fields', () async {
    final box = Hive.box<UserProfile>(GameConstants.boxProfile);
    final fresh = UserProfile(
      displayName: 'أمير',
      coins: 250,
      wins: 3,
      dailyStreak: 5,
      unlockedChars: ['fahlawy', 'osta'],
      selectedChar: 'osta',
    );
    await box.put('me', fresh);
    final loaded = box.get('me')!;
    expect(loaded.displayName, 'أمير');
    expect(loaded.coins, 250);
    expect(loaded.wins, 3);
    expect(loaded.dailyStreak, 5);
    expect(loaded.unlockedChars, containsAll(<String>['fahlawy', 'osta']));
    expect(loaded.selectedChar, 'osta');
  });
}
