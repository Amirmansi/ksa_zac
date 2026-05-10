import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String displayName;

  @HiveField(1)
  int coins;

  @HiveField(2)
  int totalGames;

  @HiveField(3)
  int wins;

  @HiveField(4)
  int correctAnswers;

  @HiveField(5)
  List<String> unlockedChars;

  @HiveField(6)
  String selectedChar;

  @HiveField(7)
  DateTime? lastDailyReward;

  @HiveField(8)
  int dailyStreak;

  @HiveField(9)
  List<String> achievements;

  @HiveField(10)
  bool soundEnabled;

  @HiveField(11)
  bool musicEnabled;

  @HiveField(12)
  bool hapticsEnabled;

  @HiveField(13)
  double volume;

  @HiveField(14)
  String language;

  @HiveField(15)
  DateTime createdAt;

  UserProfile({
    this.displayName = 'لاعب',
    this.coins = 100,
    this.totalGames = 0,
    this.wins = 0,
    this.correctAnswers = 0,
    List<String>? unlockedChars,
    this.selectedChar = 'fahlawy',
    this.lastDailyReward,
    this.dailyStreak = 0,
    List<String>? achievements,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.volume = 0.7,
    this.language = 'ar',
    DateTime? createdAt,
  })  : unlockedChars = unlockedChars ?? <String>['fahlawy'],
        achievements = achievements ?? <String>[],
        createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? displayName,
    int? coins,
    int? totalGames,
    int? wins,
    int? correctAnswers,
    List<String>? unlockedChars,
    String? selectedChar,
    DateTime? lastDailyReward,
    bool clearLastDailyReward = false,
    int? dailyStreak,
    List<String>? achievements,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    double? volume,
    String? language,
    DateTime? createdAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      coins: coins ?? this.coins,
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      unlockedChars: unlockedChars ?? List<String>.from(this.unlockedChars),
      selectedChar: selectedChar ?? this.selectedChar,
      lastDailyReward:
          clearLastDailyReward ? null : (lastDailyReward ?? this.lastDailyReward),
      dailyStreak: dailyStreak ?? this.dailyStreak,
      achievements: achievements ?? List<String>.from(this.achievements),
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get canClaimDailyReward {
    if (lastDailyReward == null) return true;
    final daysSince = DateTime.now().difference(lastDailyReward!).inHours ~/ 24;
    return daysSince >= 1;
  }

  bool get streakStillValid {
    if (lastDailyReward == null) return false;
    return DateTime.now().difference(lastDailyReward!).inHours < 48;
  }

  bool ownsCharacter(String charId) => unlockedChars.contains(charId);

  bool hasAchievement(String id) => achievements.contains(id);

  double get winRate => totalGames == 0 ? 0 : wins / totalGames;
}
