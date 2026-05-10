import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants.dart';
import '../models/user_profile.dart';

final profileRepoProvider =
    NotifierProvider<ProfileRepo, UserProfile>(ProfileRepo.new);

class ProfileRepo extends Notifier<UserProfile> {
  late final Box<UserProfile> _box;

  @override
  UserProfile build() {
    _box = Hive.box<UserProfile>(GameConstants.boxProfile);
    final existing = _box.get('me');
    if (existing != null) return existing;
    final fresh = UserProfile();
    _box.put('me', fresh);
    return fresh;
  }

  Future<void> _persist(UserProfile next) async {
    await _box.put('me', next);
    state = next;
  }

  Future<void> setDisplayName(String name) async {
    final clean = name.trim().isEmpty ? 'لاعب' : name.trim();
    await _persist(state.copyWith(displayName: clean));
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _persist(state.copyWith(coins: state.coins + amount));
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;
    await _persist(state.copyWith(coins: state.coins - amount));
    return true;
  }

  Future<void> recordGame() =>
      _persist(state.copyWith(totalGames: state.totalGames + 1));

  Future<void> recordWin() =>
      _persist(state.copyWith(wins: state.wins + 1));

  Future<void> recordCorrectAnswer() =>
      _persist(state.copyWith(correctAnswers: state.correctAnswers + 1));

  Future<bool> unlockCharacter(String charId, int price) async {
    if (state.unlockedChars.contains(charId)) return true;
    if (state.coins < price) return false;
    await _persist(state.copyWith(
      coins: state.coins - price,
      unlockedChars: [...state.unlockedChars, charId],
    ));
    return true;
  }

  Future<void> selectCharacter(String charId) async {
    if (!state.unlockedChars.contains(charId)) return;
    await _persist(state.copyWith(selectedChar: charId));
  }

  Future<void> grantAchievement(String id) async {
    if (state.achievements.contains(id)) return;
    await _persist(state.copyWith(
      achievements: [...state.achievements, id],
    ));
  }

  /// Returns reward amount when claim succeeds; 0 if not claimable yet.
  Future<int> claimDailyReward() async {
    if (!state.canClaimDailyReward) return 0;
    final keepStreak = state.streakStillValid;
    final newStreak = keepStreak ? state.dailyStreak + 1 : 1;
    final idx = ((newStreak - 1) % GameConstants.dailyRewards.length)
        .clamp(0, GameConstants.dailyRewards.length - 1);
    final reward = GameConstants.dailyRewards[idx];
    await _persist(state.copyWith(
      coins: state.coins + reward,
      dailyStreak: newStreak,
      lastDailyReward: DateTime.now(),
    ));
    return reward;
  }

  Future<void> setSoundEnabled(bool v) =>
      _persist(state.copyWith(soundEnabled: v));

  Future<void> setMusicEnabled(bool v) =>
      _persist(state.copyWith(musicEnabled: v));

  Future<void> setHapticsEnabled(bool v) =>
      _persist(state.copyWith(hapticsEnabled: v));

  Future<void> setVolume(double v) =>
      _persist(state.copyWith(volume: v.clamp(0.0, 1.0)));

  Future<void> resetProgress() async {
    final fresh = UserProfile();
    await _box.put('me', fresh);
    state = fresh;
  }
}
