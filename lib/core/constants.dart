class GameConstants {
  GameConstants._();

  // Board
  static const int boardTiles = 30;
  static const int gridRows = 6;
  static const int gridCols = 5;
  static const double tileSize = 56;
  static const double tileGap = 4;

  // Players
  static const int minPlayers = 2;
  static const int maxPlayers = 4;

  // Timing (ms / seconds)
  static const int turnTimeSeconds = 30;
  static const int questionTimeSeconds = 12;
  static const int questionTimeBonusFahlawy = 2;
  static const int moveAnimationMs = 200;
  static const int diceRollMs = 1000;

  // Powers
  static const int maxPowersInBar = 3;

  // Dice
  static const int maxConsecutiveSixes = 3;

  // Collision threshold
  static const int collisionThresholdTile = 15;
  static const int collisionLateRetreat = 5;

  // Tile effects
  static const int greenForward = 3;
  static const int redBackward = 5;
  static const int dashForward = 5;
  static const int jumpForward = 7;

  // Economy
  static const int initialCoins = 100;
  static const int coinsPerWin = 50;
  static const int coinsPerSecondPlace = 30;
  static const int coinsPerThirdPlace = 15;
  static const int coinsPerFourthPlace = 5;
  static const int coinsPerCorrectAnswer = 5;
  static const int coinsTutorialReward = 50;

  // Daily reward streak
  static const List<int> dailyRewards = [50, 75, 100, 150, 200, 300, 500];

  // Hive boxes
  static const String boxProfile = 'profile';
  static const String boxAchievements = 'achievements';
}
